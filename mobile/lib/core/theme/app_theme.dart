import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

const appFontFamily = 'Inter';

final systemOverlayStyle = SystemUiOverlayStyle.light.copyWith(
  statusBarColor: Colors.transparent,
  systemNavigationBarColor: AppColors.background,
);

const _buttonPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 8);
const _buttonText = TextStyle(fontFamily: appFontFamily, fontSize: AppFontSize.base, fontWeight: FontWeight.w500);
final _fieldShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.field));
final _cardShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card));

OutlineInputBorder _fieldBorder(Color color) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(AppRadius.field),
  borderSide: BorderSide(color: color),
);

ButtonStyle textButtonSeverity(Color c) => ButtonStyle(
  foregroundColor: WidgetStatePropertyAll(c),
  overlayColor: WidgetStateProperty.resolveWith(
    (states) => states.contains(WidgetState.pressed)
        ? c.withValues(alpha: 0.16)
        : states.contains(WidgetState.hovered)
        ? c.withValues(alpha: 0.04)
        : Colors.transparent,
  ),
);

ThemeData buildAppTheme() {
  const colorScheme = ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: AppColors.primaryContrast,
    surface: AppColors.surface,
    onSurface: AppColors.text,
    error: AppColors.danger,
    outline: AppColors.border,
  );
  const smallText = TextStyle(fontFamily: appFontFamily, fontSize: AppFontSize.xs, color: AppColors.text);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: appFontFamily,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.background,
    splashFactory: NoSplash.splashFactory,
    textTheme: ThemeData.dark().textTheme.apply(fontFamily: appFontFamily, bodyColor: AppColors.text, displayColor: AppColors.text),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.primary,
      selectionHandleColor: AppColors.primary,
      selectionColor: AppColors.primary.withValues(alpha: 0.3),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.fieldBackground,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: _fieldBorder(AppColors.fieldBorder),
      enabledBorder: _fieldBorder(AppColors.fieldBorder),
      focusedBorder: _fieldBorder(AppColors.focusBorder),
      errorBorder: _fieldBorder(AppColors.danger),
      focusedErrorBorder: _fieldBorder(AppColors.danger),
      hintStyle: const TextStyle(color: AppColors.placeholder, fontSize: AppFontSize.base),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? AppColors.primary.withValues(alpha: 0.6)
              : states.contains(WidgetState.pressed)
              ? AppColors.primaryActive
              : states.contains(WidgetState.hovered)
              ? AppColors.primaryHover
              : AppColors.primary,
        ),
        foregroundColor: const WidgetStatePropertyAll(AppColors.primaryContrast),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(0),
        padding: const WidgetStatePropertyAll(_buttonPadding),
        minimumSize: const WidgetStatePropertyAll(Size(0, 40)),
        shape: WidgetStatePropertyAll(_fieldShape),
        textStyle: const WidgetStatePropertyAll(_buttonText),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: textButtonSeverity(AppColors.primary).copyWith(
        padding: const WidgetStatePropertyAll(_buttonPadding),
        minimumSize: const WidgetStatePropertyAll(Size(40, 40)),
        shape: WidgetStatePropertyAll(_fieldShape),
        textStyle: const WidgetStatePropertyAll(_buttonText),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),
    dialogTheme: DialogThemeData(backgroundColor: AppColors.surface, surfaceTintColor: Colors.transparent, shape: _cardShape),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.field),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.field),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surface,
      contentTextStyle: const TextStyle(fontFamily: appFontFamily, fontSize: AppFontSize.base, color: AppColors.text),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      textStyle: smallText,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.border,
      circularTrackColor: AppColors.border,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? AppColors.primaryContrast : AppColors.textMuted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? AppColors.primary : AppColors.fieldBorder,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? AppColors.primary : AppColors.fieldBorder,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceHover,
      selectedColor: AppColors.highlight,
      side: const BorderSide(color: AppColors.border),
      shape: _fieldShape,
      labelStyle: smallText,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card))),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      indicatorColor: AppColors.highlight,
      indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.field)),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: appFontFamily,
          fontSize: AppFontSize.xs,
          fontWeight: FontWeight.w500,
          color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.textMuted,
        ),
      ),
    ),
    listTileTheme: ListTileThemeData(
      textColor: AppColors.text,
      iconColor: AppColors.textMuted,
      selectedColor: AppColors.text,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      shape: _fieldShape,
      titleTextStyle: const TextStyle(fontFamily: appFontFamily, fontSize: AppFontSize.base, color: AppColors.text),
    ),
  );
}
