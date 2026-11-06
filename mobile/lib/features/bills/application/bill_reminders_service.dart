import '../domain/bills_repository.dart';
import '../domain/due_bills.dart';
import '../domain/reminders/notification_scheduler.dart';
import '../domain/reminders/reminder_planner.dart';
import '../domain/year_month.dart';

abstract interface class ReminderMessages {
  String title(BillReminder reminder);

  String body(BillReminder reminder);
}

final class BillRemindersService {
  const BillRemindersService({
    required BillsRepository repository,
    required NotificationScheduler scheduler,
    required ReminderPlanner planner,
    required ReminderMessages messages,
    required DateTime Function() now,
  }) : _repository = repository,
       _scheduler = scheduler,
       _planner = planner,
       _messages = messages,
       _now = now;

  final BillsRepository _repository;
  final NotificationScheduler _scheduler;
  final ReminderPlanner _planner;
  final ReminderMessages _messages;
  final DateTime Function() _now;

  /// Bills older than [monthsBack] months are not reminded about.
  static const monthsBack = 12;

  Future<List<ScheduledNotification>> reschedule() async {
    final now = _now();
    final current = YearMonth.fromDate(now);
    final from = current.addMonths(-monthsBack);
    final to = current.addMonths(1);
    final bills = unpaidBillsWithDueDate(
      templates: await _repository.templates(),
      entries: await _repository.entriesBetween(from, to),
      from: from,
      to: to,
    );
    final notifications = [
      for (final (i, r) in _planner.plan(bills, now).indexed)
        ScheduledNotification(id: i, at: r.at, title: _messages.title(r), body: _messages.body(r)),
    ];
    await _scheduler.replaceAll(notifications);
    return notifications;
  }
}
