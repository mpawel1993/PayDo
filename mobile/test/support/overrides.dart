import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:paydo/core/state/clock_state.dart';
import 'package:paydo/features/bills/application/bills_providers.dart';
import 'package:paydo/features/settings/application/settings_providers.dart';

import 'fakes/in_memory_bills_repository.dart';
import 'fakes/in_memory_settings_repository.dart';

List<Override> settingsOverrides(InMemorySettingsRepository repository) => [settingsRepositoryProvider.overrideWith((ref) => repository)];

List<Override> billsOverrides(InMemoryBillsRepository repository) => [billsRepositoryProvider.overrideWith((ref) => repository)];

Override clockOverride(DateTime now) => clockState.overrideWithValue(() => now);
