import 'package:paydo/features/bills/domain/reminders/notification_scheduler.dart';

final class RecordingNotificationScheduler implements NotificationScheduler {
  List<ScheduledNotification> scheduled = const [];
  int calls = 0;

  @override
  Future<void> replaceAll(List<ScheduledNotification> notifications) async {
    scheduled = [...notifications];
    calls++;
  }
}
