import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/features/bills/domain/bill.dart';
import 'package:paydo/features/bills/domain/calendar_date.dart';
import 'package:paydo/features/bills/domain/year_month.dart';

import '../../../support/builders/bill_template_builder.dart';

void main() {
  final today = CalendarDate(2026, 11, 6);
  final paidAt = DateTime.utc(2026, 11, 5, 12);
  Bill bill(YearMonth month, {CalendarDate? due, DateTime? paidAt}) => Bill(
    template: BillTemplateBuilder().build(),
    month: month,
    entry: BillEntry(dueDate: due, paidAt: paidAt),
  );

  group('statusAt()', () {
    test('a paid bill is paid regardless of dates', () {
      expect(bill(YearMonth(2026, 1), paidAt: paidAt).statusAt(today), BillStatus.paid);
      expect(bill(YearMonth(2026, 1), due: CalendarDate(2026, 1, 1), paidAt: paidAt).statusAt(today), BillStatus.paid);
    });

    test('with a due date: due on the due day, overdue only from the next day', () {
      final b = bill(YearMonth(2026, 9), due: CalendarDate(2026, 9, 20));
      expect(b.statusAt(CalendarDate(2026, 9, 19)), BillStatus.due);
      expect(b.statusAt(CalendarDate(2026, 9, 20)), BillStatus.due);
      expect(b.statusAt(CalendarDate(2026, 9, 21)), BillStatus.overdue);
    });

    test('a due date after the month end keeps a past-month bill due', () {
      expect(bill(YearMonth(2026, 10), due: CalendarDate(2026, 11, 10)).statusAt(today), BillStatus.due);
    });

    test('without a due date: overdue once the month has passed', () {
      expect(bill(YearMonth(2026, 10)).statusAt(today), BillStatus.overdue);
      expect(bill(YearMonth(2026, 11)).statusAt(today), BillStatus.due);
      expect(bill(YearMonth(2026, 12)).statusAt(today), BillStatus.due);
    });
  });

  test('markedPaid() / markedUnpaid() keep the due date', () {
    final due = CalendarDate(2026, 11, 20);
    final b = bill(YearMonth(2026, 11), due: due);

    final paid = b.markedPaid(paidAt);
    expect(paid.paid, isTrue);
    expect(paid.paidAt, paidAt);
    expect(paid.dueDate, due);

    final unpaid = paid.markedUnpaid();
    expect(unpaid.paid, isFalse);
    expect(unpaid, b);
  });

  test('withDueDate() sets and clears the due date, keeping the payment', () {
    final b = bill(YearMonth(2026, 11), paidAt: paidAt);
    expect(b.withDueDate(CalendarDate(2026, 11, 20)).dueDate, CalendarDate(2026, 11, 20));
    expect(b.withDueDate(CalendarDate(2026, 11, 20)).paidAt, paidAt);
    expect(b.withDueDate(CalendarDate(2026, 11, 20)).withDueDate(null), b);
  });

  test('dueDate falls back to the template due day; its own due date wins', () {
    final template = BillTemplateBuilder().withDueDay(10).build();
    final month = YearMonth(2026, 11);
    expect(Bill(template: template, month: month).dueDate, CalendarDate(2026, 11, 10));
    expect(
      Bill(
        template: template,
        month: month,
        entry: BillEntry(dueDate: CalendarDate(2026, 11, 20)),
      ).dueDate,
      CalendarDate(2026, 11, 20),
    );
    expect(Bill(template: template, month: month).statusAt(CalendarDate(2026, 11, 11)), BillStatus.overdue);
  });
}
