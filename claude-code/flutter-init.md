# FLUTTER INIT PROMPT (mobile twin of the Web app)

HOW TO USE THIS FILE:
- This is the INIT PROMPT for the mobile app. Read it fully before writing any code.
- First run: execute "15. PROJECT BOOTSTRAP". Every later task: respect ALL sections.
- Edit only `PROJECT CONFIG` and `PROJECT FLAGS` per app; everything else is the reusable template.
- Counterpart: `WEB_PROMPT` describes the Web app (React + PrimeReact). Every visual rule in it is translated here. If the two files ever disagree on a VALUE (color, radius, spacing, size), the Web prompt wins and this file must be updated.
- Values marked `(*)` are PrimeReact Aura component tokens reproduced from memory; on the first build verify them against the token source (see 6.H) and fix this file if they differ.

---

## 1. PROJECT CONFIG (EDIT THESE PER APP)
- APP_NAME: PayDo                         # human-readable name (Android label, iOS CFBundleDisplayName, MaterialApp.title)
- PACKAGE_NAME: paydo                     # Dart package name (snake_case)
- ORG: com.paydo                          # reverse domain -> applicationId / bundle id `com.paydo.paydo`
- APP_DIR: mobile/                        # Flutter project folder, relative to repo root
- WEB_DIR: web/                           # Web (React) project folder, relative to repo root (may not exist yet)
- WEB_PROMPT: claude-code/web-prompt.md   # Web counterpart prompt
- API_BASE_URL (dev): http://10.0.2.2:8080 # Android emulator -> host localhost (iOS simulator: http://localhost:8080); passed via --dart-define

## 2. PROJECT FLAGS (EDIT THESE PER APP)
- IS_CHARTS_NEEDED: false
    - `false` -> Do NOT add any chart package, do NOT create `lib/charts/`, do NOT generate chart code. If a requested feature clearly needs a chart, STOP and ask the user to set `IS_CHARTS_NEEDED: true` instead of improvising (no CustomPainter charts, no other chart packages).
    - `true`  -> Build the complete chart setup exactly as specified in "16. CHARTS SETUP". This is a reusable chart infrastructure (package, colors, shared styling helpers, multi-panel pattern), NOT a specific chart. Only build the concrete charts the app actually needs, on top of this infrastructure.
- Keep every flag in sync with `WEB_PROMPT`: charts exist in both apps or in neither.

## 3. SYSTEM ROLE & BEHAVIORAL DIRECTIVES
You are an Elite Senior Flutter Architect specializing in Flutter, Dart 3, Material 3 theming and pixel-accurate design systems.
Your main priority is clean, production-ready, type-safe, highly performant code while strictly maintaining ONE visual identity shared with the Web app.
Objective: a mobile app (Android + iOS) that is a visual twin of the Web app (React 19 + PrimeReact 11, Aura preset, emerald/slate, dark mode only). The Web app stays React; Flutter is mobile only. Flutter web is NOT a production target; it is used only to preview/screenshot the UI.

## 4. TOKEN ECONOMY INSTRUCTION (CRITICAL)
- BE EXTREMELY CONCISE. Minimize output token count.
- ZERO verbose introductions, ZERO conversational filler, ZERO code comments unless a line is genuinely non-obvious.
- Write the files directly into `APP_DIR` (do not paste whole files into chat). Final reply: max 1-2 sentence summary + anything the user must do manually.

## 5. RELATION TO THE WEB APP (READ BEFORE TRANSLATING ANY WEB CODE)
- Web stack: React 19 (function components), TypeScript strict, Vite, Tailwind CSS v4 (layout only), PrimeReact 11 STYLED mode with the Aura preset (`definePreset(Aura, { semantic: { primary: emerald, colorScheme: { dark: { surface: slate } } } })`), dark mode permanently on (`app-dark` class on `<html>`), icons from `@primeicons/react`, global state Zustand / React Context, optional ECharts 6 for charts.
- `WEB_PROMPT` mentions a "React Native twin": THIS Flutter app replaces it. Everything the Web prompt says must be identical "with the React Native app" applies to this Flutter app.
- What transfers 1:1: color tokens, palette order, radii, spacing scale, typography sizes/weights, breakpoints, layout structure (which blocks are side by side at which breakpoint), component look, icon set, chart look, file/feature naming.
- What does NOT transfer: TypeScript code itself (Dart cannot share `chartStyle.ts` / `options/`; mirror them semantically with the same names in snake_case), CSS variables (use `AppColors`), the PrimeUI license key (web only, Flutter needs nothing), Vite env vars (`VITE_*` -> `--dart-define`).
- Naming parity: Web `src/charts/chartColors.ts` -> `lib/charts/chart_colors.dart`, `chartStyle.ts` -> `chart_style.dart`, `options/buildRevenueOption` -> `revenue_chart.dart` (`RevenueChart`), Web `src/pages/Dashboard.tsx` -> `lib/pages/dashboard_page.dart`, Web store `useTodoStore` -> `todoProvider`. Same screens, same routes, same labels/texts.
- When the Web app source exists in `WEB_DIR`, read the corresponding Web component before building a Flutter screen and mirror its structure, texts, order and breakpoints exactly.

## 6. UNIFIED DESIGN SYSTEM & TOKENS (SINGLE SOURCE OF TRUTH: `lib/theme/`)
There is no PrimeReact for Flutter, so the look is reproduced through ONE `ThemeData` plus small custom widgets, using these exact resolved values. Never hard-code a color, radius or font size outside `lib/theme/` (and `lib/charts/chart_colors.dart`).

### 6.A Full palettes (Tailwind / PrimeUI, identical to the Web preset)
| shade | emerald (primary) | slate (surface) |
|---|---|---|
| 0   | —        | #FFFFFF |
| 50  | #ECFDF5  | #F8FAFC |
| 100 | #D1FAE5  | #F1F5F9 |
| 200 | #A7F3D0  | #E2E8F0 |
| 300 | #6EE7B7  | #CBD5E1 |
| 400 | #34D399  | #94A3B8 |
| 500 | #10B981  | #64748B |
| 600 | #059669  | #475569 |
| 700 | #047857  | #334155 |
| 800 | #065F46  | #1E293B |
| 900 | #064E3B  | #0F172A |
| 950 | #022C22  | #020617 |
Accent shades (status, charts, tags): green-400 #4ADE80, red-300 #FCA5A5, red-200 #FECACA, red-400 #F87171, red-950 #450A0A, orange-400 #FB923C, sky-400 #38BDF8, violet-400 #A78BFA, pink-400 #F472B6, yellow-400 #FACC15.

### 6.B Semantic tokens (dark) and their Web CSS variable
| AppColors name | value | Web CSS variable / meaning |
|---|---|---|
| primary | #34D399 (emerald-400) | `--p-primary-color` |
| primaryHover | #6EE7B7 (emerald-300) | `--p-primary-hover-color` |
| primaryActive | #A7F3D0 (emerald-200) | `--p-primary-active-color` |
| primaryContrast | #0F172A (slate-900) | `--p-primary-contrast-color` (text/icons on primary) |
| background | #020617 (slate-950) | `body` background, `--p-surface-950` |
| surface | #0F172A (slate-900) | `--p-content-background` (cards, dialogs, menus, overlays) |
| surfaceHover | #1E293B (slate-800) | `--p-content-hover-background`, `--p-surface-800` |
| border | #334155 (slate-700) | `--p-content-border-color` (borders, dividers) |
| fieldBackground | #020617 (slate-950) | `--p-form-field-background` |
| fieldBorder | #475569 (slate-600) | `--p-form-field-border-color` |
| fieldHoverBorder | #64748B (slate-500) | `--p-form-field-hover-border-color` |
| fieldFocusBorder | #34D399 | `--p-form-field-focus-border-color` |
| fieldDisabledBackground | #334155 (slate-700) | `--p-form-field-disabled-background` |
| fieldDisabledText | #94A3B8 (slate-400) | `--p-form-field-disabled-color` |
| text | #FFFFFF | `--p-text-color` |
| textMuted | #94A3B8 (slate-400) | `--p-text-muted-color` (secondary text, subtitles, labels) |
| placeholder | #64748B (slate-500) | `--p-form-field-placeholder-color` |
| highlight | #34D399 @16% = `Color(0x2934D399)` | `--p-highlight-background` (selected items) |
| highlightText | #FFFFFF @87% = `Color(0xDEFFFFFF)` | `--p-highlight-color` |
| success | #4ADE80 | green-400 |
| warning | #FB923C | orange-400 |
| danger | #F87171 | `--p-red-400` (errors, invalid fields, negative values) |
| info | #38BDF8 | sky-400 |
| mask | #000000 @60% (*) | dialog/drawer backdrop |

