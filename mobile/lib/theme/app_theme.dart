import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_text.dart';

enum Severity { primary, secondary, success, info, warn, danger }

enum ButtonSize { small, normal, large }

typedef SeverityColors = ({Color bg, Color hover, Color active, Color fg, Color accent});

SeverityColors severityColors(Severity s) => switch (s) {
  Severity.primary => (
    bg: AppColors.primary,
    hover: AppColors.primaryHover,
    active: AppColors.primaryActive,
    fg: AppColors.primaryContrast,
    accent: AppColors.primary,
  ),
  Severity.secondary => (
    bg: AppColors.slate800,
    hover: AppColors.slate700,
    active: AppColors.slate600,
    fg: AppColors.slate300,
    accent: AppColors.slate300,
  ),
  Severity.success => (
    bg: AppColors.green400,
    hover: AppColors.green300,
    active: const Color(0xFFBBF7D0),
    fg: AppColors.green950,
    accent: AppColors.green400,
  ),
  Severity.info => (
    bg: AppColors.sky400,
    hover: AppColors.sky300,
    active: const Color(0xFFBAE6FD),
    fg: AppColors.sky950,
    accent: AppColors.sky400,
  ),
  Severity.warn => (
    bg: AppColors.orange400,
    hover: AppColors.orange300,
    active: const Color(0xFFFED7AA),
    fg: AppColors.orange950,
    accent: AppColors.orange400,
  ),
  Severity.danger => (
    bg: AppColors.red400,
    hover: AppColors.red300,
    active: AppColors.red200,
    fg: AppColors.red950,
    accent: AppColors.red400,
  ),
};

const _buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppRadius.field)));
const _buttonPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 8);
final _buttonText = AppText.base.copyWith(fontWeight: FontWeight.w500);
const _fieldRadius = BorderRadius.all(Radius.circular(AppRadius.field));

WidgetStateProperty<Color> _overlay(Color c) => WidgetStateProperty.resolveWith(
  (s) => s.contains(WidgetState.pressed)
      ? c.withValues(alpha: 0.16)
      : s.contains(WidgetState.hovered)
      ? c.withValues(alpha: 0.04)
      : Colors.transparent,
);

ButtonStyle filledButtonSeverity(Severity s) {
  final c = severityColors(s);
  Color bg(Set<WidgetState> st) => st.contains(WidgetState.disabled)
      ? c.bg.withValues(alpha: 0.6)
      : st.contains(WidgetState.pressed)
      ? c.active
      : st.contains(WidgetState.hovered)
      ? c.hover
      : c.bg;
  return ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith(bg),
    foregroundColor: WidgetStateProperty.resolveWith((st) => st.contains(WidgetState.disabled) ? c.fg.withValues(alpha: 0.6) : c.fg),
    iconColor: WidgetStatePropertyAll(c.fg),
    side: WidgetStateProperty.resolveWith((st) => BorderSide(color: bg(st))),
    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    elevation: const WidgetStatePropertyAll(0),
    shadowColor: const WidgetStatePropertyAll(Colors.transparent),
    surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
    padding: const WidgetStatePropertyAll(_buttonPadding),
    minimumSize: const WidgetStatePropertyAll(Size(0, 40)),
    shape: const WidgetStatePropertyAll(_buttonShape),
    textStyle: WidgetStatePropertyAll(_buttonText),
    iconSize: const WidgetStatePropertyAll(16),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    splashFactory: NoSplash.splashFactory,
  );
}

ButtonStyle textButtonSeverity(Color c) => ButtonStyle(
  foregroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.disabled) ? c.withValues(alpha: 0.6) : c),
  iconColor: WidgetStatePropertyAll(c),
  backgroundColor: _overlay(c),
  overlayColor: const WidgetStatePropertyAll(Colors.transparent),
);

ButtonStyle buttonSize(ButtonSize s) => switch (s) {
  ButtonSize.small => ButtonStyle(
    padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
    minimumSize: const WidgetStatePropertyAll(Size(0, 32)),
    textStyle: WidgetStatePropertyAll(AppText.sm.copyWith(fontWeight: FontWeight.w500)),
    iconSize: const WidgetStatePropertyAll(14),
  ),
  ButtonSize.normal => const ButtonStyle(),
  ButtonSize.large => ButtonStyle(
    padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
    minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
    textStyle: WidgetStatePropertyAll(AppText.lg.copyWith(fontWeight: FontWeight.w500)),
    iconSize: const WidgetStatePropertyAll(18),
  ),
};

const systemOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: AppColors.background,
  systemNavigationBarIconBrightness: Brightness.light,
);

