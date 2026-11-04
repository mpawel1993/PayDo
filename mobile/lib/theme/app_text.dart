import 'package:flutter/painting.dart';

import 'app_colors.dart';

abstract final class AppText {
  static const fontFamily = 'Inter';

  static const xs = TextStyle(fontFamily: fontFamily, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w400, color: AppColors.text);
  static const sm = TextStyle(fontFamily: fontFamily, fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, color: AppColors.text);
  static const base = TextStyle(fontFamily: fontFamily, fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400, color: AppColors.text);
  static const lg = TextStyle(fontFamily: fontFamily, fontSize: 18, height: 28 / 18, fontWeight: FontWeight.w400, color: AppColors.text);
  static const xl = TextStyle(fontFamily: fontFamily, fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w500, color: AppColors.text);
  static const xxl = TextStyle(fontFamily: fontFamily, fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w600, color: AppColors.text);
  static const xxxl = TextStyle(fontFamily: fontFamily, fontSize: 30, height: 36 / 30, fontWeight: FontWeight.w600, color: AppColors.text);
}
