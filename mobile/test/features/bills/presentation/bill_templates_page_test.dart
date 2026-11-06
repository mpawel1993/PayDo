import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/core/testing/test_ids.dart';
import 'package:paydo/core/theme/app_colors.dart';
import 'package:paydo/features/bills/domain/bill_category.dart';
import 'package:paydo/features/bills/domain/year_month.dart';
import 'package:paydo/features/bills/presentation/bill_templates_page.dart';
import 'package:paydo/features/bills/presentation/bills_page.dart';

import '../../../support/builders/bill_template_builder.dart';
import '../../../support/fakes/in_memory_bills_repository.dart';
import '../../../support/finders.dart';
import '../../../support/pump_app.dart';

const _personal = 'personal';
const _company = 'company';

Future<void> _pump(WidgetTester tester, {InMemoryBillsRepository? bills, Locale locale = const Locale('pl')}) async {
  await pumpApp(tester, const BillTemplatesPage(), bills: bills ?? InMemoryBillsRepository(), locale: locale);
  await tester.pumpAndSettle();
}

FilledButton _addButton(WidgetTester tester, String category) =>
    tester.widget<FilledButton>(find.descendant(of: byId(TestIds.billTemplatesAdd(category)), matching: find.byType(FilledButton)));

void main() {
  testWidgets('shows the header and empty sections', (tester) async {
    await _pump(tester);

    expect(byId(TestIds.billTemplatesPage), findsOneWidget);
    expect(textOf(tester, TestIds.billTemplatesTitle), 'Szablony rachunków');
    expect(byId(TestIds.billTemplatesBack), findsOneWidget);
    expect(byId(TestIds.billTemplatesBackIcon), findsOneWidget);
    for (final c in [_personal, _company]) {
      expect(byId(TestIds.billTemplatesSection(c)), findsOneWidget);
      expect(textOf(tester, TestIds.billTemplatesEmpty(c)), 'Brak szablonów');
      expect(byId(TestIds.billTemplatesInput(c)), findsOneWidget);
      expect(byId(TestIds.billTemplatesAdd(c)), findsOneWidget);
      expect(byId(TestIds.billTemplatesAddIcon(c)), findsOneWidget);
    }
    expect(textOf(tester, TestIds.billTemplatesSectionTitle(_personal)), 'Osobiste');
    expect(textOf(tester, TestIds.billTemplatesSectionTitle(_company)), 'Firmowe');
  });

  testWidgets('shows English texts for the en locale', (tester) async {
    await _pump(tester, locale: const Locale('en'));

    expect(textOf(tester, TestIds.billTemplatesTitle), 'Bill templates');
    expect(textOf(tester, TestIds.billTemplatesEmpty(_personal)), 'No templates');
  });

  testWidgets('lists only active templates in their category', (tester) async {
    await _pump(
      tester,
      bills: InMemoryBillsRepository(
        templates: [
          BillTemplateBuilder().withId(1).withName('Czynsz').build(),
          BillTemplateBuilder().withId(2).withName('ZUS').inCategory(BillCategory.company).build(),
          BillTemplateBuilder().withId(3).withName('Stary').endingAt(YearMonth(2026, 10)).build(),
        ],
      ),
    );

    expect(textOf(tester, TestIds.billTemplatesRowName(1)), 'Czynsz');
    expect(find.descendant(of: byId(TestIds.billTemplatesSection(_company)), matching: byId(TestIds.billTemplatesRow(2))), findsOneWidget);
    expect(byId(TestIds.billTemplatesRow(3)), findsNothing);
    expect(byId(TestIds.billTemplatesEmpty(_personal)), findsNothing);
    expect(byId(TestIds.billTemplatesRowDelete(1)), findsOneWidget);
    expect(byId(TestIds.billTemplatesRowDeleteIcon(1)), findsOneWidget);
  });

  testWidgets('the add button is disabled until a name is typed', (tester) async {
    await _pump(tester);
    expect(_addButton(tester, _company).onPressed, isNull);

    await tester.enterText(byId(TestIds.billTemplatesInput(_company)), '   ');
    await tester.pump();
    expect(_addButton(tester, _company).onPressed, isNull);

    await tester.enterText(byId(TestIds.billTemplatesInput(_company)), 'ZUS');
    await tester.pump();
    expect(_addButton(tester, _company).onPressed, isNotNull);
  });

  testWidgets('adds a template to the section it was typed in and clears the input', (tester) async {
    final repository = InMemoryBillsRepository();
    await _pump(tester, bills: repository);

    await tester.enterText(byId(TestIds.billTemplatesInput(_company)), ' ZUS ');
    await tester.pump();
    await tester.tap(byId(TestIds.billTemplatesAdd(_company)));
    await tester.pumpAndSettle();

    final stored = repository.storedTemplates.single;
    expect(stored.name, 'ZUS');
    expect(stored.category, BillCategory.company);
    expect(stored.startMonth, YearMonth(2026, 11));
    expect(
      find.descendant(of: byId(TestIds.billTemplatesSection(_company)), matching: byId(TestIds.billTemplatesRow(stored.id))),
      findsOneWidget,
    );
    expect(
      tester
          .widget<TextField>(find.descendant(of: byId(TestIds.billTemplatesInput(_company)), matching: find.byType(TextField)))
          .controller!
          .text,
      isEmpty,
    );
  });

  testWidgets('submitting from the keyboard adds the template', (tester) async {
    final repository = InMemoryBillsRepository();
    await _pump(tester, bills: repository);

    await tester.enterText(byId(TestIds.billTemplatesInput(_personal)), 'Prąd');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(repository.storedTemplates.single.name, 'Prąd');
    expect(repository.storedTemplates.single.category, BillCategory.personal);
  });

  testWidgets('deleting asks for confirmation; No keeps the template', (tester) async {
    final repository = InMemoryBillsRepository(templates: [BillTemplateBuilder().withId(1).withName('Czynsz').build()]);
    await _pump(tester, bills: repository);

    await tester.tap(byId(TestIds.billTemplatesRowDelete(1)));
    await tester.pumpAndSettle();
    expect(byId(TestIds.confirmDialog), findsOneWidget);
    expect(textOf(tester, TestIds.confirmDialogMessage), 'Czy na pewno usunąć szablon „Czynsz”?');
    expect(textOf(tester, TestIds.confirmDialogYes), 'Tak');
    expect(textOf(tester, TestIds.confirmDialogNo), 'Nie');

    await tester.tap(byId(TestIds.confirmDialogNo));
    await tester.pumpAndSettle();

    expect(byId(TestIds.confirmDialog), findsNothing);
    expect(byId(TestIds.billTemplatesRow(1)), findsOneWidget);
    expect(repository.storedTemplates.single.endMonth, isNull);
  });

  testWidgets('deleting with Yes removes the template from the list', (tester) async {
    final repository = InMemoryBillsRepository(templates: [BillTemplateBuilder().withId(1).withName('Czynsz').build()]);
    await _pump(tester, bills: repository);

    await tester.tap(byId(TestIds.billTemplatesRowDelete(1)));
    await tester.pumpAndSettle();
    await tester.tap(byId(TestIds.confirmDialogYes));
    await tester.pumpAndSettle();

    expect(byId(TestIds.billTemplatesRow(1)), findsNothing);
    expect(byId(TestIds.billTemplatesEmpty(_personal)), findsOneWidget);
    expect(repository.storedTemplates.single.endMonth, YearMonth(2026, 11));
  });

  testWidgets('a template added here shows up on the bills page after going back', (tester) async {
    await pumpApp(tester, const BillsPage());
    await tester.pumpAndSettle();
    await tester.tap(byId(TestIds.billsTemplatesButton));
    await tester.pumpAndSettle();

    await tester.enterText(byId(TestIds.billTemplatesInput(_personal)), 'Czynsz');
    await tester.pump();
    await tester.tap(byId(TestIds.billTemplatesAdd(_personal)));
    await tester.pumpAndSettle();
    await tester.tap(byId(TestIds.billTemplatesBack));
    await tester.pumpAndSettle();

    expect(byId(TestIds.billTemplatesPage), findsNothing);
    expect(textOf(tester, TestIds.billsRowName(YearMonth(2026, 11).key, 1)), 'Czynsz');
  });

  testWidgets('adds a template with an optional due day and shows it under the name', (tester) async {
    final repository = InMemoryBillsRepository();
    await _pump(tester, bills: repository);
    expect(textOf(tester, TestIds.billTemplatesDueDayInput(_personal)), 'Dzień');
    expect(find.byType(TextField), findsNWidgets(2), reason: 'only the two name fields are text fields');

    await tester.enterText(byId(TestIds.billTemplatesInput(_personal)), 'Czynsz');
    await _pickDay(tester, TestIds.billTemplatesDueDayInput(_personal), 10);
    expect(textOf(tester, TestIds.billTemplatesDueDayInput(_personal)), '10');
    await tester.tap(byId(TestIds.billTemplatesAdd(_personal)));
    await tester.pumpAndSettle();

    final stored = repository.storedTemplates.single;
    expect(stored.dueDay, 10);
    expect(textOf(tester, TestIds.billTemplatesRowDetails(stored.id)), 'Termin: 10. dzień miesiąca');
    expect(textOf(tester, TestIds.billTemplatesDueDayInput(_personal)), 'Dzień');
  });

  testWidgets('the due day calendar can clear the chosen day', (tester) async {
    final repository = InMemoryBillsRepository();
    await _pump(tester, bills: repository);
    await tester.enterText(byId(TestIds.billTemplatesInput(_personal)), 'Czynsz');
    await _pickDay(tester, TestIds.billTemplatesDueDayInput(_personal), 10);

    await tester.tap(byId(TestIds.billTemplatesDueDayInput(_personal)));
    await tester.pumpAndSettle();
    expect(textOf(tester, TestIds.dayPickerClear), 'Bez terminu');
    await tester.tap(byId(TestIds.dayPickerClear));
    await tester.pumpAndSettle();
    await tester.tap(byId(TestIds.billTemplatesAdd(_personal)));
    await tester.pumpAndSettle();

    expect(repository.storedTemplates.single.dueDay, isNull);
  });

  testWidgets('templates without a due day have no details line', (tester) async {
    await _pump(tester, bills: InMemoryBillsRepository(templates: [BillTemplateBuilder().withId(1).build()]));
    expect(byId(TestIds.billTemplatesRowDetails(1)), findsNothing);
  });

  testWidgets('the delete confirmation uses a red Yes button', (tester) async {
    await _pump(tester, bills: InMemoryBillsRepository(templates: [BillTemplateBuilder().withId(1).build()]));
    await tester.tap(byId(TestIds.billTemplatesRowDelete(1)));
    await tester.pumpAndSettle();

    expect(_yesColor(tester), AppColors.danger);
  });

  group('editing', () {
    final rent = BillTemplateBuilder().withId(1).withName('Czynsz').withDueDay(10).build();

    Future<InMemoryBillsRepository> openEditor(WidgetTester tester) async {
      final repository = InMemoryBillsRepository(templates: [rent]);
      await _pump(tester, bills: repository);
      expect(byId(TestIds.billTemplatesRowEditIcon(1)), findsOneWidget);
      await tester.tap(byId(TestIds.billTemplatesRowEdit(1)));
      await tester.pumpAndSettle();
      return repository;
    }

    FilledButton save(WidgetTester tester) =>
        tester.widget<FilledButton>(find.descendant(of: byId(TestIds.billTemplatesEditSave), matching: find.byType(FilledButton)));

    testWidgets('opens a dialog prefilled with the template', (tester) async {
      await openEditor(tester);

      expect(byId(TestIds.billTemplatesEditDialog), findsOneWidget);
      expect(textOf(tester, TestIds.billTemplatesEditTitle), 'Edytuj szablon');
      expect(_fieldText(tester, TestIds.billTemplatesEditName), 'Czynsz');
      expect(textOf(tester, TestIds.billTemplatesEditDueDay), '10');
      expect(byId(TestIds.billTemplatesEditSave), findsOneWidget);
      expect(byId(TestIds.billTemplatesEditCancel), findsOneWidget);
    });

    testWidgets('Save asks for confirmation and Yes stores the changes', (tester) async {
      final repository = await openEditor(tester);

      await tester.enterText(byId(TestIds.billTemplatesEditName), 'Prąd');
      await tester.tap(byId(TestIds.billTemplatesEditDueDay));
      await tester.pumpAndSettle();
      expect(byId(TestIds.dayPicker), findsOneWidget);
      await tester.tap(byId(TestIds.dayPickerClear));
      await tester.pumpAndSettle();
      expect(textOf(tester, TestIds.billTemplatesEditDueDay), 'Dzień');
      await tester.tap(byId(TestIds.billTemplatesEditSave));
      await tester.pumpAndSettle();
      expect(textOf(tester, TestIds.confirmDialogMessage), 'Czy na pewno zapisać zmiany w szablonie „Czynsz”?');
      expect(_yesColor(tester), AppColors.yellow400);

      await tester.tap(byId(TestIds.confirmDialogYes));
      await tester.pumpAndSettle();

      expect(byId(TestIds.billTemplatesEditDialog), findsNothing);
      expect(repository.storedTemplates.single, rent.copyWith(name: 'Prąd').withDueDay(null));
      expect(textOf(tester, TestIds.billTemplatesRowName(1)), 'Prąd');
    });

    testWidgets('No in the confirmation keeps the template unchanged', (tester) async {
      final repository = await openEditor(tester);

      await _pickDay(tester, TestIds.billTemplatesEditDueDay, 15);
      expect(textOf(tester, TestIds.billTemplatesEditDueDay), '15');
      await tester.tap(byId(TestIds.billTemplatesEditSave));
      await tester.pumpAndSettle();
      await tester.tap(byId(TestIds.confirmDialogNo));
      await tester.pumpAndSettle();

      expect(byId(TestIds.confirmDialog), findsNothing);
      expect(byId(TestIds.billTemplatesEditDialog), findsNothing);
      expect(repository.storedTemplates.single, rent);
    });

    testWidgets('Cancel closes the dialog without asking', (tester) async {
      final repository = await openEditor(tester);

      await tester.tap(byId(TestIds.billTemplatesEditCancel));
      await tester.pumpAndSettle();

      expect(byId(TestIds.billTemplatesEditDialog), findsNothing);
      expect(byId(TestIds.confirmDialog), findsNothing);
      expect(repository.storedTemplates.single, rent);
    });

    testWidgets('Save is disabled for an empty name', (tester) async {
      await openEditor(tester);

      await tester.enterText(byId(TestIds.billTemplatesEditName), ' ');
      await tester.pump();
      expect(save(tester).onPressed, isNull);

      await tester.enterText(byId(TestIds.billTemplatesEditName), 'Prąd');
      await tester.pump();
      expect(save(tester).onPressed, isNotNull);
    });

    testWidgets('the calendar opens on the current due day', (tester) async {
      await openEditor(tester);
      await tester.tap(byId(TestIds.billTemplatesEditDueDay));
      await tester.pumpAndSettle();

      final day10 = tester.widget<Container>(find.descendant(of: byId(TestIds.dayPickerDay(10)), matching: find.byType(Container)).first);
      expect((day10.decoration! as BoxDecoration).color, AppColors.primary);
    });
  });
}

String _fieldText(WidgetTester tester, String id) =>
    tester.widget<TextField>(find.descendant(of: byId(id), matching: find.byType(TextField))).controller!.text;

Future<void> _pickDay(WidgetTester tester, String buttonId, int day) async {
  await tester.tap(byId(buttonId));
  await tester.pumpAndSettle();
  await tester.tap(byId(TestIds.dayPickerDay(day)));
  await tester.pumpAndSettle();
}

Color? _yesColor(WidgetTester tester) {
  final finder = find.descendant(of: byId(TestIds.confirmDialogYes), matching: find.byType(FilledButton));
  final style = tester.widget<FilledButton>(finder).style ?? FilledButtonTheme.of(tester.element(finder)).style!;
  return style.backgroundColor!.resolve({});
}
