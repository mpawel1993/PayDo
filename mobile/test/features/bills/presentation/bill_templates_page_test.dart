import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/core/testing/test_ids.dart';
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

  testWidgets('deleting removes the template from the list', (tester) async {
    final repository = InMemoryBillsRepository(templates: [BillTemplateBuilder().withId(1).withName('Czynsz').build()]);
    await _pump(tester, bills: repository);

    await tester.tap(byId(TestIds.billTemplatesRowDelete(1)));
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
}
