import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/app.dart';
import 'package:paydo/core/testing/test_ids.dart';
import 'package:paydo/core/theme/app_colors.dart';
import 'package:paydo/features/navigation/presentation/app_shell.dart';
import 'package:paydo/features/settings/domain/app_language.dart';

import 'support/fakes/in_memory_bills_repository.dart';
import 'support/fakes/in_memory_settings_repository.dart';
import 'support/overrides.dart';

Future<void> _pump(WidgetTester tester, InMemorySettingsRepository repository) => tester.pumpWidget(
  ProviderScope(overrides: [...settingsOverrides(repository), ...billsOverrides(InMemoryBillsRepository())], child: const App()),
);

void main() {
  testWidgets('shows only the background while the language is loading, then the shell', (tester) async {
    await _pump(tester, InMemorySettingsRepository());

    expect(find.byKey(const ValueKey<String>(TestIds.appLoading)), findsOneWidget);
    expect(find.byType(AppShell), findsNothing);

    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>(TestIds.appLoading)), findsNothing);
    expect(find.byType(AppShell), findsOneWidget);
  });

  testWidgets('uses Polish by default', (tester) async {
    await _pump(tester, InMemorySettingsRepository());
    await tester.pumpAndSettle();

    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).locale, const Locale('pl'));
  });

  testWidgets('uses the saved language', (tester) async {
    await _pump(tester, InMemorySettingsRepository(language: AppLanguage.en));
    await tester.pumpAndSettle();

    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).locale, const Locale('en'));
  });

  testWidgets('MaterialApp uses the dark app theme and supports pl + en', (tester) async {
    await _pump(tester, InMemorySettingsRepository());
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(app.theme?.scaffoldBackgroundColor, AppColors.background);
    expect(app.debugShowCheckedModeBanner, isFalse);
    expect(app.supportedLocales, containsAll(const [Locale('pl'), Locale('en')]));
  });
}
