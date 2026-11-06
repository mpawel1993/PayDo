import '../../domain/reminders/notification_scheduler.dart';

/// Web preview has no local notifications.
final class NoopNotificationScheduler implements NotificationScheduler {
  const NoopNotificationScheduler();

  @override
  Future<void> replaceAll(List<ScheduledNotification> notifications) async {}
}