### 6.C `lib/theme/app_colors.dart` (create exactly this shape)
```dart
abstract final class AppColors {
  // Raw palette: EVERY emerald50..emerald950 and slate50..slate950 shade from 6.A as `static const`, e.g.:
  static const emerald50 = Color(0xFFECFDF5);
  static const slate950 = Color(0xFF020617);
  // Semantic tokens (6.B) — widgets use ONLY these, never raw shades (except accents below):
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
  static const fieldHoverBorder = Color(0xFF64748B);
  static const fieldDisabledBackground = Color(0xFF334155);
  static const text = Color(0xFFFFFFFF);
  static const textMuted = Color(0xFF94A3B8);
  static const placeholder = Color(0xFF64748B);
  static const highlight = Color(0x2934D399);
  static const highlightText = Color(0xDEFFFFFF);
  static const success = Color(0xFF4ADE80);
  static const warning = Color(0xFFFB923C);
  static const danger = Color(0xFFF87171);
  static const info = Color(0xFF38BDF8);
  static const mask = Color(0x99000000);
  static const slate300 = Color(0xFFCBD5E1), slate600 = Color(0xFF475569);
  static const red200 = Color(0xFFFECACA), red300 = Color(0xFFFCA5A5), red950 = Color(0xFF450A0A), emerald700 = Color(0xFF047857);
  static const sky400 = Color(0xFF38BDF8), orange400 = Color(0xFFFB923C), violet400 = Color(0xFFA78BFA), pink400 = Color(0xFFF472B6), yellow400 = Color(0xFFFACC15);
}

abstract final class AppRadius {
  static const checkbox = 4.0; // Aura border.radius.sm (checkbox, menu/list options, heatmap cells)
  static const field = 6.0;    // Aura border.radius.md (inputs, buttons, list rows, tags, tooltips, menus)
  static const card = 12.0;    // Aura border.radius.xl (cards, dialogs, panels, bottom sheets)
}

abstract final class AppSpacing {
  static const xs = 4.0, sm = 8.0, md = 12.0, lg = 16.0, card = 20.0, xl = 24.0, xxl = 32.0;
}

abstract final class Breakpoints {
  static const sm = 640.0, md = 768.0, lg = 1024.0, xl = 1280.0, xxl = 1536.0; // Tailwind sm/md/lg/xl/2xl
}
```

### 6.D Typography (Tailwind scale, logical px = CSS px)
| Tailwind | size / line height | use |
|---|---|---|
| text-xs | 12 / 16 | chart & axis labels, captions, small badges |
| text-sm | 14 / 20 | tags, helper text, table secondary text, small buttons |
| text-base | 16 / 24 | DEFAULT body, inputs, buttons, list rows |
| text-lg | 18 / 28 | section headers |
| text-xl | 20 / 28 | card & dialog titles (w500 card, w600 dialog) |
| text-2xl | 24 / 32 | key figures (w600) |
| text-3xl | 30 / 36 | page titles (w600), only if the Web app uses them |
- Flutter line height = `height: lineHeight / fontSize` (e.g. 16/24 -> `height: 1.5`). Put the scale in `lib/theme/app_text.dart` (`AppText.xs`, `sm`, `base`, `lg`, `xl`, `xxl`, `xxxl`) and wire it into `ThemeData.textTheme` (bodyMedium = base, bodySmall = sm, labelLarge = base w500, titleLarge = xl w500, headlineSmall = 2xl w600).
- Weights: 400 (body), 500 (buttons, card titles, labels), 600 (key figures, dialog titles, table headers), 700 (tags/badges only (*)). Never other weights.
- Default text color `AppColors.text`; secondary `AppColors.textMuted`. Never pure grey, never opacity hacks.

### 6.E Spacing & sizing
- Scale (4px base): 4 / 8 / 12 / 16 / 20 / 24 / 32 (Tailwind `1 / 2 / 3 / 4 / 5 / 6 / 8`). Never invent values outside the scale (except component tokens below).
- Card padding 20 (Aura card body `1.25rem`), gap 8 inside the card header, 16 between blocks/cards (`gap-4`), 8 between form controls (`gap-2`).
- Custom containers (Web `w-full bg-[#0F172A] border border-[#334155] rounded-xl p-4 md:p-6`): padding 16, 24 from `Breakpoints.md`.
- Page padding 16, 32 from `Breakpoints.md`.
- Control height: 40 (buttons, inputs, selects). Small 32, large 48 (Aura sm/lg).
- Minimum touch target 40x40 (keep visuals at Web size; extend hit area with padding when needed).

### 6.F Elevation, motion, states
- No Material elevation/tint anywhere: `elevation: 0`, `surfaceTintColor: Colors.transparent`, `shadowColor: Colors.transparent` (Aura dark shadows are invisible on slate-950). Overlays (dialogs, menus, tooltips) may use `BoxShadow(color: Color(0x66000000), blurRadius: 12, offset: Offset(0, 4))` (= Web `0 4px 12px rgba(0,0,0,.4)`).
- No ripple: `splashFactory: NoSplash.splashFactory`, `overlayColor` transparent; all state feedback via color changes (Aura behaviour).
- Transitions 150-200ms `Curves.easeOut` (Aura `transition.duration: 0.2s`) via `AnimatedContainer` / `AnimatedOpacity`.
- States: hover/pressed per component (see 9); disabled = 60% opacity (`Opacity(opacity: 0.6)`, Aura `disabled.opacity`); invalid = border `danger`; focus (keyboard) = 1px `primary` outline, offset 2 (Aura focus ring) — use `FocusableActionDetector` / `focusColor` only where Material does not cover it.

### 6.G Dark mode
- Always on: `brightness: Brightness.dark`, `themeMode: ThemeMode.dark`, no light theme, no toggle.
- System bars: `AnnotatedRegion<SystemUiOverlayStyle>(value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent, systemNavigationBarColor: AppColors.background, systemNavigationBarIconBrightness: Brightness.light))`. Android 15+ edge-to-edge: content inside `SafeArea`.

### 6.H Token source of truth (when unsure)
- Aura component tokens live in the npm package `@primeuix/themes`: `node_modules/@primeuix/themes/dist/aura/<component>/index.mjs` (in `WEB_DIR`, or `npm i --no-save @primeuix/themes` in a scratch folder). `rem` -> px x16. `{primary.color}` / `{surface.800}` / `{content.border.color}` -> the tables above. `color-mix(in srgb, X, transparent N%)` -> `X.withValues(alpha: 1 - N/100)`.
- Visual reference: https://primereact.dev/ showcase in dark mode with emerald primary + slate surface.

## 7. FONTS & ICONS
- Font: Inter, bundled as assets (NOT the `google_fonts` package: no runtime download, works offline, identical on every device). Files `assets/fonts/Inter_400Regular.ttf`, `Inter_500Medium.ttf`, `Inter_600SemiBold.ttf`, `Inter_700Bold.ttf` (from the npm package `@expo-google-fonts/inter` or Google Fonts), declared in `pubspec.yaml` as family `Inter` with `weight: 400/500/600/700`; `ThemeData(fontFamily: 'Inter')`. Web uses `font-family: 'Inter', system-ui, sans-serif` — same font, same metrics.
- Icons: PrimeIcons, identical to the Web app's `@primeicons/react` (Web: `import { Check } from '@primeicons/react/check'` -> Flutter: `PrimeIcon.check`; kebab-case names -> camelCase enum values, file names stay kebab-case). Generate SVG files from the npm package `@primeicons/core` (each icon module exports `{ svg: { viewBox }, nodes: [[tag, attrs]] }`; write `<svg xmlns="http://www.w3.org/2000/svg" viewBox=...>` with the nodes, replacing `currentColor` with `#000000`) into `assets/icons/<name>.svg`. Render with `flutter_svg`:
  ```dart
  enum PrimeIcon {
    check('check'), plus('plus'), trash('trash'), angleDown('angle-down'), bars('bars'), times('times');
    const PrimeIcon(this.file);
    final String file;
  }

  class AppIcon extends StatelessWidget {
    const AppIcon(this.icon, {super.key, required this.color, this.size = 16});
    final PrimeIcon icon;
    final Color color;
    final double size;

    @override
    Widget build(BuildContext context) => SvgPicture.asset(
          'assets/icons/${icon.file}.svg',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        );
  }
  ```
