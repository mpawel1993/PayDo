import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum PrimeIcon { arrowLeft, check, chevronLeft, chevronRight, cog, listCheck, plus, receipt, trash }

class AppIcon extends StatelessWidget {
  const AppIcon(this.icon, {super.key, required this.color, this.size = 16});

  final PrimeIcon icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset('assets/icons/${icon.name}.svg', width: size, height: size, colorFilter: ColorFilter.mode(color, BlendMode.srcIn));
}
