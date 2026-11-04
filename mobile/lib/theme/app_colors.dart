import 'package:flutter/painting.dart';

abstract final class AppColors {
  static const emerald50 = Color(0xFFECFDF5);
  static const emerald100 = Color(0xFFD1FAE5);
  static const emerald200 = Color(0xFFA7F3D0);
  static const emerald300 = Color(0xFF6EE7B7);
  static const emerald400 = Color(0xFF34D399);
  static const emerald500 = Color(0xFF10B981);
  static const emerald600 = Color(0xFF059669);
  static const emerald700 = Color(0xFF047857);
  static const emerald800 = Color(0xFF065F46);
  static const emerald900 = Color(0xFF064E3B);
  static const emerald950 = Color(0xFF022C22);

  static const slate0 = Color(0xFFFFFFFF);
  static const slate50 = Color(0xFFF8FAFC);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate300 = Color(0xFFCBD5E1);
  static const slate400 = Color(0xFF94A3B8);
  static const slate500 = Color(0xFF64748B);
  static const slate600 = Color(0xFF475569);
  static const slate700 = Color(0xFF334155);
  static const slate800 = Color(0xFF1E293B);
  static const slate900 = Color(0xFF0F172A);
  static const slate950 = Color(0xFF020617);

  static const green300 = Color(0xFF86EFAC);
  static const green400 = Color(0xFF4ADE80);
  static const green500 = Color(0xFF22C55E);
  static const green950 = Color(0xFF052E16);
  static const red200 = Color(0xFFFECACA);
  static const red300 = Color(0xFFFCA5A5);
  static const red400 = Color(0xFFF87171);
  static const red500 = Color(0xFFEF4444);
  static const red950 = Color(0xFF450A0A);
  static const orange300 = Color(0xFFFDBA74);
  static const orange400 = Color(0xFFFB923C);
  static const orange500 = Color(0xFFF97316);
  static const orange950 = Color(0xFF431407);
  static const sky300 = Color(0xFF7DD3FC);
  static const sky400 = Color(0xFF38BDF8);
  static const sky500 = Color(0xFF0EA5E9);
  static const sky950 = Color(0xFF082F49);
  static const violet400 = Color(0xFFA78BFA);
  static const pink400 = Color(0xFFF472B6);
  static const yellow400 = Color(0xFFFACC15);

  static const primary = emerald400;
  static const primaryHover = emerald300;
  static const primaryActive = emerald200;
  static const primaryContrast = slate900;
  static const background = slate950;
  static const surface = slate900;
  static const surfaceHover = slate800;
  static const border = slate700;
  static const fieldBackground = slate950;
  static const fieldBorder = slate600;
  static const fieldHoverBorder = slate500;
  static const fieldFocusBorder = emerald400;
  static const fieldDisabledBackground = slate700;
  static const fieldDisabledText = slate400;
  static const text = slate0;
  static const textMuted = slate400;
  static const placeholder = slate500;
  static const highlight = Color(0x2934D399);
  static const highlightText = Color(0xDEFFFFFF);
  static const success = green400;
  static const warning = orange400;
  static const danger = red400;
  static const info = sky400;
  static const mask = Color(0x99000000);
}

abstract final class AppRadius {
  static const checkbox = 4.0;
  static const field = 6.0;
  static const card = 12.0;
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const card = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

abstract final class Breakpoints {
  static const sm = 640.0;
  static const md = 768.0;
  static const lg = 1024.0;
  static const xl = 1280.0;
  static const xxl = 1536.0;
}
