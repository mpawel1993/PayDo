import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/core/widgets/app_icon.dart';

void main() {
  test('every PrimeIcon has an SVG asset', () {
    for (final icon in PrimeIcon.values) {
      expect(File('assets/icons/${icon.name}.svg').existsSync(), isTrue, reason: icon.name);
    }
  });

  testWidgets('renders the icon SVG with the given size and color', (tester) async {
    await tester.pumpWidget(const Center(child: AppIcon(PrimeIcon.cog, color: Color(0xFF34D399), size: 24)));

    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect((svg.bytesLoader as SvgAssetLoader).assetName, 'assets/icons/cog.svg');
    expect(svg.width, 24);
    expect(svg.height, 24);
    expect(svg.colorFilter, const ColorFilter.mode(Color(0xFF34D399), BlendMode.srcIn));
  });
}
