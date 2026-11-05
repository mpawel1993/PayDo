import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/core/theme/app_theme.dart';

Future<void> pumpApp(WidgetTester tester, Widget child, {List<Override> overrides = const []}) => tester.pumpWidget(
  ProviderScope(
    overrides: overrides,
    child: MaterialApp(theme: buildAppTheme(), home: child),
  ),
);
