import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/core/theme/app_colors.dart';
import 'package:paydo/core/widgets/app_checkbox.dart';
import 'package:paydo/core/widgets/app_icon.dart';

import '../../support/finders.dart';
import '../../support/pump_app.dart';

BoxDecoration _box(WidgetTester tester) =>
    tester.widget<AnimatedContainer>(find.descendant(of: byId('test.cb'), matching: find.byType(AnimatedContainer))).decoration!
        as BoxDecoration;

void main() {
  testWidgets('unchecked: field colors, no check icon', (tester) async {
    await pumpApp(tester, AppCheckbox(id: 'test.cb', value: false, onChanged: (_) {}, label: 'Rent'));

    expect(byId('test.cb'), findsOneWidget);
    expect(_box(tester).color, AppColors.fieldBackground);
    expect(find.byType(AppIcon), findsNothing);
  });

  testWidgets('checked: primary fill with a check icon', (tester) async {
    await pumpApp(tester, AppCheckbox(id: 'test.cb', value: true, onChanged: (_) {}, label: 'Rent'));
    await tester.pumpAndSettle();

    expect(_box(tester).color, AppColors.primary);
    expect(tester.widget<AppIcon>(find.byType(AppIcon)).icon, PrimeIcon.check);
  });

  testWidgets('tapping reports the toggled value', (tester) async {
    bool? reported;
    await pumpApp(tester, AppCheckbox(id: 'test.cb', value: false, onChanged: (v) => reported = v, label: 'Rent'));

    await tester.tap(byId('test.cb'));
    expect(reported, isTrue);
  });

  testWidgets('exposes checked semantics with the label', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, AppCheckbox(id: 'test.cb', value: true, onChanged: (_) {}, label: 'Rent'));

    expect(
      tester.getSemantics(byId('test.cb')),
      isSemantics(identifier: 'test.cb', isChecked: true, hasCheckedState: true, label: 'Rent', isEnabled: true, hasTapAction: true),
    );
    handle.dispose();
  });
}
