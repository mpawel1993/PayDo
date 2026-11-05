import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/core/testing/test_ids.dart';
import 'package:paydo/features/navigation/presentation/app_shell.dart';

import '../../../support/pump_app.dart';

Finder _id(String id) => find.byKey(ValueKey<String>(id));

String _label(WidgetTester tester, String tabId) =>
    tester.widget<NavigationDestination>(find.descendant(of: _id(tabId), matching: find.byType(NavigationDestination))).label;

void main() {
  testWidgets('shows a bottom bar with Rachunki, Todo, Ustawienia in Polish', (tester) async {
    await pumpApp(tester, const AppShell());
    await tester.pump();

    expect(_id(TestIds.navigationBar), findsOneWidget);
    expect(_label(tester, TestIds.navigationTabBills), 'Rachunki');
    expect(_label(tester, TestIds.navigationTabTodo), 'Todo');
    expect(_label(tester, TestIds.navigationTabSettings), 'Ustawienia');
    for (final id in [TestIds.navigationTabBillsIcon, TestIds.navigationTabTodoIcon, TestIds.navigationTabSettingsIcon]) {
      expect(_id(id), findsOneWidget);
    }
  });

  testWidgets('shows the labels in English for the en locale', (tester) async {
    await pumpApp(tester, const AppShell(), locale: const Locale('en'));
    await tester.pump();

    expect(_label(tester, TestIds.navigationTabBills), 'Bills');
    expect(_label(tester, TestIds.navigationTabTodo), 'Todo');
    expect(_label(tester, TestIds.navigationTabSettings), 'Settings');
  });

  testWidgets('starts on the Bills page', (tester) async {
    await pumpApp(tester, const AppShell());
    await tester.pump();

    expect(_id(TestIds.billsPage), findsOneWidget);
    expect(_id(TestIds.todoPage), findsNothing);
    expect(_id(TestIds.settingsPage), findsNothing);
    expect(tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex, 0);
  });

  testWidgets('tapping a tab shows its page', (tester) async {
    await pumpApp(tester, const AppShell());
    await tester.pump();

    await tester.tap(_id(TestIds.navigationTabTodo));
    await tester.pumpAndSettle();
    expect(_id(TestIds.todoPage), findsOneWidget);
    expect(_id(TestIds.billsPage), findsNothing);
    expect(tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex, 1);

    await tester.tap(_id(TestIds.navigationTabSettings));
    await tester.pumpAndSettle();
    expect(_id(TestIds.settingsPage), findsOneWidget);
    expect(_id(TestIds.todoPage), findsNothing);
    expect(tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex, 2);

    await tester.tap(_id(TestIds.navigationTabBills));
    await tester.pumpAndSettle();
    expect(_id(TestIds.billsPage), findsOneWidget);
  });
}
