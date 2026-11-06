import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/core/testing/test_ids.dart';
import 'package:paydo/core/theme/app_colors.dart';
import 'package:paydo/core/widgets/app_confirm_dialog.dart';

import '../../support/finders.dart';
import '../../support/pump_app.dart';

void main() {
  late Future<bool> result;

  Future<void> open(WidgetTester tester) async {
    await pumpApp(
      tester,
      Builder(
        builder: (context) => TextButton(
          key: const ValueKey<String>('test.open'),
          onPressed: () => result = showAppConfirmDialog(context, message: 'Sure?', confirmLabel: 'Yes', cancelLabel: 'No'),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(byId('test.open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the message with yes / no buttons', (tester) async {
    await open(tester);

    expect(byId(TestIds.confirmDialog), findsOneWidget);
    expect(textOf(tester, TestIds.confirmDialogMessage), 'Sure?');
    expect(textOf(tester, TestIds.confirmDialogYes), 'Yes');
    expect(textOf(tester, TestIds.confirmDialogNo), 'No');
  });

  testWidgets('Yes resolves to true', (tester) async {
    await open(tester);
    await tester.tap(byId(TestIds.confirmDialogYes));
    await tester.pumpAndSettle();
    expect(await result, isTrue);
    expect(byId(TestIds.confirmDialog), findsNothing);
  });

  testWidgets('No resolves to false', (tester) async {
    await open(tester);
    await tester.tap(byId(TestIds.confirmDialogNo));
    await tester.pumpAndSettle();
    expect(await result, isFalse);
  });

  for (final (severity, color) in [
    (ConfirmSeverity.primary, AppColors.primary),
    (ConfirmSeverity.warning, AppColors.yellow400),
    (ConfirmSeverity.danger, AppColors.danger),
  ]) {
    testWidgets('the Yes button uses the ${severity.name} color', (tester) async {
      await pumpApp(
        tester,
        Builder(
          builder: (context) => TextButton(
            key: const ValueKey<String>('test.open'),
            onPressed: () => showAppConfirmDialog(context, message: 'Sure?', confirmLabel: 'Yes', cancelLabel: 'No', severity: severity),
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(byId('test.open'));
      await tester.pumpAndSettle();

      final button = tester.widget<FilledButton>(find.descendant(of: byId(TestIds.confirmDialogYes), matching: find.byType(FilledButton)));
      final context = tester.element(find.descendant(of: byId(TestIds.confirmDialogYes), matching: find.byType(FilledButton)));
      final style = button.style ?? FilledButtonTheme.of(context).style!;
      expect(style.backgroundColor!.resolve({}), color);
      expect(style.foregroundColor!.resolve({}), AppColors.primaryContrast);
    });
  }

  testWidgets('dismissing by tapping outside resolves to false', (tester) async {
    await open(tester);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(await result, isFalse);
  });
}
