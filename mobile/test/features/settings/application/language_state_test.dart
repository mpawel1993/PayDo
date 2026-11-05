import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/features/settings/application/language_state.dart';
import 'package:paydo/features/settings/domain/app_language.dart';

import '../../../support/fakes/in_memory_settings_repository.dart';
import '../../../support/overrides.dart';

ProviderContainer _container(InMemorySettingsRepository repository) {
  final container = ProviderContainer(overrides: settingsOverrides(repository));
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('loads the fallback language when nothing is saved', () async {
    final container = _container(InMemorySettingsRepository());
    expect(await container.read(languageState.future), AppLanguage.fallback);
  });

  test('loads the saved language', () async {
    final container = _container(InMemorySettingsRepository(language: AppLanguage.en));
    expect(await container.read(languageState.future), AppLanguage.en);
  });

  test('setLanguage() updates the state and persists it', () async {
    final repository = InMemorySettingsRepository();
    final container = _container(repository);
    await container.read(languageState.future);

    await container.read(languageState.notifier).setLanguage(AppLanguage.en);

    expect(container.read(languageState).value, AppLanguage.en);
    expect(repository.language, AppLanguage.en);
  });

  test('setLanguage() with the current language does not write again', () async {
    final repository = InMemorySettingsRepository(language: AppLanguage.pl);
    final container = _container(repository);
    await container.read(languageState.future);

    await container.read(languageState.notifier).setLanguage(AppLanguage.pl);

    expect(repository.saveCount, 0);
  });
}
