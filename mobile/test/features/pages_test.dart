import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/core/testing/test_ids.dart';
import 'package:paydo/features/bills/presentation/bills_page.dart';
import 'package:paydo/features/shopping/presentation/shopping_page.dart';
import 'package:paydo/features/todo/presentation/todo_page.dart';

import '../support/pump_app.dart';

String _text(WidgetTester tester, String id) =>
    tester.widget<Text>(find.descendant(of: find.byKey(ValueKey<String>(id)), matching: find.byType(Text))).data!;

void main() {
  for (final (locale, expected) in [('pl', 'Rachunki'), ('en', 'Bills')]) {
    testWidgets('BillsPage shows its title ($locale)', (tester) async {
      await pumpApp(tester, const BillsPage(), locale: Locale(locale));
      expect(find.byKey(const ValueKey<String>(TestIds.billsPage)), findsOneWidget);
      expect(_text(tester, TestIds.billsTitle), expected);
    });
  }

  for (final locale in ['pl', 'en']) {
    testWidgets('TodoPage shows its title ($locale)', (tester) async {
      await pumpApp(tester, const TodoPage(), locale: Locale(locale));
      expect(find.byKey(const ValueKey<String>(TestIds.todoPage)), findsOneWidget);
      expect(_text(tester, TestIds.todoTitle), 'Todo');
    });
  }

  for (final (locale, expected) in [('pl', 'Zakupy'), ('en', 'Shopping')]) {
    testWidgets('ShoppingPage shows its title ($locale)', (tester) async {
      await pumpApp(tester, const ShoppingPage(), locale: Locale(locale));
      expect(find.byKey(const ValueKey<String>(TestIds.shoppingPage)), findsOneWidget);
      expect(_text(tester, TestIds.shoppingTitle), expected);
    });
  }
}
