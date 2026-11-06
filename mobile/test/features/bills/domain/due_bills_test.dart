import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/features/bills/domain/bill.dart';
import 'package:paydo/features/bills/domain/calendar_date.dart';
import 'package:paydo/features/bills/domain/due_bills.dart';
import 'package:paydo/features/bills/domain/year_month.dart';

import '../../../support/builders/bill_template_builder.dart';

void main() {
  final sep = YearMonth(2026, 9);
  final oct = YearMonth(2026, 10);
  final nov = YearMonth(2026, 11);
  final paid = DateTime.utc(2026, 10, 1);

  test('collects unpaid bills of each month that have a template or own due date', () {
    final rent = BillTemplateBuilder().withId(1).withDueDay(10).startingAt(sep).build();
    final gas = BillTemplateBuilder().withId(2).startingAt(sep).build();
    final late = BillTemplateBuilder().withId(3).withDueDay(5).startingAt(nov).build();

    final bills = unpaidBillsWithDueDate(
      templates: [rent, gas, late],
      entries: {
        (1, sep): BillEntry(paidAt: paid),
        (2, oct): BillEntry(dueDate: CalendarDate(2026, 10, 15)),
      },
      from: sep,
      to: nov,
    );

    expect(
      bills,
      unorderedEquals([
        Bill(template: rent, month: oct),
        Bill(template: rent, month: nov),
        Bill(
          template: gas,
          month: oct,
          entry: BillEntry(dueDate: CalendarDate(2026, 10, 15)),
        ),
        Bill(template: late, month: nov),
      ]),
    );
  });

  test('skips months where the template is not active', () {
    final archived = BillTemplateBuilder().withId(1).withDueDay(10).startingAt(sep).endingAt(oct).build();
    final bills = unpaidBillsWithDueDate(templates: [archived], entries: const {}, from: YearMonth(2026, 1), to: nov);
    expect(bills.map((b) => b.month), [sep]);
  });
}
