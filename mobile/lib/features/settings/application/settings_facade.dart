import '../domain/app_language.dart';
import '../domain/settings_repository.dart';

final class SettingsFacade {
  const SettingsFacade(this._repository);

  final SettingsRepository _repository;

  Future<AppLanguage> language() async => await _repository.loadLanguage() ?? AppLanguage.fallback;

  Future<void> changeLanguage(AppLanguage language) => _repository.saveLanguage(language);
}
