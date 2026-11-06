import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/core/testing/test_ids.dart';
import 'package:paydo/core/theme/app_colors.dart';
import 'package:paydo/core/widgets/app_day_picker.dart';

import '../../support/finders.dart';
import '../../support/pump_app.dart';

void main() {
  late Future<DayPick?> result;

  Future<void> open(WidgetTester tester, {int? initialDay}) async {
    await pumpApp(
      tester,
      Builder(
        builder: (context) => TextButton(
          key: const ValueKey<String>('test.open'),
          onPressed: () =>
              result = showAppDayOfMonthPicker(context, title: 'Day', clearLabel: 'None', cancelLabel: 'Cancel', initialDay: initialDay),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(byId('test.open'));
    await tester.pumpAndSettle();
  }

  Color? dayBackground(WidgetTester tester, int day) =>
      (tester.widget<Container>(find.descendant(of: byId(TestIds.dayPickerDay(day)), matching: find.byType(Container)).first).decoration
              as BoxDecoration?)
          ?.color;

  testWidgets('shows a calendar grid with days 1..31 and the actions', (tester) async {
    await open(tester);

    expect(byId(TestIds.dayPicker), findsOneWidget);
    expect(textOf(tester, TestIds.dayPickerTitle), 'Day');
    for (var day = 1; day <= 31; day++) {
      expect(textOf(tester, TestIds.dayPickerDay(day)), '$day');
    }
    expect(byId(TestIds.dayPickerDay(32)), findsNothing);
    expect(textOf(tester, TestIds.dayPickerClear), 'None');
    expect(textOf(tester, TestIds.dayPickerCancel), 'Cancel');
  });

  testWidgets('highlights the initial day', (tester) async {
    await open(tester, initialDay: 10);

    expect(dayBackground(tester, 10), AppColors.primary);
    expect(dayBackground(tester, 11), isNot(AppColors.primary));
  });

  testWidgets('tapping a day resolves to that day', (tester) async {
    await open(tester);
    await tester.tap(byId(TestIds.dayPickerDay(15)));
    await tester.pumpAndSettle();

    expect(await result, (day: 15));
    expect(byId(TestIds.dayPicker), findsNothing);
  });

  testWidgets('clear resolves to no day, cancel resolves to null', (tester) async {
    await open(tester, initialDay: 10);
    await tester.tap(byId(TestIds.dayPickerClear));
    await tester.pumpAndSettle();
    expect(await result, (day: null));

    await tester.tap(byId('test.open'));
    await tester.pumpAndSettle();
    await tester.tap(byId(TestIds.dayPickerCancel));
    await tester.pumpAndSettle();
    expect(await result, isNull);
  });
}
