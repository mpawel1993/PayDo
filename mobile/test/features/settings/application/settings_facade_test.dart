import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/features/settings/application/settings_facade.dart';
import 'package:paydo/features/settings/domain/app_language.dart';

import '../../../support/fakes/in_memory_settings_repository.dart';

void main() {
  test('language() returns the fallback when nothing is saved', () async {
    expect(await SettingsFacade(InMemorySettingsRepository()).language(), AppLanguage.fallback);
  });

  test('language() returns the saved language', () async {
    expect(await SettingsFacade(InMemorySettingsRepository(language: AppLanguage.en)).language(), AppLanguage.en);
  });

  test('changeLanguage() persists through the repository', () async {
    final repository = InMemorySettingsRepository();
    await SettingsFacade(repository).changeLanguage(AppLanguage.en);

    expect(repository.language, AppLanguage.en);
    expect(repository.saveCount, 1);
  });
}
