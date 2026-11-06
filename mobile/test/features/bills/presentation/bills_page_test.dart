import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/core/testing/test_ids.dart';
import 'package:paydo/core/theme/app_colors.dart';
import 'package:paydo/core/widgets/app_checkbox.dart';
import 'package:paydo/features/bills/domain/bill.dart';
import 'package:paydo/features/bills/domain/bill_category.dart';
import 'package:paydo/features/bills/domain/calendar_date.dart';
import 'package:paydo/features/bills/domain/year_month.dart';
import 'package:paydo/features/bills/presentation/bills_page.dart';

import '../../../support/builders/bill_template_builder.dart';
import '../../../support/fakes/in_memory_bills_repository.dart';
import '../../../support/finders.dart';
import '../../../support/pump_app.dart';

final _nov = YearMonth(2026, 11);
final _oct = YearMonth(2026, 10);
const _personal = 'personal';
const _company = 'company';

InMemoryBillsRepository _repository({Map<(int, YearMonth), BillEntry> entries = const {}}) => InMemoryBillsRepository(
  templates: [
    BillTemplateBuilder().withId(1).withName('Czynsz').startingAt(YearMonth(2026, 1)).build(),
    BillTemplateBuilder().withId(2).withName('ZUS').inCategory(BillCategory.company).startingAt(YearMonth(2026, 1)).build(),
  ],
  entries: entries,
);

Future<void> _pump(WidgetTester tester, {InMemoryBillsRepository? bills, Locale locale = const Locale('pl')}) async {
  await pumpApp(tester, const BillsPage(), bills: bills ?? _repository(), locale: locale);
  await tester.pumpAndSettle();
}

bool _checked(WidgetTester tester, YearMonth month, int id) =>
    tester.widget<AppCheckbox>(find.ancestor(of: byId(TestIds.billsRowCheckbox(month.key, id)), matching: find.byType(AppCheckbox))).value;