- Icon sizes: 16 default (Aura `1rem`), 14 inside checkboxes/small buttons, 12 inside tags, 20 in the top bar/navigation.
- Add new icons by generating their SVG + adding an enum value. Never use Material `Icons.*` for visible UI icons (SVG icons do not inherit `IconTheme`: always pass the color).

## 8. THEME (`lib/theme/app_theme.dart`) — MANDATORY SETTINGS
`ThemeData buildAppTheme()` sets:
- `useMaterial3: true`, `brightness: Brightness.dark`, `fontFamily: 'Inter'`, `scaffoldBackgroundColor: AppColors.background`, `splashFactory: NoSplash.splashFactory`, `highlightColor`/`splashColor`/`hoverColor` transparent, `visualDensity: VisualDensity.standard`, `materialTapTargetSize: MaterialTapTargetSize.shrinkWrap`.
- `colorScheme: ColorScheme.dark(primary: primary, onPrimary: primaryContrast, secondary: primary, onSecondary: primaryContrast, surface: surface, onSurface: text, onSurfaceVariant: textMuted, surfaceContainerLowest: background, surfaceContainerLow: surface, surfaceContainer: surface, surfaceContainerHigh: surfaceHover, surfaceContainerHighest: surfaceHover, error: danger, onError: AppColors.red950, outline: fieldBorder, outlineVariant: border, surfaceTint: Colors.transparent, shadow: Colors.black, scrim: mask)`.
- `textTheme`: from `AppText` (6.D), all colors `text` unless stated.
- `textSelectionTheme`: cursor + handles `primary`, selection `primary.withValues(alpha: 0.3)`.
- `inputDecorationTheme`: `filled: true`, `fillColor: fieldBackground`, `isDense: true`, `contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)` (verified: total height 40 with 16/24 text), `border`/`enabledBorder`: `OutlineInputBorder(borderRadius: 6, borderSide: fieldBorder 1)`, `focusedBorder`: side `primary` 1, `errorBorder`/`focusedErrorBorder`: side `danger` 1, `disabledBorder`: side `fieldBorder`, `hintStyle`: placeholder 16, `labelStyle`/`floatingLabelStyle`: textMuted 16 (prefer a separate label `Text` above the field like the Web `<label>`; no floating labels), `errorStyle`: danger 14, `helperStyle`: textMuted 14, `prefixIconColor`/`suffixIconColor`: textMuted.
- `filledButtonTheme` (= PrimeReact primary `<Button>`): background resolves disabled -> primary 60%, pressed -> primaryActive, hovered -> primaryHover, else primary; foreground primaryContrast; border 1 same color as background; `overlayColor` transparent; `elevation` 0; padding h12 v8; `minimumSize: Size(0, 40)`; shape radius 6; text Inter 16 w500; icon gap 8 (`FilledButton.icon` + `iconAlignment`); `tapTargetSize: shrinkWrap`.
- `outlinedButtonTheme` (= `variant="outlined"`): transparent background, border emerald-700 #047857 (*), foreground primary, overlay hovered primary 4% / pressed primary 16%, same size/shape/text as filled.
- `textButtonTheme` (= `variant="text"`): same padding/shape/text, `minimumSize: Size(40, 40)`, foreground primary, overlay hovered primary 4% / pressed primary 16%.
- Helpers in `app_theme.dart`:
  - `ButtonStyle textButtonSeverity(Color c)`: foreground c, overlay pressed c 16% / hovered c 4% / else transparent.
  - `ButtonStyle filledButtonSeverity(Severity s)`: `Severity.secondary` -> bg slate-800 #1E293B, hover slate-700, pressed slate-600, fg slate-300 (*); `Severity.danger` -> bg red-400, hover red-300, pressed red-200, fg red-950 (*); `success`/`warn`/`info` analog with the 400/300/200 shades and the 950 shade as foreground (*).
  - `ButtonStyle buttonSize(ButtonSize s)`: small -> padding h10 v6, min height 32, text 14; large -> padding h14 v10, min height 48, text 18.
