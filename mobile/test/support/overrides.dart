import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:paydo/features/settings/application/settings_providers.dart';

import 'fakes/in_memory_settings_repository.dart';

List<Override> settingsOverrides(InMemorySettingsRepository repository) => [settingsRepositoryProvider.overrideWith((ref) => repository)];
