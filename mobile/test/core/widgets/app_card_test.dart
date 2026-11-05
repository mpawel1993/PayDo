import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/core/theme/app_colors.dart';
import 'package:paydo/core/widgets/app_card.dart';

import '../../support/finders.dart';
import '../../support/pump_app.dart';

void main() {
  testWidgets('renders a surface card with title, subtitle, aside and child', (tester) async {
    await pumpApp(
      tester,
      const AppCard(
        id: 'test.card',
        titleId: 'test.card_title',
        title: 'Personal',
        subtitle: 'Sub',
        aside: Text('aside', key: ValueKey<String>('test.aside')),
        child: Text('body', key: ValueKey<String>('test.body')),
      ),
    );

    expect(byId('test.card'), findsOneWidget);
    expect(textOf(tester, 'test.card_title'), 'Personal');
    expect(find.text('Sub'), findsOneWidget);
    expect(byId('test.aside'), findsOneWidget);
    expect(byId('test.body'), findsOneWidget);

    final container = tester.widget<Container>(find.descendant(of: byId('test.card'), matching: find.byType(Container)).first);
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.surface);
    expect(decoration.borderRadius, BorderRadius.circular(AppRadius.card));
    expect(decoration.border, isNull);
    expect(decoration.boxShadow, isNull);
    expect(textWidget(tester, 'test.card_title').style?.fontSize, AppFontSize.xl);
  });
}
