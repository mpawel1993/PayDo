import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/app.dart';
import 'package:paydo/core/testing/test_ids.dart';
import 'package:paydo/features/settings/domain/app_language.dart';
import 'package:paydo/features/settings/presentation/settings_page.dart';

import '../../../support/fakes/in_memory_bills_repository.dart';
import '../../../support/fakes/in_memory_settings_repository.dart';
import '../../../support/overrides.dart';
import '../../../support/pump_app.dart';

Finder _id(String id) => find.byKey(ValueKey<String>(id));

String _text(WidgetTester tester, String id) => tester.widget<Text>(find.descendant(of: _id(id), matching: find.byType(Text)).first).data!;

AppLanguage? _selected(WidgetTester tester) => tester.widget<RadioGroup<AppLanguage>>(find.byType(RadioGroup<AppLanguage>)).groupValue;

void main() {
  testWidgets('shows title, language label and both options in Polish', (tester) async {
    await pumpApp(tester, const SettingsPage());
    await tester.pump();

    expect(_id(TestIds.settingsPage), findsOneWidget);
    expect(_text(tester, TestIds.settingsTitle), 'Ustawienia');
    expect(_text(tester, TestIds.settingsLanguageLabel), 'Język');
    expect(_text(tester, TestIds.settingsLanguageOptionPl), 'Polski');
    expect(_text(tester, TestIds.settingsLanguageOptionEn), 'Angielski');
    expect(_selected(tester), AppLanguage.pl);
  });

  testWidgets('shows the texts in English for the en locale', (tester) async {
    await pumpApp(
      tester,
      const SettingsPage(),
      locale: const Locale('en'),
      settings: InMemorySettingsRepository(language: AppLanguage.en),
    );
    await tester.pump();

    expect(_text(tester, TestIds.settingsTitle), 'Settings');
    expect(_text(tester, TestIds.settingsLanguageLabel), 'Language');
    expect(_text(tester, TestIds.settingsLanguageOptionPl), 'Polish');
    expect(_text(tester, TestIds.settingsLanguageOptionEn), 'English');
    expect(_selected(tester), AppLanguage.en);
  });

  testWidgets('selecting English in the app switches every text to English and saves it', (tester) async {
    final repository = InMemorySettingsRepository();
    await tester.pumpWidget(
      ProviderScope(overrides: [...settingsOverrides(repository), ...billsOverrides(InMemoryBillsRepository())], child: const App()),
    );
    await tester.pumpAndSettle();

    await tester.tap(_id(TestIds.navigationTabSettings));
    await tester.pumpAndSettle();
    await tester.tap(_id(TestIds.settingsLanguageOptionEn));
    await tester.pumpAndSettle();

    expect(repository.language, AppLanguage.en);
    expect(_text(tester, TestIds.settingsTitle), 'Settings');
    expect(find.text('Bills'), findsOneWidget);
    expect(find.text('Rachunki'), findsNothing);
    expect(_selected(tester), AppLanguage.en);

    await tester.tap(_id(TestIds.settingsLanguageOptionPl));
    await tester.pumpAndSettle();

    expect(repository.language, AppLanguage.pl);
    expect(_text(tester, TestIds.settingsTitle), 'Ustawienia');
  });
}