- `checkboxTheme` (only if Material `Checkbox` is used anywhere; prefer `AppCheckbox`), `switchTheme` (= PrimeReact `ToggleSwitch`: track off fieldBorder #475569 / on primary, thumb off slate-400 / on primaryContrast (*), no outline), `radioTheme` (fill primary when selected, fieldBorder otherwise).
- `dialogTheme`: background surface, `shape` radius 12 + side border 1, `elevation` 0, `barrierColor` mask, `titleTextStyle` 20 w600 text, `contentTextStyle` 16 text, `insetPadding` 16.
- `bottomSheetTheme`: background surface, top radius 12, side border, `modalBarrierColor` mask, `showDragHandle: true`, `dragHandleColor` border.
- `menuTheme` / `dropdownMenuTheme` / `popupMenuTheme`: background surface, border 1, radius 6, padding 4, elevation 0, item text 16 text, item hover/focus background surfaceHover, selected item background highlight + text highlightText.
- `snackBarTheme`: background surface, content 16 text, shape radius 6 + side border, `behavior: floating`, `elevation` 0, `actionTextColor` primary (severity variants via `AppToast`, see 9).
- `dividerTheme`: color border, thickness 1, space 1.
- `tooltipTheme` (= PrimeReact Tooltip): background slate-700 #334155, text 14 white, padding h12 v8, radius 6, `waitDuration` 500ms (*).
- `progressIndicatorTheme`: color primary, `linearTrackColor` border, `circularTrackColor` border, `linearMinHeight` 4 (Web ProgressBar is 20 tall only when it shows a label).
- `chipTheme` (filter chips): background surfaceHover, selected highlight, label 14 text, side none, radius 16 (*).
- `navigationBarTheme`: background surface, indicator highlight, `indicatorShape` radius 6, labels 12 (selected primary w500, unselected textMuted), height 64, elevation 0.
- `navigationRailTheme` / `drawerTheme`: background surface, indicator highlight, `drawerTheme.shape` none, `width` 280, `scrimColor` mask.
- `appBarTheme`: background surface, foreground text, elevation 0, `scrolledUnderElevation` 0, `surfaceTintColor` transparent, `centerTitle: false`, title 20 w500, `shape: Border(bottom: BorderSide(color: border))`, `systemOverlayStyle` light (6.G).
- `listTileTheme`: `tileColor` transparent, `selectedTileColor` highlight, `selectedColor` highlightText, `iconColor` textMuted, `textColor` text, `contentPadding` h12, `shape` radius 6, `minVerticalPadding` 8, `dense: true`.
- `dataTableTheme` (= PrimeReact DataTable): `headingRowColor` surface, heading text 16 w600 text, `dataRowColor` hovered/selected -> surfaceHover/highlight, `dividerThickness` 1 border, cell padding h16 v12 (*).
- `scrollbarTheme`: thumb border color, radius 6, thickness 6.
- Use `Color.withValues(alpha: x)` (never the deprecated `withOpacity`). Use `WidgetStateProperty.resolveWith` (never `MaterialStateProperty`).

## 9. COMPONENT MAPPING (PrimeReact 11 -> Flutter) — build these in `lib/widgets/`
PrimeReact 11 composes components from parts (`<Card.Root><Card.Body><Card.Header><Card.Title/>...`). In Flutter each multi-part component becomes ONE widget with named parameters (no part widgets).
| PrimeReact (Web) | Flutter | Details |
|---|---|---|
| `<Button>` | `FilledButton` / `FilledButton.icon(icon: AppIcon(..., color: AppColors.primaryContrast), label: Text(...))` | themed in 8; `loading` -> replace icon with 16px `CircularProgressIndicator(strokeWidth: 2, color: primaryContrast)` and disable |
| `<Button severity="secondary\|danger\|...">` | `FilledButton(style: filledButtonSeverity(...))` | |
| `<Button variant="outlined">` | `OutlinedButton` | |
| `<Button variant="text">` / icon-only | `TextButton` (+ `textButtonSeverity(c)`), icon-only wrapped in `Semantics(label:, button: true)` + `Tooltip` | min 40x40 |
| `<Button rounded>` | shape `StadiumBorder()` | |
| `<InputText>` | `AppTextField` = label `Text` (14 w500 text, gap 8) + `TextField` (style 16 text) + optional helper/error `Text` 14 | `w-full` -> stretch; inside `Row` wrap in `Expanded` (= `flex-1 min-w-0`) |
| `<Password>` | `AppTextField(obscure: true)` + suffix `TextButton` with `PrimeIcon.eye` / `eyeSlash` | |
| `<InputNumber>` | `AppTextField` + `keyboardType: TextInputType.numberWithOptions(decimal: true)` + `FilteringTextInputFormatter` + `NumberFormat` from `intl` | currency formatting identical to Web (`Intl.NumberFormat`) |
| `<Textarea>` | `TextField(minLines: 3, maxLines: null)` | |
| `<Select>` / `<Dropdown>` | themed `DropdownMenu<T>` (`expandedInsets: EdgeInsets.zero` for full width, `trailingIcon: AppIcon(PrimeIcon.angleDown, color: textMuted)`) | overlay: surface, border, radius 6, option padding h12 v8, option radius 4, focused option surfaceHover, selected option highlight (*) |
| `<MultiSelect>` | `showModalBottomSheet` with checkbox list (`AppCheckbox`) + chips summary in the field | |
| `<DatePicker>` / `<Calendar>` | `showDatePicker` themed via `datePickerTheme` (surface, header surface, selected day primary bg + primaryContrast text, today border primary, radius 12) | |
| `<Checkbox.Root checked onCheckedChange><Checkbox.Box><Checkbox.Indicator match="checked"><Check/>` | `AppCheckbox(value, onChanged, label)` | 20x20, radius 4, border fieldBorder 1 + background fieldBackground; hover border fieldHoverBorder; checked = primary fill + primary border + `PrimeIcon.check` 14px in primaryContrast; invalid border danger; disabled bg fieldDisabledBackground; 10px padding as touch area; `AnimatedContainer` 150ms; `Semantics(checked:, label:)`; tapping the label toggles too |
| `<RadioButton>` | `AppRadio` | 20x20 circle, border fieldBorder 1, bg fieldBackground; selected = primary bg + primary border + centered 8px primaryContrast dot (*); `Semantics(inMutuallyExclusiveGroup: true, checked:)` |
| `<ToggleSwitch>` | `Switch` themed (8) | 40x24 visual (*) |
| `<Card.Root>` + `Card.Header` / `Card.Title` / `Card.Subtitle` / `Card.Content` / `Card.Footer` | `AppCard(title, subtitle, aside, child, footer)` | `Container(padding: 20, BoxDecoration(color: surface, borderRadius: 12))`, NO border and NO shadow (Aura dark card); header = `Wrap(alignment: spaceBetween, crossAxisAlignment: end, spacing 8, runSpacing 8)`: left `Column(title 20 w500 text, subtitle 16 textMuted, gap 8)`, right optional `aside` (key figure 24 w600 + colored delta); `child` 16 below the header; `footer` 16 below the child (buttons `Row(spacing: 8)`) |
| custom container `bg-[#0F172A] border border-[#334155] rounded-xl p-4 md:p-6` | `AppPanel(child)` | surface bg, border 1, radius 12, padding 16 / 24 from md |
| `<Panel header toggleable>` | `AppPanel(header:, collapsible: true)` | header row 16 w600, toggle `TextButton` with `PrimeIcon.minus/plus`, `AnimatedSize` |
| `<Accordion>` | list of `AppPanel(collapsible: true)` with only one expanded | divider border between |
| `<Divider>` | `Divider()` / `VerticalDivider()` | |
| list rows (todo items, etc.) | `AppListRow` = `Container(border 1 border, radius 6, padding h6 v2)` + `Row(spacing: 6)` | selected -> highlight bg; done text textMuted + `TextDecoration.lineThrough` with `decorationColor` textMuted |
| `<DataTable>` | `AppDataTable`: below `Breakpoints.md` render each row as a stacked `AppListRow` card (label textMuted 14 / value 16) = Web responsive "stack" layout; from md a `DataTable` inside horizontal `SingleChildScrollView` (= `scrollable`) | header 16 w600, row hover surfaceHover, borders border, sort icon `PrimeIcon.sortAlt`, paginator `Row` of `TextButton`s (current page highlight bg) |
| `<Paginator>` | `AppPaginator` | buttons 40x40 radius 6 text, current page highlight + highlightText |
| `<Dialog header visible onHide breakpoints>` | `showAppDialog(...)` -> themed `Dialog` | header padding 20 (title 20 w600 + close `TextButton` `PrimeIcon.times`), content padding `fromLTRB(20, 0, 20, 20)`, footer padding `fromLTRB(20, 0, 20, 20)` buttons right-aligned `Row(spacing: 8)`; width `min(screen - 32, maxWidth)` with maxWidth 512 default; below `Breakpoints.sm` use `Dialog.fullscreen` only if the Web `breakpoints` prop makes it 100vw |
| `<ConfirmDialog>` | `showAppConfirm(title, message, acceptLabel, rejectLabel, severity)` returning `Future<bool>` | reject = text button, accept = filled (danger severity for destructive) |
| `<Sidebar>` / `<Drawer>` | `Drawer` (left nav) or `showModalBottomSheet` (bottom) | surface bg, border on the inner edge, mask barrier |
| `<Toast>` | `AppToast.show(context, severity, summary, detail)` via `ScaffoldMessenger` + themed `SnackBar` | Aura dark toast (*): bg = status color 16% alpha over surface, border status color 36% alpha, text summary 16 w500 + detail 14 in status color, leading status icon (`check`/`info-circle`/`exclamation-triangle`/`times-circle`), radius 6, close button; top on Web -> `SnackBarBehavior.floating` with margin; duration 3s |
| `<Message>` / `<InlineMessage>` | `AppMessage(severity, text)` | same colors as toast, inline `Container` radius 6 padding h12 v8 |
| `<Tag>` / `<Badge>` | `AppTag(text, severity)` | `Container(padding h8 v4, radius 6)`, text 14 w700 (*); primary: bg emerald-500 16% / text emerald-300 (*); success/info/warn/danger: same pattern with the 500 bg 16% + 300 text; secondary: bg slate-800, text slate-300; `rounded` -> radius 999 |
| `<Chip>` | `Chip` themed | |
| `<Avatar>` | `CircleAvatar(backgroundColor: border, foregroundColor: text)` 32/40/48 | |
| `<ProgressBar>` | `LinearProgressIndicator` (radius 6 via `ClipRRect`) | |
| `<ProgressSpinner>` | `CircularProgressIndicator(strokeWidth: 2)` | |
| `<Skeleton>` | `AppSkeleton(width?, height, radius 6)` | bg white 6%, pulse to white 4% with `AnimatedOpacity` 1s loop (*) |
| `<TabView>` / `<Tabs>` | `TabBar` themed | label 16 w600 textMuted, selected primary, indicator 1px primary, divider border, no ripple |
| `<Menu>` / `<TieredMenu>` | `MenuAnchor` themed | item padding h12 v8, icon 16 textMuted, gap 8 |
| `<Breadcrumb>` | `Row` of `TextButton`s + `PrimeIcon.angleRight` textMuted 12 | |
| `<Tooltip>` | `Tooltip` themed | |
| `<FileUpload>` | `file_picker` package only when requested; UI = `AppPanel` + filled button | ask before adding the package |
| `<Image>` | `Image.network` with `loadingBuilder` -> `AppSkeleton`, `errorBuilder` -> muted icon | radius via `ClipRRect` |
- Prefer composing these widgets over adding UI kits. NO third-party UI kits (GetWidget, VelocityX, shadcn ports, etc.).
- Every widget takes data + callbacks only (no providers inside design-system widgets) and has `const` constructors where possible.

## 10. RESPONSIVE FLEX LAYOUT (NON-NEGOTIABLE)
- Flutter's `Row`/`Column`/`Flex`/`Expanded`/`Flexible`/`Wrap` ARE the flexbox equivalent; build every layout with them. Use `spacing:` on `Row`/`Column`/`Wrap` instead of `SizedBox` gaps. `GridView` only when a true 2D grid is unavoidable (Web rule: CSS Grid only when unavoidable).
- Breakpoints mirror Tailwind exactly (`Breakpoints` in 6.C), measured on the window width: `MediaQuery.sizeOf(context).width` for page-level decisions, `LayoutBuilder` for component-level decisions.
- Mobile-first: default single column (`Column(crossAxisAlignment: CrossAxisAlignment.stretch)`), switch to `Row` at the SAME breakpoint the Web app uses.
- Tailwind -> Flutter translation table:
| Tailwind | Flutter |
|---|---|
| `flex flex-col gap-4` | `Column(crossAxisAlignment: stretch, spacing: 16)` |
| `flex flex-row gap-2` | `Row(spacing: 8)` |
| `flex-col md:flex-row` | `width >= Breakpoints.md ? Row(...) : Column(...)` (extract a small `ResponsiveFlex(breakpoint:, spacing:, children:)` widget that switches `Flex.direction`) |
| `flex-1` | `Expanded()` (in a Column fallback: no Expanded, children stretch) |
| `flex-[2]` / `xl:flex-[2]` | `Expanded(flex: 2)` |
| `min-w-0` | implicit with `Expanded`; text inside uses `overflow: TextOverflow.ellipsis` / `softWrap` |
| `flex-wrap gap-4` | `Wrap(spacing: 16, runSpacing: 16)` |
| `basis-full lg:basis-[calc(50%-0.5rem)]` | `LayoutBuilder` -> child width `w >= Breakpoints.lg ? (c.maxWidth - 16) / 2 : c.maxWidth` inside `Wrap` |
| `items-center` / `items-end` / `items-start` | `crossAxisAlignment: center / end / start` (Wrap: `crossAxisAlignment: WrapCrossAlignment.*`) |
| `justify-between` / `justify-center` / `justify-end` | `mainAxisAlignment: spaceBetween / center / end` (Wrap: `alignment: WrapAlignment.*`) |
| `w-full` | `crossAxisAlignment: stretch` on the parent or `SizedBox(width: double.infinity)` |
| `max-w-screen-xl mx-auto` | `Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: Breakpoints.xl), child: ...))` |
| `hidden md:flex` | `if (width >= Breakpoints.md) widget` (null-aware/collection-if) |
| `p-4 md:p-8` | `EdgeInsets.all(width >= Breakpoints.md ? 32 : 16)` |
| `h-[55vh] min-h-80` | `max(320, MediaQuery.sizeOf(context).height * 0.55)` |
| `truncate` | `Text(maxLines: 1, overflow: TextOverflow.ellipsis)` |
- NO fixed widths for containers (use `Expanded`, `Flexible`, `double.infinity`, `ConstrainedBox(maxWidth)`); heights only where content requires it (charts, skeletons, controls).
- Lists with many items -> `ListView.builder` / `SliverList.builder`; never `Column` of 50+ children.
- Orientation: allow portrait and landscape (no `setPreferredOrientations`); tablets/landscape reach the `md`/`lg`/`xl` layouts. Respect text scaling (`MediaQuery.textScalerOf`), never clamp it below 1.0; layouts must not overflow at 1.3x.

## 11. NAVIGATION & PAGE SHELL
- Routing: `go_router` with the same paths as the Web app (`/`, `/dashboard`, `/settings`, ...); `ShellRoute` for the app shell; deep links work the same as Web URLs.
- Shell (mirror the Web navigation when it exists; default otherwise):
  - `< Breakpoints.md`: `Scaffold(appBar: AppTopBar, drawer: AppNavDrawer)` — top bar = APP_NAME 20 w500 + menu `TextButton(PrimeIcon.bars)` (Web Sidebar/Drawer on small screens). If the app has 2-5 primary destinations, use a bottom `NavigationBar` instead of the drawer.
  - `>= Breakpoints.md`: `NavigationRail` (labels shown from `Breakpoints.lg`) or a persistent side nav `ConstrainedBox(maxWidth: 256)` (= Web `w-64` sidebar) with a right border.
  - Nav items: `Row(spacing: 8)` icon 16 + label 16, padding h12 v8, radius 6, hover surfaceHover, active highlight + highlightText.
- Page: `Scaffold` -> `SafeArea` -> `SingleChildScrollView(padding: EdgeInsets.all(width >= Breakpoints.md ? 32 : 16))` -> `Center` + `ConstrainedBox(maxWidth: Breakpoints.xl)` -> `Column(stretch, spacing: 16)`. Page title (if the Web page has one) 24 w600 + optional subtitle 16 textMuted.
- Pull-to-refresh: `RefreshIndicator(color: primary, backgroundColor: surface)` on list/data pages.
- States on every data screen: loading (`AppSkeleton`s shaped like the content), empty (`AppPanel` with muted icon 32 + text 16 textMuted + optional primary action), error (`AppMessage(danger)` + retry button). Same texts as Web.

## 12. ACCESSIBILITY (A11y)
- Every interactive widget has a semantic label (`Semantics`, `tooltip:`, or visible text); icon-only buttons always `Semantics(label:, button: true)` + `Tooltip`.
- Contrast: only the token pairs above (all pass WCAG AA on surface/background); never put textMuted on surfaceHover for body text.
- Touch targets >= 40x40; focus order follows visual order; `FocusTraversalGroup` per form.
- Charts: `Semantics(label: '<what the chart shows>')` (= Web `aria-label` / `aria.enabled`).
- Form errors announced: error text inside the field's `Semantics` (`TextField` `errorText` does this).

## 13. TECHNICAL ARCHITECTURE & CODING STANDARDS
1. Flutter stable 3.41+, Dart 3.11+ (installed: Flutter 3.41.4 / Dart 3.11.1). Use modern Dart: records, patterns, `switch` expressions, sealed classes, null-aware collection elements (`?widget`), `Row/Column spacing`. No experimental language flags.
2. Structure:
   ```
   lib/
   ├── main.dart                 # runApp(ProviderScope(child: App())); App: AnnotatedRegion + MaterialApp.router(theme: buildAppTheme(), themeMode: dark)
   ├── app_router.dart           # GoRouter (same paths as Web)
   ├── config.dart               # const apiBaseUrl = String.fromEnvironment('API_BASE_URL')
   ├── theme/app_colors.dart     # AppColors, AppRadius, AppSpacing, Breakpoints
   ├── theme/app_text.dart       # AppText type scale
   ├── theme/app_theme.dart      # buildAppTheme(), textButtonSeverity(), filledButtonSeverity(), buttonSize()
   ├── widgets/                  # design-system widgets (section 9), one file per widget, snake_case
   ├── pages/                    # screens: <name>_page.dart, page-private widgets in pages/<name>/
   ├── models/                   # immutable data classes (mirror backend DTOs / Web TS interfaces 1:1, same field names in camelCase)
   ├── api/                      # api_client.dart + <feature>_api.dart
   ├── state/                    # Riverpod providers / notifiers (<feature>_provider.dart)
   └── charts/                   # only when IS_CHARTS_NEEDED: true
   ```
3. State: `StatefulWidget` for local UI state (form fields, toggles, expanded panels); `flutter_riverpod` 3.x (Notifier / AsyncNotifier, no code generation, no legacy `StateNotifier`/`StateProvider`) for shared/app state (= Web Zustand / Context). One provider per Web store, same name semantics.
4. Models: immutable classes, `const` constructors, `final` fields, hand-written `factory X.fromJson(Map<String, Object?> json)` / `Map<String, Object?> toJson()`, `copyWith`, `==`/`hashCode` (or records for simple value types). No `freezed`/`json_serializable` code generation. Dates as `DateTime` (ISO-8601 strings on the wire), money as `int` minor units (cents) unless the backend/Web model uses something else — then match it exactly. Never `double` for money arithmetic.
5. API: `ApiClient` on top of `package:http` (`get/post/put/delete<T>(path, {body, fromJson})`), base URL from `config.dart`, JSON headers, timeouts 15s, non-2xx -> typed `ApiException(statusCode, message)`; auth token (when needed) injected from a provider; `flutter_secure_storage` for tokens only when auth is requested. No fetching in widgets' `build` — providers own data loading.
6. Errors: never swallow exceptions; show `AppToast`/`AppMessage` with the same texts as Web; log with `debugPrint` only in debug.
7. Lints: `flutter_lints` + rules in 15.3; `flutter analyze` must report "No issues found!". Format with `dart format -l 140` (also `formatter: page_width: 140` in `analysis_options.yaml`).
8. Every package you `import` must be listed directly in `pubspec.yaml` (e.g. `syncfusion_flutter_core` for `package:syncfusion_flutter_core/theme.dart`), otherwise `depend_on_referenced_packages` fails. Allowed packages: `flutter_svg`, `flutter_riverpod`, `go_router`, `http`, `intl` (+ chart packages when `IS_CHARTS_NEEDED: true`). Anything else: ask first.
9. Localization: texts identical to the Web app; if the Web app is multi-language, use `flutter_localizations` + ARB files with the same keys. Number/date/currency formatting with `intl` using the same locale and pattern as Web `Intl.NumberFormat` / `Intl.DateTimeFormat`.
10. Tests: widget smoke test per page (pumps with `ProviderScope` overrides + fake API), unit tests for models (`fromJson`/`toJson` round trip) and pure helpers.
11. Visual verification: `flutter build web --release`, serve `build/web` on a FREE port (check with `curl` first — another local app may already listen on common ports; verify the served `<title>` is APP_NAME) with `npx -y http-server -p 8790 -s -c-1 build/web`, and screenshot with `puppeteer-core` driving the installed Chrome (wait for `flutter-view` + ~2.5s; plain `chrome --headless --screenshot` captures a blank page before Flutter renders). Screenshot at 390px (phone), 768px (tablet) and 1600px (desktop) width. Flutter web uses the same rendering engine (Skia/Impeller-equivalent CanvasKit) as mobile, so it is a faithful preview. Compare side by side with the Web (React) app at the same widths.
12. App identity: Android `android:label` in `android/app/src/main/AndroidManifest.xml` and iOS `CFBundleDisplayName` = APP_NAME; Android `minSdk` = Flutter default; launcher icon + splash (`flutter_launcher_icons` / `flutter_native_splash`, dev deps) only when the user provides an icon — splash background `#020617`.

## 14. ENVIRONMENT / RUN COMMANDS
- Run: `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080` (Android emulator) / `http://localhost:8080` (iOS simulator / web preview).
- Optional `APP_DIR/.vscode/launch.json` / IntelliJ run configuration "dev" with the same `--dart-define`.
- Release: `flutter build apk --release --dart-define=API_BASE_URL=<prod>`, `flutter build ipa --dart-define=API_BASE_URL=<prod>` (iOS build only on macOS).

## 15. PROJECT BOOTSTRAP (FIRST RUN ONLY — skip if `APP_DIR/pubspec.yaml` exists)
STATUS: executed on 2026-11-04 (Flutter 3.41.4), then reduced on user request to a BARE TEMPLATE: `lib/main.dart` (dark background + "hello") + `lib/theme/` (app_colors, app_text, app_theme = sections 6 and 8) + Inter fonts. No packages, widgets, icons, router, state or API client exist yet: add each (steps 2, 5, 6 and section 9) only when a feature needs it, never preemptively.
Platform files are CRLF (`core.autocrlf=true`): script edits must handle `\r\n`.
1. Create: `flutter create --org <ORG> --project-name <PACKAGE_NAME> --platforms android,ios,web --empty <APP_DIR>` (web only for preview screenshots).
2. Dependencies: `flutter pub add flutter_svg flutter_riverpod go_router http intl` (+ chart packages only when `IS_CHARTS_NEEDED: true`). Dev: `flutter_lints` (already present).
3. `analysis_options.yaml`: `include: package:flutter_lints/flutter.yaml`; `formatter: page_width: 140`; `linter.rules`: `prefer_const_constructors`, `prefer_const_declarations`, `prefer_final_locals`, `prefer_final_fields`, `always_declare_return_types`, `avoid_print`, `use_super_parameters`, `unawaited_futures` (do NOT enable `require_trailing_commas`; the formatter manages commas at width 140).
4. Fonts: download Inter 400/500/600/700 TTFs into `assets/fonts/` (section 7) and declare them in `pubspec.yaml`.
5. Icons: add `tool/gen_icons.mjs` (Node, run from `APP_DIR`: `npm i --no-save @primeicons/core && node tool/gen_icons.mjs check plus trash angle-down bars times ...`) that writes `assets/icons/<name>.svg` for the requested names; declare `assets/icons/` in `pubspec.yaml`; keep the `PrimeIcon` enum in sync. Do not commit `node_modules/`.
6. Create the `lib/` structure (13.2) with: `theme/app_colors.dart`, `theme/app_text.dart`, `theme/app_theme.dart` (complete section 8), `widgets/app_icon.dart`, `app_card.dart`, `app_panel.dart`, `app_checkbox.dart`, `app_text_field.dart`, `app_tag.dart`, `app_toast.dart`, `app_skeleton.dart`, `config.dart`, `api/api_client.dart`, `app_router.dart`, `pages/home_page.dart` (placeholder screen showing an `AppCard` with a text field, primary + danger-text button, checkbox and tag so the theme can be checked visually), `main.dart`.
7. Set app name (Android `android:label`, iOS `CFBundleDisplayName`), lock nothing to portrait. Web preview: `web/index.html` `<meta name="theme-color" content="#020617">` and `body { background: #020617 }` to avoid a white flash.
8. Remove the default `test/widget_test.dart`; add `test/app_smoke_test.dart` that pumps the app and finds the home page.
9. `.gitignore`: keep Flutter defaults, add `node_modules/`.
10. Verify: `flutter pub get`, `dart format -l 140 .`, `flutter analyze` ("No issues found!"), `flutter test`, `flutter build web --release` + screenshots (13.11).

## 16. CHARTS SETUP (ONLY WHEN IS_CHARTS_NEEDED: true)
Skip this whole section when `IS_CHARTS_NEEDED: false`.

### A. Package & licensing
- `syncfusion_flutter_charts` (+ `syncfusion_flutter_sliders` for range/zoom sliders, + `syncfusion_flutter_core` for slider theming, + `syncfusion_flutter_gauges` only if a gauge is needed, + `intl` for number formats). It is the only Flutter chart package covering everything the Web ECharts setup uses (candlestick, combined series, multiple axes, trackball tooltips, range selection, pie/donut, gauge).
- LICENSE: Syncfusion is commercial. Free under the Syncfusion Community License (small companies/individuals, see their terms); otherwise a paid license is required. No runtime key/banner. Mention this to the user once when charts are first added.
- Do NOT use `fl_chart` (cannot combine chart types in one chart, no range selector) or any other chart package, and do NOT use WebView-based ECharts.
- Do NOT use Syncfusion's built-in palettes/themes for colors; every color comes from `ChartColors` (Web rule: no ECharts built-in themes, no hard-coded colors in option builders).
- Web principle "option builders are pure and platform-agnostic" -> in Flutter: data classes + derived-series helpers are pure Dart (no Flutter imports) in `<name>_data.dart`; chart widgets only map data to series using `chart_style.dart` helpers.

### B. File structure (`lib/charts/`) — mirrors Web `src/charts/`
```
lib/charts/
├── chart_colors.dart     # ChartColors: same names and values as the Web ChartColors contract (Web chartColors.ts)
├── chart_style.dart      # shared helpers (Web chartStyle.ts): chartLabelStyle, compactFormat, niceRange(), categoryAxis(), valueAxis(), chartTrackball(), chartTooltip(), ChartLegend/ChartLegendItem, areaGradient()
├── <name>_data.dart      # typed data classes + pure derived-series helpers (moving averages etc.) (Web options/<name> helpers)
└── <name>_chart.dart     # one widget per concrete chart (Web options/build<Name>Option), built only from chart_style helpers
```
There is no `echartsSetup.ts` / `EChart.tsx` equivalent: Syncfusion needs no registration, and each chart widget is the generic component.

### C. `ChartColors` (identical values to the Web app)
```dart
abstract final class ChartColors {
  static const primary = AppColors.primary;           // #34D399  --p-primary-color
  static const up = AppColors.primary;                // #34D399  positive / price up / growth
  static const down = AppColors.danger;               // #F87171  --p-red-400 negative / price down / loss
  static const text = AppColors.text;                 // #FFFFFF  --p-text-color
  static const muted = AppColors.textMuted;           // #94A3B8  axis labels, legend, secondary text
  static const border = AppColors.border;             // #334155  axis lines, split lines, tooltip border
  static const surface = AppColors.surface;           // #0F172A  tooltip background, slice/cell borders
  static const surfaceHover = AppColors.surfaceHover; // #1E293B  heatmap min, tracks, inactive areas
  static const inactive = AppColors.slate600;         // #475569  hidden legend items, disabled series, "Other"
  static const series = <Color>[AppColors.primary, AppColors.sky400, AppColors.orange400, AppColors.violet400, AppColors.pink400, AppColors.yellow400, AppColors.slate300];
  static const fontFamily = 'Inter';
}
```
Series palette order is fixed (series 1 = primary #34D399, 2 sky #38BDF8, 3 orange #FB923C, 4 violet #A78BFA, 5 pink #F472B6, 6 yellow #FACC15, 7 slate-300 #CBD5E1); more than 7 categories -> group the rest as "Other" in `inactive` instead of inventing colors. Transparency always via `withValues(alpha:)` (= Web `withAlpha()`).

### D. MANDATORY VISUAL STYLE (must match the Web ECharts look)
- Root: `SfCartesianChart(margin: EdgeInsets.zero, plotAreaBorderWidth: 0, backgroundColor: Colors.transparent, ...)` (the `AppCard` provides the surface). Animation: `animationDuration: 400` on every series (Syncfusion default is 1500 — always set it), `animationDuration: 0` for financial/real-time charts or series > 2000 points (= Web `animation: false`).
- Spacing (= Web grid `left/right 8`, `top 36 with legend`, `bottom 48 with slider`): chart margin zero; legend is a separate widget above (gap 8), range selector a separate widget below (gap 8).
- Category axis (`categoryAxis()`): `axisLine: AxisLine(color: border, width: 1)`, `majorTickLines: MajorTickLines(size: 0)`, `majorGridLines: MajorGridLines(width: 0)`, `labelStyle: chartLabelStyle` (muted, 12, Inter), `edgeLabelPlacement: EdgeLabelPlacement.shift`, `labelIntersectAction: AxisLabelIntersectAction.hide`, `labelPlacement: LabelPlacement.betweenTicks` for bar/candlestick (= Web `boundaryGap: true`), `LabelPlacement.onTicks` for line/area (= `boundaryGap: false`). In multi-panel charts only the bottom panel shows the category axis (`isVisible: false` on the others).
- Value axis (`valueAxis()`): `axisLine: AxisLine(width: 0)`, `majorTickLines: MajorTickLines(size: 0)`, `majorGridLines: MajorGridLines(color: border, width: 1, dashArray: [4, 4])` (= Web dashed split lines), `labelStyle: chartLabelStyle`, `edgeLabelPlacement: shift`, `numberFormat: compactFormat` (= Web `formatCompact`, `NumberFormat.compact(locale: 'en')` with max 1 fraction digit), `labelsExtent: chartValueAxisExtent`. `opposedPosition: true` (right side) for financial charts, left otherwise. Prices: never start at zero (= Web `scale: true`), see F.
- Tooltip / axis pointer:
  - Cartesian: `TrackballBehavior(enable: true, activationMode: ActivationMode.singleTap, tooltipDisplayMode: TrackballDisplayMode.groupAllPoints, lineType: TrackballLineType.vertical, lineColor: muted, lineWidth: 1, lineDashArray: [4, 4], hideDelay: 3000, tooltipSettings: InteractiveTooltip(color: surface, borderColor: border, borderWidth: 1, borderRadius: 6, textStyle: TextStyle(color: text, fontSize: 12, fontFamily: 'Inter')))` (= Web `trigger: 'axis'`, padding [8,12], radius 6).
  - Financial (= Web `axisPointer.type: 'cross'`): additionally `CrosshairBehavior(enable: true, activationMode: ActivationMode.longPress, lineColor: muted, lineDashArray: [4, 4], lineWidth: 1)` with axis `interactiveTooltip: InteractiveTooltip(color: border, textStyle: TextStyle(color: text, fontSize: 12))` (= Web pointer label `backgroundColor: c.border`).
  - Pie/donut/scatter/heatmap (= Web `trigger: 'item'`): `TooltipBehavior(enable: true, color: surface, borderColor: border, borderWidth: 1, textStyle: chartLabelStyle.copyWith(color: text))`.
  - The Web tooltip shadow `0 4px 12px rgba(0,0,0,.4)` cannot be reproduced by Syncfusion; accepted difference.
- Legend: custom `ChartLegend` = `Wrap(spacing: 12, runSpacing: 8)` of `ChartLegendItem`s above the chart, aligned left (= Web `top: 0, left: 0`): 12x8 rounded rect (radius 2, = `icon: 'roundRect'`) + label muted 12; hidden series -> `inactive` color for both rect and label. Tapping toggles the series. Do NOT use Syncfusion's built-in legend. Hide the legend for single-series charts.
- Emphasis (= Web `emphasis.focus: 'series'`, blur opacity 0.3): multi-series charts use `SelectionBehavior(enable: true, unselectedOpacity: 0.3)` on each series, `selectionType: SelectionType.series`.
- Series:
    - Line: `SplineSeries` (= `smooth: true`), `width: 2`, color from `ChartColors.series`, `markerSettings: MarkerSettings(isVisible: false)` (= `showSymbol: false`; trackball marker: circle 6). Indicator lines (moving averages): `width: 1.5`, colors `series[1]`, `series[2]`, ...
    - Area: `SplineAreaSeries` with `gradient: areaGradient(c)` = `LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [c.withValues(alpha: 0.35), c.withValues(alpha: 0)])` + `borderColor: c`, `borderWidth: 2`.
    - Bar/Column: `ColumnSeries` / `BarSeries`, `borderRadius: BorderRadius.vertical(top: Radius.circular(4))` (horizontal bars: `BorderRadius.horizontal(right: Radius.circular(4))`; stacked bars: radius only on the top segment), `width: 0.8`, `spacing: 0.2` (Web `barMaxWidth: 32`: with few categories lower `width` so a bar never exceeds ~32 px); positive/negative coloring via `pointColorMapper` (`up`/`down`).
    - Candlestick: data `open/close/low/high` (same order of meaning as Web `[open, close, low, high]`), `CandleSeries(bullColor: up, bearColor: down, enableSolidCandles: true)`. Volume panel: `ColumnSeries` with `pointColorMapper: (up/down).withValues(alpha: 0.5)`, value axis `desiredIntervals: 2` (= Web `splitNumber: 2`).
    - Pie/Donut: donut by default, `SfCircularChart(margin: EdgeInsets.zero)` + `DoughnutSeries(innerRadius: '55%', radius: '80%', strokeColor: surface, strokeWidth: 2, cornerStyle: CornerStyle.bothFlat)` (Web slice `borderRadius: 6` has no exact equivalent; keep flat), colors from `series` via `pointColorMapper`, `dataLabelSettings: DataLabelSettings(isVisible: true, labelPosition: ChartDataLabelPosition.outside, textStyle: chartLabelStyle, connectorLineSettings: ConnectorLineSettings(color: border, width: 1))`.
    - Gauge/progress: `syncfusion_flutter_gauges` `SfRadialGauge` with `RadialAxis(showTicks: false, showLabels: false, axisLineStyle: AxisLineStyle(color: surfaceHover, thickness: 0.15, thicknessUnit: GaugeSizeUnit.factor))`, `RangePointer(color: primary, width: 0.15, sizeUnit: factor, cornerStyle: CornerStyle.bothFlat)`, center `GaugeAnnotation` text 24 w600 white.
    - Heatmap: Syncfusion has no heatmap series -> build `AppHeatmap` from a `Column` of `Row`s of `Expanded` cells: cell color `Color.lerp(surfaceHover, primary, t)` (= Web `visualMap.inRange [surfaceHover, primary]`), cell border `surface` 2 (gap 2), radius 4, axis labels muted 12, tap shows a tooltip-styled overlay; legend gradient bar muted labels.
    - Scatter: `ScatterSeries`, `markerSettings: MarkerSettings(height: 8, width: 8, shape: DataMarkerType.circle)`, `color: c`, `opacity: 0.8`.
- Delta/trend text outside the chart: primary when >= 0, danger when < 0 (`+2.76%` / `-1.20%`), same formatting as Web.

### E. Shared helpers (`chart_style.dart`) — must exist and be used by every chart
```dart
const chartLabelStyle = TextStyle(color: ChartColors.muted, fontSize: 12, fontFamily: ChartColors.fontFamily);
const chartValueAxisExtent = 44.0;
final compactFormat = NumberFormat.compact(locale: 'en')..maximumFractionDigits = 1;

({double min, double max, double interval}) niceRange(double lo, double hi, {int ticks = 5}) {
  if (hi <= lo) hi = lo + 1;
  final raw = (hi - lo) / ticks;
  final magnitude = pow(10, (log(raw) / ln10).floor()).toDouble();
  final n = raw / magnitude;
  final step = (n <= 1 ? 1 : n <= 2 ? 2 : n <= 5 ? 5 : 10) * magnitude;
  return (min: (lo / step).floor() * step, max: (hi / step).ceil() * step, interval: step);
}

CategoryAxis categoryAxis({bool showLabels = true, bool betweenTicks = true, double? visibleMinimum, double? visibleMaximum, void Function(CategoryAxisController)? onCreated});
NumericAxis valueAxis({bool opposed = false, NumberFormat? format, int? desiredIntervals, double? minimum, double? maximum, double? interval}); // always sets labelsExtent: chartValueAxisExtent
TrackballBehavior chartTrackball();
TooltipBehavior chartTooltip();
LinearGradient areaGradient(Color c);
class ChartLegend extends StatelessWidget { /* items: List<({String label, Color color, bool visible})>, onToggle */ }
class ChartLegendItem extends StatelessWidget { /* label, color, visible, onTap */ }
```

### F. HARD-WON GOTCHAS (verified in a real build, follow them)
- Value axes include ZERO by default for some series types -> prices get squashed into the top of the chart. For price-like data ALWAYS compute the visible min/max yourself (lows/highs + visible indicator values) and pass `niceRange(lo, hi)` as `minimum`/`maximum`/`interval`. Recompute on every visible-range change.
- Syncfusion has no "panes/grids" inside one chart (Web: multiple grids linked with `axisPointer.link`). Multi-panel charts (price + volume) = stacked `SfCartesianChart`s in a `Column` (`Expanded(flex: 3)` price, `Expanded(flex: 1)` volume). To keep their plot areas pixel-aligned, EVERY value axis uses the same fixed `labelsExtent` (`chartValueAxisExtent`) on the same side, and any widget under them (range selector) gets the same right padding. Trackballs are per panel; do not try to sync them unless asked.
- Synchronize visible ranges of stacked charts with one `SfRangeSelector` (= Web slider dataZoom; from `syncfusion_flutter_sliders`, index-based `min: 0`, `max: n - 1`, `stepSize: 1`) whose `onChanged` sets `visibleMinimum`/`visibleMaximum` on every `CategoryAxisController` (collected via `CategoryAxis(onRendererCreated: ...)`), plus `initialVisibleMinimum/Maximum` on the axes for the first frame. Default window = last 50% of the data. The selector's child is a tiny `SfCartesianChart` with an `AreaSeries` preview (color border, borderColor muted, axes hidden). Theme it with `SfRangeSelectorTheme(data: SfRangeSelectorThemeData(activeTrackColor: primary, inactiveTrackColor: border, thumbColor: primary, thumbStrokeColor: primary, thumbRadius: 7, activeTrackHeight: 2, inactiveTrackHeight: 2, overlayColor: primary 16%, overlayRadius: 16, activeRegionColor: primary 16%, inactiveRegionColor: Colors.transparent, activeLabelStyle: chartLabelStyle, inactiveLabelStyle: chartLabelStyle))`. Web `dataZoom type: 'inside'` (pinch/drag) -> `ZoomPanBehavior(enablePinching: true, enablePanning: true, zoomMode: ZoomMode.x)` only on single-panel charts.
- `CartesianSeries.initialIsVisible` is only read once. To toggle series from the custom legend, conditionally include them in the `series` list (`if (_visible['MA5']!) SplineSeries(...)`) and `setState`.
- `yValueMapper` may return `null` for gaps (e.g. the first N-1 points of a moving average; = Web `'-'`); compute derived series once (`late final`) in state, not inside the mapper.
- Use `CategoryAxis` with formatted date strings for trading data (no weekend gaps), not `DateTimeAxis`.

### G. Layout & sizing
- A chart always sits inside `AppCard` (title/subtitle left, key figure 24 w600 + colored delta right in `aside`) (= Web `<Card.Root>` with header `flex flex-wrap items-end justify-between gap-2`).
- Height = `max(minHeight, MediaQuery.sizeOf(context).height * heightRatio)`: hero chart `0.55 / 320` (= `h-[55vh] min-h-80`), secondary `0.4 / 256` (= `h-[40vh] min-h-64`), sparkline fixed 64 (= `h-16`). Width always fills the parent (`Expanded`/stretch). Syncfusion resizes automatically with its constraints (= Web `ResizeObserver`).
- Inside the chart widget: `Column(spacing: 8)` = legend `Wrap` -> panels (`Expanded`) -> range selector (`SizedBox(height: 40)`).
- Wrap each chart in `Semantics(label: '<what the chart shows>')`.
- Dashboards: `ResponsiveFlex(breakpoint: Breakpoints.xl)` -> hero chart `Expanded(flex: 2)` + side card `Expanded()` at `xl`, stacked below (= Web `flex flex-col xl:flex-row gap-4`). Chart grids: `Wrap` with child width full / half from `Breakpoints.lg` (= `basis-full lg:basis-[calc(50%-0.5rem)]`).
- Loading: `AppSkeleton` with the same height as the chart (= Web `Suspense` + `Skeleton` fallback).

### H. Performance & data
- Charts receive typed, already-loaded data; no fetching inside chart widgets. Data classes mirror Web interfaces 1:1, e.g. `class Candle { final String date; final double open, close, low, high, volume; }`.
- Large datasets (> 2000 points): `animationDuration: 0`, `FastLineSeries` instead of `SplineSeries` (= Web `sampling: 'lttb'`), `FastColumnSeries`/`FastScatterSeries` where available (= `large: true`), keep the range selector so only a window is drawn.
- Never rebuild data lists in `build`; derive once in `initState`/`late final` and when inputs change (`didUpdateWidget`). Never recreate the chart on data change; update the series data (= Web: only `setOption`).

### I. Reference documentation (check before using an API you are not sure about; package APIs change between versions)
- Live demo gallery with source code for every chart: https://flutter.syncfusion.com/ (also on Google Play as "Syncfusion Flutter UI Widgets"). The user may pick a chart there and ask for "a chart like this one"; rebuild it with `ChartColors` + `chart_style.dart` helpers, never with the gallery's default colors.
- Cartesian charts: https://help.syncfusion.com/flutter/cartesian-charts/overview
- Circular charts: https://help.syncfusion.com/flutter/circular-charts/overview
- Range selector: https://help.syncfusion.com/flutter/range-selector/overview
- Radial gauge: https://help.syncfusion.com/flutter/radial-gauge/overview
- API reference: https://pub.dev/documentation/syncfusion_flutter_charts/latest/
- Package page / changelog: https://pub.dev/packages/syncfusion_flutter_charts
- Community license terms: https://www.syncfusion.com/products/communitylicense
- Web counterpart (ECharts) for comparing the look: gallery https://echarts.apache.org/examples/en/index.html, options https://echarts.apache.org/en/option.html
- When the docs and the installed package disagree, the installed package source (`%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\syncfusion_flutter_charts-<version>` / `~/.pub-cache`) wins.

## 17. OUTPUT REQUIREMENTS
- Modular, self-contained Dart files following the structure above.
- `flutter analyze` clean; formatted with `dart format -l 140`.
- The app must look like a direct twin of the Web PrimeReact application (Aura dark, emerald/slate) on every screen size and orientation, out of the box.
- Respect `PROJECT CONFIG` and `PROJECT FLAGS` at the top of this prompt in every answer.

## 18. DEFINITION OF DONE (every task)
- `dart format -l 140 .` applied, `flutter analyze` clean, `flutter test` green.
- No hard-coded colors/radii/font sizes outside `lib/theme/` (and `lib/charts/chart_colors.dart`), no Material `Icons.*`, no `withOpacity`, no `MaterialStateProperty`, no fixed container widths, no ripple.
- Same texts, order, breakpoints and states (loading/empty/error) as the Web screen.
- New screens checked at 390px, 768px and 1600px width (web preview), in landscape and at text scale 1.3.
- If something could not be verified (no emulator, no backend, no Web source to compare), say so explicitly in the summary.
