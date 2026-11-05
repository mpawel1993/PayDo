import 'package:flutter/painting.dart';

abstract final class AppColors {
  static const primary = Color(0xFF34D399);
  static const primaryHover = Color(0xFF6EE7B7);
  static const primaryActive = Color(0xFFA7F3D0);
  static const primaryContrast = Color(0xFF0F172A);

  static const background = Color(0xFF020617);
  static const surface = Color(0xFF0F172A);
  static const surfaceHover = Color(0xFF1E293B);
  static const border = Color(0xFF334155);

  static const fieldBackground = Color(0xFF020617);
  static const fieldBorder = Color(0xFF475569);
  static const focusBorder = primary;

  static const text = Color(0xFFFFFFFF);
  static const textMuted = Color(0xFF94A3B8);
  static const placeholder = Color(0xFF64748B);

  static const highlight = Color(0x2934D399);
  static const highlightText = Color(0xDEFFFFFF);

  static const success = Color(0xFF4ADE80);
  static const warning = Color(0xFFFB923C);
  static const danger = Color(0xFFF87171);
  static const info = Color(0xFF38BDF8);

  static const slate300 = Color(0xFFCBD5E1);
  static const slate600 = Color(0xFF475569);
  static const sky400 = Color(0xFF38BDF8);
  static const orange400 = Color(0xFFFB923C);
  static const violet400 = Color(0xFFA78BFA);
  static const pink400 = Color(0xFFF472B6);
  static const yellow400 = Color(0xFFFACC15);
}

abstract final class AppRadius {
  static const double checkbox = 4;
  static const double field = 6;
  static const double card = 12;
}

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

abstract final class AppFontSize {
  static const double xs = 12;
  static const double base = 16;
  static const double xl = 20;
  static const double xxl = 24;
}

abstract final class Breakpoints {
  static const double sm = 640;
  static const double md = 768;
  static const double lg = 1024;
  static const double xl = 1280;
}
