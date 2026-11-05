import 'package:paydo/features/settings/domain/app_language.dart';
import 'package:paydo/features/settings/domain/settings_repository.dart';

final class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository({this.language});

  AppLanguage? language;
  int saveCount = 0;

  @override
  Future<AppLanguage?> loadLanguage() async => language;

  @override
  Future<void> saveLanguage(AppLanguage language) async {
    this.language = language;
    saveCount++;
  }
}
