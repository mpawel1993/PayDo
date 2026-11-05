import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/testing/test_id.dart';
import '../../../core/testing/test_ids.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_page.dart';
import '../application/language_state.dart';
import '../domain/app_language.dart';

extension on AppLanguage {
  String label(AppLocalizations l10n) => switch (this) {
    AppLanguage.pl => l10n.languagePolish,
    AppLanguage.en => l10n.languageEnglish,
  };

  String get optionId => switch (this) {
    AppLanguage.pl => TestIds.settingsLanguageOptionPl,
    AppLanguage.en => TestIds.settingsLanguageOptionEn,
  };
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppPage(
      id: TestIds.settingsPage,
      titleId: TestIds.settingsTitle,
      title: l10n.navSettings,
      children: [
        Text(
          l10n.settingsLanguage,
          style: const TextStyle(color: AppColors.textMuted, fontSize: AppFontSize.base, fontWeight: FontWeight.w500),
        ).testId(TestIds.settingsLanguageLabel),
        RadioGroup<AppLanguage>(
          groupValue: ref.watch(languageState).value,
          onChanged: (language) {
            if (language != null) ref.read(languageState.notifier).setLanguage(language);
          },
          child: Column(
            spacing: AppSpacing.xs,
            children: [
              for (final language in AppLanguage.values)
                RadioListTile<AppLanguage>(value: language, title: Text(language.label(l10n))).testId(language.optionId),
            ],
          ),
        ).testId(TestIds.settingsLanguageOptions),
      ],
    );
  }
}
