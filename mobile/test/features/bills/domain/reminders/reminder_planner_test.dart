import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/features/bills/domain/bill.dart';
import 'package:paydo/features/bills/domain/calendar_date.dart';
import 'package:paydo/features/bills/domain/reminders/reminder_planner.dart';
import 'package:paydo/features/bills/domain/year_month.dart';

import '../../../../support/builders/bill_template_builder.dart';

final class _FixedTime implements ReminderTimeStrategy {
  const _FixedTime(this.minute);

  final int minute;

  @override
  int minuteOfDay(Bill bill, CalendarDate day) => minute;
}

Bill _bill({int id = 1, CalendarDate? due, DateTime? paidAt}) => Bill(
  template: BillTemplateBuilder().withId(id).build(),
  month: YearMonth(2026, 9),
  entry: BillEntry(dueDate: due, paidAt: paidAt),
);

void main() {
  const planner = ReminderPlanner(timeStrategy: _FixedTime(15 * 60), horizonDays: 3);
  final due = CalendarDate(2026, 9, 20);

  test('nothing is planned for paid bills or bills without a due date', () {
    final bills = [_bill(due: due, paidAt: DateTime.utc(2026, 9, 19)), _bill(id: 2)];
    expect(planner.plan(bills, DateTime(2026, 9, 1)), isEmpty);
  });

  test('first reminder on the day after the due date at 9:00, then daily at the strategy time until the horizon', () {
    final bill = _bill(due: due);
    final reminders = planner.plan([bill], DateTime(2026, 9, 20, 12));

    expect(reminders, [
      BillReminder(bill: bill, at: DateTime(2026, 9, 21, 9)),
      BillReminder(bill: bill, at: DateTime(2026, 9, 22, 15)),
      BillReminder(bill: bill, at: DateTime(2026, 9, 23, 15)),
    ]);
  });

  test('nothing is sent on the due day itself', () {
    final reminders = planner.plan([_bill(due: due)], DateTime(2026, 9, 1));
    expect(reminders.every((r) => CalendarDate.fromDateTime(r.at).isAfter(due)), isTrue);
  });

  test('skips moments that already passed and keeps reminding while unpaid', () {
    final bill = _bill(due: due);
    final reminders = planner.plan([bill], DateTime(2026, 10, 5, 16));

    expect(reminders.map((r) => r.at), [DateTime(2026, 10, 6, 15), DateTime(2026, 10, 7, 15), DateTime(2026, 10, 8, 15)]);
  });

  test('a reminder later today is still planned', () {
    final reminders = planner.plan([_bill(due: due)], DateTime(2026, 9, 25, 10));
    expect(reminders.first.at, DateTime(2026, 9, 25, 15));
  });

  test('merges bills by time and keeps only the earliest maxReminders', () {
    const capped = ReminderPlanner(timeStrategy: _FixedTime(15 * 60), horizonDays: 3, maxReminders: 3);
    final a = _bill(id: 1, due: due);
    final b = _bill(id: 2, due: CalendarDate(2026, 9, 21));

    final reminders = capped.plan([a, b], DateTime(2026, 9, 20, 12));

    expect(reminders, [
      BillReminder(bill: a, at: DateTime(2026, 9, 21, 9)),
      BillReminder(bill: b, at: DateTime(2026, 9, 22, 9)),
      BillReminder(bill: a, at: DateTime(2026, 9, 22, 15)),
    ]);
  });

  group('SeededRandomReminderTime', () {
    const strategy = SeededRandomReminderTime();

    test('stays within the window and is stable for the same bill and day', () {
      final bill = _bill(due: due);
      for (var d = 0; d < 60; d++) {
        final day = due.addDays(d);
        final minute = strategy.minuteOfDay(bill, day);
        expect(minute, inInclusiveRange(9 * 60, 21 * 60 - 1));
        expect(strategy.minuteOfDay(bill, day), minute);
      }
    });

    test('varies between days', () {
      final bill = _bill(due: due);
      final minutes = {for (var d = 0; d < 30; d++) strategy.minuteOfDay(bill, due.addDays(d))};
      expect(minutes.length, greaterThan(10));
    });
  });
}
