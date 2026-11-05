import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/generated/app_localizations.dart';
import 'core/testing/test_id.dart';
import 'core/testing/test_ids.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation/presentation/app_shell.dart';
import 'features/settings/application/language_state.dart';
import 'features/settings/domain/app_language.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageAsync = ref.watch(languageState);
    final language = languageAsync.value ?? (languageAsync.hasError ? AppLanguage.fallback : null);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemOverlayStyle,
      child: language == null
          ? const ColoredBox(color: AppColors.background, child: SizedBox.expand()).testId(TestIds.appLoading)
          : MaterialApp(
              title: 'PayDo',
              theme: buildAppTheme(),
              themeMode: ThemeMode.dark,
              debugShowCheckedModeBanner: false,
              locale: Locale(language.code),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const AppShell(),
            ),
    );
  }
}
