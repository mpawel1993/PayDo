import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/features/bills/application/bill_reminders_service.dart';
import 'package:paydo/features/bills/domain/bill.dart';
import 'package:paydo/features/bills/domain/calendar_date.dart';
import 'package:paydo/features/bills/domain/reminders/notification_scheduler.dart';
import 'package:paydo/features/bills/domain/reminders/reminder_planner.dart';
import 'package:paydo/features/bills/domain/year_month.dart';

import '../../../support/builders/bill_template_builder.dart';
import '../../../support/fakes/in_memory_bills_repository.dart';
import '../../../support/fakes/recording_notification_scheduler.dart';

final class _FixedTime implements ReminderTimeStrategy {
  @override
  int minuteOfDay(Bill bill, CalendarDate day) => 12 * 60;
}

final class _Messages implements ReminderMessages {
  @override
  String title(BillReminder reminder) => 'Unpaid';

  @override
  String body(BillReminder reminder) => '${reminder.bill.template.name} ${reminder.bill.dueDate}';
}

void main() {
  final sep = YearMonth(2026, 9);
  final due = CalendarDate(2026, 9, 20);

  BillRemindersService service(InMemoryBillsRepository repository, RecordingNotificationScheduler scheduler, DateTime now) =>
      BillRemindersService(
        repository: repository,
        scheduler: scheduler,
        planner: ReminderPlanner(timeStrategy: _FixedTime(), horizonDays: 2),
        messages: _Messages(),
        now: () => now,
      );

  test('schedules the planned reminders of unpaid overdue bills with sequential ids', () async {
    final rent = BillTemplateBuilder().withId(1).withName('Rent').startingAt(sep).build();
    final gas = BillTemplateBuilder().withId(2).withName('Gas').startingAt(sep).build();
    final repository = InMemoryBillsRepository(
      templates: [rent, gas],
      entries: {
        (1, sep): BillEntry(dueDate: due),
        (2, sep): BillEntry(dueDate: due, paidAt: DateTime.utc(2026, 9, 19)),
      },
    );
    final scheduler = RecordingNotificationScheduler();

    final result = await service(repository, scheduler, DateTime(2026, 9, 20, 8)).reschedule();

    final expected = [
      ScheduledNotification(id: 0, at: DateTime(2026, 9, 21, 9), title: 'Unpaid', body: 'Rent $due'),
      ScheduledNotification(id: 1, at: DateTime(2026, 9, 22, 12), title: 'Unpaid', body: 'Rent $due'),
    ];
    expect(scheduler.scheduled, expected);
    expect(result, expected);
  });

  test('replaces everything with nothing once all bills are paid', () async {
    final repository = InMemoryBillsRepository(
      templates: [BillTemplateBuilder().withId(1).startingAt(sep).build()],
      entries: {(1, sep): BillEntry(dueDate: due, paidAt: DateTime.utc(2026, 9, 25))},
    );
    final scheduler = RecordingNotificationScheduler()..scheduled = [ScheduledNotification(id: 0, at: DateTime(2026), title: '', body: '')];

    await service(repository, scheduler, DateTime(2026, 9, 26)).reschedule();

    expect(scheduler.calls, 1);
    expect(scheduler.scheduled, isEmpty);
  });

  test('uses the template due day for months without their own due date', () async {
    final repository = InMemoryBillsRepository(
      templates: [BillTemplateBuilder().withId(1).withName('Rent').withDueDay(20).startingAt(sep).build()],
    );
    final scheduler = RecordingNotificationScheduler();

    await service(repository, scheduler, DateTime(2026, 9, 20, 8)).reschedule();

    expect(scheduler.scheduled.map((n) => n.at), [DateTime(2026, 9, 21, 9), DateTime(2026, 9, 22, 12)]);
  });

  test('ignores bills older than 12 months', () async {
    final repository = InMemoryBillsRepository(
      templates: [BillTemplateBuilder().withId(1).withDueDay(20).startingAt(YearMonth(2024, 1)).build()],
      entries: {
        for (var m = YearMonth(2025, 9); !m.isAfter(YearMonth(2026, 10)); m = m.addMonths(1)) (1, m): BillEntry(paidAt: DateTime.utc(2026)),
      },
    );
    final scheduler = RecordingNotificationScheduler();

    await service(repository, scheduler, DateTime(2026, 9, 25)).reschedule();

    expect(scheduler.scheduled, isEmpty);
  });
}
