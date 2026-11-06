final class ScheduledNotification {
  const ScheduledNotification({required this.id, required this.at, required this.title, required this.body});

  final int id;

  /// Local date-time.
  final DateTime at;
  final String title;
  final String body;

  @override
  bool operator ==(Object other) =>
      other is ScheduledNotification && other.id == id && other.at == at && other.title == title && other.body == body;

  @override
  int get hashCode => Object.hash(id, at, title, body);

  @override
  String toString() => 'ScheduledNotification($id, $at, $title, $body)';
}

abstract interface class NotificationScheduler {
  /// Cancels every previously scheduled notification and schedules [notifications].
  Future<void> replaceAll(List<ScheduledNotification> notifications);
}
