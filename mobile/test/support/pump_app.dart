import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/core/l10n/generated/app_localizations.dart';
import 'package:paydo/core/theme/app_theme.dart';

import 'fakes/in_memory_settings_repository.dart';
import 'overrides.dart';

Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('pl'),
  InMemorySettingsRepository? settings,
  List<Override> overrides = const [],
}) => tester.pumpWidget(
  ProviderScope(
    overrides: [...settingsOverrides(settings ?? InMemorySettingsRepository()), ...overrides],
    child: MaterialApp(
      theme: buildAppTheme(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  ),
);
