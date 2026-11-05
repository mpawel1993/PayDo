import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/core/testing/test_id.dart';
import 'package:paydo/core/testing/test_ids.dart';

void main() {
  test('TestIds.all contains no duplicates', () {
    expect(TestIds.all.toSet().length, TestIds.all.length);
  });

  test('TestIds follow the lower_snake_case dotted format', () {
    final format = RegExp(r'^[a-z0-9_]+(\.[a-z0-9_]+)+$');
    for (final id in TestIds.all) {
      expect(format.hasMatch(id), isTrue, reason: id);
    }
  });

  testWidgets('testId() applies both a ValueKey and a Semantics identifier', (tester) async {
    await tester.pumpWidget(const Directionality(textDirection: TextDirection.ltr, child: Text('x')).testId('test.sample'));

    expect(find.byKey(const ValueKey<String>('test.sample')), findsOneWidget);
    final semantics = tester.widget<Semantics>(find.byWidgetPredicate((w) => w is Semantics && w.properties.identifier == 'test.sample'));
    expect(semantics.container, isTrue);
  });
}
