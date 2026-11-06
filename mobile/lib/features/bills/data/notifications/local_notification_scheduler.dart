import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/reminders/notification_scheduler.dart';

/// ADAPTER: flutter_local_notifications -> NotificationScheduler.
final class LocalNotificationScheduler implements NotificationScheduler {
  LocalNotificationScheduler({required this.channelName, FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const channelId = 'bill_reminders';

  final String channelName;
  final FlutterLocalNotificationsPlugin _plugin;
  static Future<void>? _initialization;

  Future<void> _initialize() => _initialization ??= () async {
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation((await FlutterTimezone.getLocalTimezone()).identifier));
    } on Object {
      tz.setLocalLocation(tz.UTC);
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }();

  @override
  Future<void> replaceAll(List<ScheduledNotification> notifications) async {
    await _initialize();
    await _plugin.cancelAll();
    final details = NotificationDetails(
      android: AndroidNotificationDetails(channelId, channelName, importance: Importance.high, priority: Priority.high),
      iOS: const DarwinNotificationDetails(),
    );
    for (final n in notifications) {
      await _plugin.zonedSchedule(
        id: n.id,
        title: n.title,
        body: n.body,
        scheduledDate: tz.TZDateTime.from(n.at, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
