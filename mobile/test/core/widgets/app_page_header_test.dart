import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/core/theme/app_colors.dart';
import 'package:paydo/core/widgets/app_page_header.dart';

import '../../support/finders.dart';
import '../../support/pump_app.dart';

void main() {
  testWidgets('shows the title with optional leading and trailing widgets', (tester) async {
    await pumpApp(
      tester,
      const AppPageHeader(
        titleId: 'test.title',
        title: 'Bills',
        leading: SizedBox(key: ValueKey<String>('test.leading')),
        trailing: SizedBox(key: ValueKey<String>('test.trailing')),
      ),
    );

    expect(textOf(tester, 'test.title'), 'Bills');
    expect(textWidget(tester, 'test.title').style?.fontSize, AppFontSize.xxl);
    expect(byId('test.leading'), findsOneWidget);
    expect(byId('test.trailing'), findsOneWidget);
  });
}
