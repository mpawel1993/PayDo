import 'dart:math';

import 'package:collection/collection.dart';

import '../bill.dart';
import '../calendar_date.dart';

/// STRATEGY: picks the minute of the day at which a repeated reminder is sent.
abstract interface class ReminderTimeStrategy {
  int minuteOfDay(Bill bill, CalendarDate day);
}

/// Pseudo-random minute in [startMinute, endMinute), stable for the same bill and day so re-planning never moves a reminder.
final class SeededRandomReminderTime implements ReminderTimeStrategy {
  const SeededRandomReminderTime({this.startMinute = 9 * 60, this.endMinute = 21 * 60});

  final int startMinute;
  final int endMinute;

  @override
  int minuteOfDay(Bill bill, CalendarDate day) {
    final seed = (bill.template.id * 1000003 + bill.month.key * 1009 + day.toUtcMillis() ~/ Duration.millisecondsPerDay) & 0x7fffffff;
    return startMinute + Random(seed).nextInt(endMinute - startMinute);
  }
}

final class BillReminder {
  const BillReminder({required this.bill, required this.at});

  final Bill bill;

  /// Local date-time of the notification.
  final DateTime at;

  @override
  bool operator ==(Object other) => other is BillReminder && other.bill == bill && other.at == at;

  @override
  int get hashCode => Object.hash(bill, at);

  @override
  String toString() => 'BillReminder(${bill.template.id}, ${bill.month}, $at)';
}

/// Plans overdue reminders: the first on the day after the due date at [firstReminderMinute],
/// then one per day at a moment chosen by [timeStrategy], until the bill is paid.
final class ReminderPlanner {
  const ReminderPlanner({
    this.timeStrategy = const SeededRandomReminderTime(),
    this.firstReminderMinute = 9 * 60,
    this.horizonDays = 30,
    this.maxReminders = 400,
  });

  final ReminderTimeStrategy timeStrategy;
  final int firstReminderMinute;

  /// Reminders are planned up to this many days after today; re-planning (e.g. on app start) extends the horizon.
  final int horizonDays;

  /// Platform limit of pending notifications; the earliest reminders are kept.
  final int maxReminders;

  List<BillReminder> plan(Iterable<Bill> bills, DateTime now) {
    final lastDay = CalendarDate.fromDateTime(now).addDays(horizonDays);
    final reminders = [
      for (final bill in bills)
        if (bill.dueDate case final due? when !bill.paid)
          for (var day = due.addDays(1); !day.isAfter(lastDay); day = day.addDays(1))
            if (day.atMinute(day == due.addDays(1) ? firstReminderMinute : timeStrategy.minuteOfDay(bill, day)) case final at
                when at.isAfter(now))
              BillReminder(bill: bill, at: at),
    ];
    mergeSort(reminders, compare: (a, b) => a.at.compareTo(b.at));
    return reminders.take(maxReminders).toList();
  }
}
