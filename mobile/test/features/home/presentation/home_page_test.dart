import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/app.dart';
import 'package:paydo/core/testing/test_ids.dart';
import 'package:paydo/core/theme/app_colors.dart';
import 'package:paydo/features/home/presentation/home_page.dart';

import '../../../support/pump_app.dart';

const _page = ValueKey<String>(TestIds.homePage);
const _hello = ValueKey<String>(TestIds.homeHelloText);

void main() {
  testWidgets('App starts on the home page', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byKey(_page), findsOneWidget);
    expect(find.byKey(_hello), findsOneWidget);
  });

  testWidgets('HomePage shows only "hello" on the app background', (tester) async {
    await pumpApp(tester, const HomePage());

    final hello = tester.widget<Text>(find.descendant(of: find.byKey(_hello), matching: find.byType(Text)));
    expect(hello.data, 'hello');
    expect(find.byType(Text), findsOneWidget);

    final scaffold = tester.widget<Scaffold>(find.descendant(of: find.byKey(_page), matching: find.byType(Scaffold)));
    expect(scaffold.backgroundColor, AppColors.background);
  });

  testWidgets('"hello" is centered on screen', (tester) async {
    await pumpApp(tester, const HomePage());

    expect(tester.getCenter(find.byKey(_hello)), tester.getCenter(find.byKey(_page)));
  });

  testWidgets('MaterialApp uses the app dark theme', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(app.theme?.scaffoldBackgroundColor, AppColors.background);
    expect(app.debugShowCheckedModeBanner, isFalse);
  });
}