void main() {
  testWidgets('shows the header with the current month and the templates button', (tester) async {
    await _pump(tester);

    expect(byId(TestIds.billsPage), findsOneWidget);
    expect(textOf(tester, TestIds.billsTitle), 'Rachunki');
    expect(textOf(tester, TestIds.billsTemplatesButton), 'Szablony');
    expect(textOf(tester, TestIds.billsMonthLabel), 'Listopad 2026');
    expect(byId(TestIds.billsPreviousMonth), findsOneWidget);
    expect(byId(TestIds.billsNextMonth), findsOneWidget);
    expect(byId(TestIds.billsPreviousMonthIcon), findsOneWidget);
    expect(byId(TestIds.billsNextMonthIcon), findsOneWidget);
    expect(byId(TestIds.billsPager), findsOneWidget);
    expect(byId(TestIds.billsMonth(_nov.key)), findsOneWidget);
  });

  testWidgets('shows the month in English for the en locale', (tester) async {
    await _pump(tester, locale: const Locale('en'));

    expect(textOf(tester, TestIds.billsTitle), 'Bills');
    expect(textOf(tester, TestIds.billsTemplatesButton), 'Templates');
    expect(textOf(tester, TestIds.billsMonthLabel), 'November 2026');
    expect(textOf(tester, TestIds.billsSectionTitle(_nov.key, _personal)), 'Personal');
    expect(textOf(tester, TestIds.billsSectionTitle(_nov.key, _company)), 'Company');
  });

  testWidgets('lists the bills in Personal and Company sections', (tester) async {
    await _pump(tester);

    expect(byId(TestIds.billsSection(_nov.key, _personal)), findsOneWidget);
    expect(byId(TestIds.billsSection(_nov.key, _company)), findsOneWidget);
    expect(textOf(tester, TestIds.billsSectionTitle(_nov.key, _personal)), 'Osobiste');
    expect(textOf(tester, TestIds.billsSectionTitle(_nov.key, _company)), 'Firmowe');
    expect(byId(TestIds.billsRow(_nov.key, 1)), findsOneWidget);
    expect(textOf(tester, TestIds.billsRowName(_nov.key, 1)), 'Czynsz');
    expect(textOf(tester, TestIds.billsRowName(_nov.key, 2)), 'ZUS');
    expect(
      find.descendant(of: byId(TestIds.billsSection(_nov.key, _company)), matching: byId(TestIds.billsRow(_nov.key, 2))),
      findsOneWidget,
    );
    expect(_checked(tester, _nov, 1), isFalse);
  });

  testWidgets('shows an empty message in sections without bills', (tester) async {
    await _pump(tester, bills: InMemoryBillsRepository());

    expect(textOf(tester, TestIds.billsSectionEmpty(_nov.key, _personal)), 'Brak rachunków. Dodaj szablon.');
    expect(byId(TestIds.billsSectionEmpty(_nov.key, _company)), findsOneWidget);
  });

  testWidgets('tapping the checkbox marks the bill paid and persists it', (tester) async {
    final repository = _repository();
    await _pump(tester, bills: repository);

    await tester.tap(byId(TestIds.billsRowCheckbox(_nov.key, 1)));
    await tester.pumpAndSettle();

    expect(_checked(tester, _nov, 1), isTrue);
    expect(repository.paidIn(_nov), {1});
    final name = textWidget(tester, TestIds.billsRowName(_nov.key, 1));
    expect(name.style?.decoration, TextDecoration.lineThrough);
    expect(name.style?.color, AppColors.textMuted);

    await tester.tap(byId(TestIds.billsRow(_nov.key, 1)));
    await tester.pumpAndSettle();
    expect(_checked(tester, _nov, 1), isFalse);
    expect(repository.paidIn(_nov), isEmpty);
  });

  testWidgets('the previous / next buttons change the month', (tester) async {
    await _pump(tester);

    await tester.tap(byId(TestIds.billsPreviousMonth));
    await tester.pumpAndSettle();
    expect(textOf(tester, TestIds.billsMonthLabel), 'Październik 2026');
    expect(byId(TestIds.billsMonth(_oct.key)), findsOneWidget);

    await tester.tap(byId(TestIds.billsNextMonth));
    await tester.pumpAndSettle();
    await tester.tap(byId(TestIds.billsNextMonth));
    await tester.pumpAndSettle();
    expect(textOf(tester, TestIds.billsMonthLabel), 'Grudzień 2026');
  });

  testWidgets('swiping right shows the previous month, swiping left the next one', (tester) async {
    await _pump(tester);

    await tester.fling(byId(TestIds.billsPager), const Offset(400, 0), 1000);
    await tester.pumpAndSettle();
    expect(textOf(tester, TestIds.billsMonthLabel), 'Październik 2026');

    await tester.fling(byId(TestIds.billsPager), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    await tester.fling(byId(TestIds.billsPager), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(textOf(tester, TestIds.billsMonthLabel), 'Grudzień 2026');
  });

  testWidgets('stops 12 months back and 12 months ahead', (tester) async {
    await _pump(tester);

    for (var i = 0; i < 12; i++) {
      await tester.tap(byId(TestIds.billsPreviousMonth));
      await tester.pumpAndSettle();
    }
    expect(textOf(tester, TestIds.billsMonthLabel), 'Listopad 2025');
    expect(
      tester.widget<TextButton>(find.descendant(of: byId(TestIds.billsPreviousMonth), matching: find.byType(TextButton))).onPressed,
      isNull,
    );

    for (var i = 0; i < 24; i++) {
      await tester.tap(byId(TestIds.billsNextMonth));
      await tester.pumpAndSettle();
    }
    expect(textOf(tester, TestIds.billsMonthLabel), 'Listopad 2027');
    expect(
      tester.widget<TextButton>(find.descendant(of: byId(TestIds.billsNextMonth), matching: find.byType(TextButton))).onPressed,
      isNull,
    );
  });

  testWidgets('unpaid bills of past months are highlighted as overdue', (tester) async {
    await _pump(
      tester,
      bills: _repository(entries: {(2, _oct): BillEntry(paidAt: DateTime.utc(2026, 10, 10))}),
    );

    await tester.tap(byId(TestIds.billsPreviousMonth));
    await tester.pumpAndSettle();

    expect(textWidget(tester, TestIds.billsRowName(_oct.key, 1)).style?.color, AppColors.danger);
    expect(textWidget(tester, TestIds.billsRowName(_oct.key, 2)).style?.color, AppColors.textMuted);
  });

  testWidgets('the current month bills are not overdue', (tester) async {
    await _pump(tester);
    expect(textWidget(tester, TestIds.billsRowName(_nov.key, 1)).style?.color, AppColors.text);
  });

  testWidgets('the templates button opens the templates page', (tester) async {
    await _pump(tester);

    await tester.tap(byId(TestIds.billsTemplatesButton));
    await tester.pumpAndSettle();

    expect(byId(TestIds.billTemplatesPage), findsOneWidget);
  });

  testWidgets('a bill with a due date that passed is overdue, on the due day it is not', (tester) async {
    await _pump(
      tester,
      bills: _repository(
        entries: {
          (1, _nov): BillEntry(dueDate: CalendarDate(2026, 11, 5)),
          (2, _nov): BillEntry(dueDate: CalendarDate(2026, 11, 6)),
        },
      ),
    );

    expect(textWidget(tester, TestIds.billsRowName(_nov.key, 1)).style?.color, AppColors.danger);
    expect(textWidget(tester, TestIds.billsRowName(_nov.key, 2)).style?.color, AppColors.text);
  });

  testWidgets('shows the due date and the payment date under the bill name', (tester) async {
    await _pump(
      tester,
      bills: _repository(entries: {(1, _nov): BillEntry(dueDate: CalendarDate(2026, 11, 20))}),
    );

    expect(textOf(tester, TestIds.billsRowDetails(_nov.key, 1)), 'Termin: 20.11.2026');
    expect(byId(TestIds.billsRowDetails(_nov.key, 2)), findsNothing);

    await tester.tap(byId(TestIds.billsRowCheckbox(_nov.key, 1)));
    await tester.pumpAndSettle();
    expect(textOf(tester, TestIds.billsRowDetails(_nov.key, 1)), 'Termin: 20.11.2026 · Zapłacono: 6.11.2026');

    await tester.tap(byId(TestIds.billsRowCheckbox(_nov.key, 2)));
    await tester.pumpAndSettle();
    expect(textOf(tester, TestIds.billsRowDetails(_nov.key, 2)), 'Zapłacono: 6.11.2026');
  });

  testWidgets('the due date button on the right sets the due date with a date picker', (tester) async {
    final repository = _repository();
    await _pump(tester, bills: repository);
    expect(byId(TestIds.billsRowDueDateIcon(_nov.key, 1)), findsOneWidget);

    await tester.tap(byId(TestIds.billsRowDueDate(_nov.key, 1)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('20'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(repository.entryOf(1, _nov).dueDate, CalendarDate(2026, 11, 20));
    expect(textOf(tester, TestIds.billsRowDetails(_nov.key, 1)), 'Termin: 20.11.2026');
  });

  testWidgets('cancelling the date picker keeps the due date', (tester) async {
    final repository = _repository(entries: {(1, _nov): BillEntry(dueDate: CalendarDate(2026, 11, 20))});
    await _pump(tester, bills: repository);

    await tester.tap(byId(TestIds.billsRowDueDate(_nov.key, 1)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Anuluj'));
    await tester.pumpAndSettle();

    expect(repository.entryOf(1, _nov).dueDate, CalendarDate(2026, 11, 20));
  });
}
