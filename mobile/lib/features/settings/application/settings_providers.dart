import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/db_providers.dart';
import '../data/sqlite_settings_repository.dart';
import '../domain/settings_repository.dart';
import 'settings_facade.dart';

final settingsRepositoryProvider = FutureProvider<SettingsRepository>(
  (ref) async => SqliteSettingsRepository(await ref.watch(appDatabaseProvider.future)),
);

final settingsFacadeProvider = FutureProvider<SettingsFacade>(
  (ref) async => SettingsFacade(await ref.watch(settingsRepositoryProvider.future)),
);
