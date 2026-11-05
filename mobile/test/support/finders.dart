import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Finder byId(String id) => find.byKey(ValueKey<String>(id));

Text textWidget(WidgetTester tester, String id) =>
    tester.widget<Text>(find.descendant(of: byId(id), matching: find.byType(Text), matchRoot: true).first);

String textOf(WidgetTester tester, String id) => textWidget(tester, id).data!;
