import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/db_providers.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/state/clock_state.dart';
import '../../settings/application/language_state.dart';
import '../../settings/domain/app_language.dart';
import '../data/notifications/local_notification_scheduler.dart';
import '../data/notifications/noop_notification_scheduler.dart';
import '../data/sqlite_bills_repository.dart';
import '../domain/bills_repository.dart';
import '../domain/reminders/notification_scheduler.dart';
import '../domain/reminders/reminder_planner.dart';
import 'bill_reminders_service.dart';
import 'bills_facade.dart';
import 'l10n_reminder_messages.dart';

final billsRepositoryProvider = FutureProvider<BillsRepository>(
  (ref) async => SqliteBillsRepository(await ref.watch(appDatabaseProvider.future), now: ref.watch(clockState)),
);

final billsFacadeProvider = FutureProvider<BillsFacade>(
  (ref) async => BillsFacade(await ref.watch(billsRepositoryProvider.future), ref.watch(clockState)),
);

final notificationSchedulerProvider = Provider<NotificationScheduler>(
  (ref) => kIsWeb
      ? const NoopNotificationScheduler()
      : LocalNotificationScheduler(
          channelName: lookupAppLocalizations(Locale((ref.watch(languageState).value ?? AppLanguage.fallback).code)).reminderChannelName,
        ),
);

/// iOS keeps at most 64 pending notifications.
final reminderPlannerProvider = Provider<ReminderPlanner>(
  (ref) => ReminderPlanner(maxReminders: defaultTargetPlatform == TargetPlatform.iOS ? 60 : 400),
);

final billRemindersServiceProvider = FutureProvider<BillRemindersService>((ref) async {
  final language = await ref.watch(languageState.future);
  return BillRemindersService(
    repository: await ref.watch(billsRepositoryProvider.future),
    scheduler: ref.watch(notificationSchedulerProvider),
    planner: ref.watch(reminderPlannerProvider),
    messages: L10nReminderMessages(lookupAppLocalizations(Locale(language.code))),
    now: ref.watch(clockState),
  );
});