ThemeData buildAppTheme() {
  const scheme = ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: AppColors.primaryContrast,
    secondary: AppColors.primary,
    onSecondary: AppColors.primaryContrast,
    surface: AppColors.surface,
    onSurface: AppColors.text,
    onSurfaceVariant: AppColors.textMuted,
    surfaceContainerLowest: AppColors.background,
    surfaceContainerLow: AppColors.surface,
    surfaceContainer: AppColors.surface,
    surfaceContainerHigh: AppColors.surfaceHover,
    surfaceContainerHighest: AppColors.surfaceHover,
    error: AppColors.danger,
    onError: AppColors.red950,
    outline: AppColors.fieldBorder,
    outlineVariant: AppColors.border,
    surfaceTint: Colors.transparent,
    shadow: Colors.black,
    scrim: AppColors.mask,
  );

  OutlineInputBorder fieldBorder(Color c) => OutlineInputBorder(
    borderRadius: _fieldRadius,
    borderSide: BorderSide(color: c),
  );
  const borderSide = BorderSide(color: AppColors.border);
  const fieldShape = RoundedRectangleBorder(borderRadius: _fieldRadius);
  const cardRadius = BorderRadius.all(Radius.circular(AppRadius.card));
  const menuStyle = MenuStyle(
    backgroundColor: WidgetStatePropertyAll(AppColors.surface),
    surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
    shadowColor: WidgetStatePropertyAll(Color(0x66000000)),
    elevation: WidgetStatePropertyAll(4),
    padding: WidgetStatePropertyAll(EdgeInsets.all(4)),
    shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: _fieldRadius, side: borderSide)),
  );
  final inputTheme = InputDecorationThemeData(
    filled: true,
    fillColor: AppColors.fieldBackground,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    border: fieldBorder(AppColors.fieldBorder),
    enabledBorder: fieldBorder(AppColors.fieldBorder),
    focusedBorder: fieldBorder(AppColors.fieldFocusBorder),
    errorBorder: fieldBorder(AppColors.danger),
    focusedErrorBorder: fieldBorder(AppColors.danger),
    disabledBorder: fieldBorder(AppColors.fieldBorder),
    hintStyle: AppText.base.copyWith(color: AppColors.placeholder),
    labelStyle: AppText.base.copyWith(color: AppColors.textMuted),
    floatingLabelStyle: AppText.base.copyWith(color: AppColors.textMuted),
    floatingLabelBehavior: FloatingLabelBehavior.never,
    errorStyle: AppText.sm.copyWith(color: AppColors.danger),
    helperStyle: AppText.sm.copyWith(color: AppColors.textMuted),
    prefixIconColor: AppColors.textMuted,
    suffixIconColor: AppColors.textMuted,
    hoverColor: Colors.transparent,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    fontFamily: AppText.fontFamily,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.surface,
    splashFactory: NoSplash.splashFactory,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    focusColor: AppColors.primary.withValues(alpha: 0.16),
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    textTheme: TextTheme(
      displaySmall: AppText.xxxl,
      headlineSmall: AppText.xxl,
      titleLarge: AppText.xl,
      titleMedium: AppText.lg.copyWith(fontWeight: FontWeight.w500),
      titleSmall: AppText.base.copyWith(fontWeight: FontWeight.w500),
      bodyLarge: AppText.base,
      bodyMedium: AppText.base,
      bodySmall: AppText.sm,
      labelLarge: AppText.base.copyWith(fontWeight: FontWeight.w500),
      labelMedium: AppText.sm.copyWith(fontWeight: FontWeight.w500),
      labelSmall: AppText.xs,
    ),
    iconTheme: const IconThemeData(color: AppColors.textMuted, size: 16),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.primary,
      selectionHandleColor: AppColors.primary,
      selectionColor: AppColors.primary.withValues(alpha: 0.3),
    ),
    inputDecorationTheme: inputTheme,
    filledButtonTheme: FilledButtonThemeData(style: filledButtonSeverity(Severity.primary)),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: const WidgetStatePropertyAll(AppColors.primary),
        iconColor: const WidgetStatePropertyAll(AppColors.primary),
        backgroundColor: _overlay(AppColors.primary),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        side: const WidgetStatePropertyAll(BorderSide(color: AppColors.emerald700)),
        elevation: const WidgetStatePropertyAll(0),
        padding: const WidgetStatePropertyAll(_buttonPadding),
        minimumSize: const WidgetStatePropertyAll(Size(0, 40)),
        shape: const WidgetStatePropertyAll(_buttonShape),
        textStyle: WidgetStatePropertyAll(_buttonText),
        iconSize: const WidgetStatePropertyAll(16),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        splashFactory: NoSplash.splashFactory,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: const WidgetStatePropertyAll(AppColors.primary),
        iconColor: const WidgetStatePropertyAll(AppColors.primary),
        backgroundColor: _overlay(AppColors.primary),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(0),
        padding: const WidgetStatePropertyAll(_buttonPadding),
        minimumSize: const WidgetStatePropertyAll(Size(40, 40)),
        shape: const WidgetStatePropertyAll(_buttonShape),
        textStyle: WidgetStatePropertyAll(_buttonText),
        iconSize: const WidgetStatePropertyAll(16),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        splashFactory: NoSplash.splashFactory,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.primaryContrast : AppColors.slate400),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.primary : AppColors.fieldBorder),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      thumbIcon: const WidgetStatePropertyAll(null),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.primary : AppColors.fieldBorder),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: cardRadius, side: borderSide),
      barrierColor: AppColors.mask,
      titleTextStyle: AppText.xl.copyWith(fontWeight: FontWeight.w600),
      contentTextStyle: AppText.base,
      insetPadding: const EdgeInsets.all(16),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      modalBackgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      modalElevation: 0,
      modalBarrierColor: AppColors.mask,
      showDragHandle: true,
      dragHandleColor: AppColors.border,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
        side: borderSide,
      ),
    ),
    menuTheme: const MenuThemeData(style: menuStyle),
    dropdownMenuTheme: DropdownMenuThemeData(menuStyle: menuStyle, inputDecorationTheme: inputTheme, textStyle: AppText.base),
    menuButtonTheme: MenuButtonThemeData(
      style: ButtonStyle(
        foregroundColor: const WidgetStatePropertyAll(AppColors.text),
        iconColor: const WidgetStatePropertyAll(AppColors.textMuted),
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.highlight
              : s.contains(WidgetState.hovered) || s.contains(WidgetState.focused) || s.contains(WidgetState.pressed)
              ? AppColors.surfaceHover
              : Colors.transparent,
        ),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
        shape: const WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppRadius.checkbox)))),
        textStyle: const WidgetStatePropertyAll(AppText.base),
        iconSize: const WidgetStatePropertyAll(16),
        splashFactory: NoSplash.splashFactory,
      ),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: _fieldRadius, side: borderSide),
      textStyle: AppText.base,
      menuPadding: EdgeInsets.all(4),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.surface,
      contentTextStyle: AppText.base,
      actionTextColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: _fieldRadius, side: borderSide),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
    tooltipTheme: const TooltipThemeData(
      decoration: BoxDecoration(color: AppColors.slate700, borderRadius: _fieldRadius),
      textStyle: AppText.sm,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      waitDuration: Duration(milliseconds: 500),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.border,
      circularTrackColor: Colors.transparent,
      linearMinHeight: 4,
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: AppColors.surfaceHover,
      selectedColor: AppColors.highlight,
      labelStyle: AppText.sm,
      side: BorderSide.none,
      shape: StadiumBorder(),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 64,
      indicatorColor: AppColors.highlight,
      indicatorShape: fieldShape,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppText.xs.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500)
            : AppText.xs.copyWith(color: AppColors.textMuted),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: AppColors.surface,
      elevation: 0,
      indicatorColor: AppColors.highlight,
      indicatorShape: fieldShape,
      selectedLabelTextStyle: AppText.sm.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500),
      unselectedLabelTextStyle: AppText.sm.copyWith(color: AppColors.textMuted),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrimColor: AppColors.mask,
      width: 280,
      shape: Border(right: borderSide),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: AppText.xl,
      shape: Border(bottom: borderSide),
      systemOverlayStyle: systemOverlayStyle,
    ),
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      selectedTileColor: AppColors.highlight,
      selectedColor: AppColors.highlightText,
      iconColor: AppColors.textMuted,
      textColor: AppColors.text,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      shape: fieldShape,
      minVerticalPadding: 8,
      dense: true,
      titleTextStyle: AppText.base,
      subtitleTextStyle: AppText.sm.copyWith(color: AppColors.textMuted),
    ),
    dataTableTheme: DataTableThemeData(
      headingRowColor: const WidgetStatePropertyAll(AppColors.surface),
      headingTextStyle: AppText.base.copyWith(fontWeight: FontWeight.w600),
      dataTextStyle: AppText.base,
      dataRowColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.highlight
            : s.contains(WidgetState.hovered)
            ? AppColors.surfaceHover
            : AppColors.surface,
      ),
      dividerThickness: 1,
      horizontalMargin: 16,
      columnSpacing: 32,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textMuted,
      labelStyle: AppText.base.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: AppText.base.copyWith(fontWeight: FontWeight.w600),
      indicatorColor: AppColors.primary,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: AppColors.border,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      splashFactory: NoSplash.splashFactory,
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: cardRadius, side: borderSide),
      headerBackgroundColor: AppColors.surface,
      headerForegroundColor: AppColors.text,
      dividerColor: AppColors.border,
      todayBorder: const BorderSide(color: AppColors.primary),
      dayShape: const WidgetStatePropertyAll(fieldShape),
      dayBackgroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.primary : Colors.transparent),
      dayForegroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.primaryContrast : AppColors.text,
      ),
      dayOverlayColor: const WidgetStatePropertyAll(Colors.transparent),
      todayForegroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.primaryContrast : AppColors.primary,
      ),
      todayBackgroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.primary : Colors.transparent,
      ),
      yearBackgroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.primary : Colors.transparent,
      ),
      yearForegroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.primaryContrast : AppColors.text,
      ),
      cancelButtonStyle: textButtonSeverity(AppColors.textMuted),
      confirmButtonStyle: textButtonSeverity(AppColors.primary),
    ),
    scrollbarTheme: const ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(AppColors.border),
      radius: Radius.circular(AppRadius.field),
      thickness: WidgetStatePropertyAll(6),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: cardRadius),
    ),
  );
}
