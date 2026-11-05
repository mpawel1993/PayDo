import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/app_language.dart';
import 'settings_providers.dart';

final languageState = AsyncNotifierProvider<LanguageNotifier, AppLanguage>(LanguageNotifier.new);

class LanguageNotifier extends AsyncNotifier<AppLanguage> {
  @override
  Future<AppLanguage> build() async => (await ref.watch(settingsFacadeProvider.future)).language();

  Future<void> setLanguage(AppLanguage language) async {
    if (state.value == language) return;
    await (await ref.read(settingsFacadeProvider.future)).changeLanguage(language);
    state = AsyncData(language);
  }
}
