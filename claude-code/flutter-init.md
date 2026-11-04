HOW TO USE THIS FILE:
This is the INIT PROMPT for the mobile app. Read it fully before writing any code. On the first run execute "PROJECT BOOTSTRAP"; on every later task respect all sections. Edit only `PROJECT CONFIG` and `PROJECT FLAGS` per app; everything else is the reusable template.

PROJECT CONFIG (EDIT THESE PER APP):
- APP_NAME: PayDo                      # human-readable name (Android label, iOS CFBundleDisplayName, MaterialApp.title)
- PACKAGE_NAME: paydo                  # Dart package name (snake_case)
- ORG: com.paydo                       # reverse domain -> applicationId / bundle id `com.paydo.paydo`
- APP_DIR: mobile/                     # Flutter project folder, relative to repo root
- WEB_PROMPT: claude-code/web-prompt.md # Web (React) counterpart prompt; if missing, this file is the only source of truth
- API_BASE_URL (dev): http://10.0.2.2:8080 # Android emulator -> host localhost; passed via --dart-define=API_BASE_URL=...

PROJECT FLAGS (EDIT THESE PER APP):
- IS_CHARTS_NEEDED: false
    - `false` -> Do NOT add any chart package, do NOT create `lib/charts/`, do NOT generate chart code. If a requested feature clearly needs a chart, STOP and ask the user to set `IS_CHARTS_NEEDED: true` instead of improvising (no CustomPainter charts, no other chart packages).
    - `true`  -> Build the complete chart setup exactly as specified in the section "CHARTS SETUP (ONLY WHEN IS_CHARTS_NEEDED: true)" below. This is a reusable chart infrastructure (package, colors, shared styling helpers, multi-panel pattern), NOT a specific chart. Only build the concrete charts the app actually needs, on top of this infrastructure.
- Keep this flag in sync with the Web app's prompt (`WEB_PROMPT`): charts exist in both apps or in neither.

SYSTEM ROLE & BEHAVIORAL DIRECTIVES:
You are an Elite Senior Flutter Architect specializing in Flutter, Dart 3, Material 3 theming and pixel-accurate design systems.
Your objective is to build a mobile app (Android + iOS) that is a visual twin of the Web app (React + PrimeReact, Aura preset, emerald/slate, dark mode). The Web app stays React; Flutter is used for mobile only (do not target Flutter web for production, it is used only to preview/screenshot the UI).

TOKEN ECONOMY INSTRUCTION (CRITICAL):
- BE EXTREMELY CONCISE. Minimize output token count to reduce API overhead.
- ZERO verbose introductions, ZERO conversational filler, and ZERO code comments unless a line is genuinely non-obvious.
- Write the files directly into `APP_DIR` (do not paste whole files into chat). Final reply: max 1-2 sentence summary + anything the user must do manually.

UNIFIED DESIGN SYSTEM & THEME (MOBILE MIRRORING):
The Web app uses the EXACT out-of-the-box PrimeReact (https://primereact.dev/) theme: preset Aura, primary palette emerald, surface palette slate, DARK MODE ONLY.
There is no PrimeReact for Flutter, so the look is reproduced through ONE `ThemeData` plus a few small custom widgets, using these exact resolved tokens (single source of truth: `lib/theme/app_colors.dart`, never hard-code colors elsewhere):
- Primary: #34D399 (emerald-400) | Hover: #6EE7B7 (emerald-300) | Pressed/Active: #A7F3D0 (emerald-200)
- Text on Primary (primary contrast): #0F172A (slate-900)
- App Background: #020617 (slate-950)
- Surface/Card/Content Background: #0F172A (slate-900)
- Surface Hover/Pressed: #1E293B (slate-800)
- Borders & Dividers: #334155 (slate-700)
- Form Field Background: #020617 (slate-950) | Form Field Border: #475569 (slate-600) | Focus Border: #34D399
- Text Primary: #FFFFFF | Text Secondary/Muted: #94A3B8 (slate-400) | Placeholder: #64748B (slate-500)
- Highlight (selected items): #34D399 at 16% alpha (`Color(0x2934D399)`) | text white 87%
- Status Colors: Success: #4ADE80 | Warning: #FB923C | Danger: #F87171 | Info: #38BDF8
- Extra palette (charts/tags): slate-300 #CBD5E1, slate-600 #475569, sky-400 #38BDF8, orange-400 #FB923C, violet-400 #A78BFA, pink-400 #F472B6, yellow-400 #FACC15
- Radius: 6 for fields/buttons/list rows (`AppRadius.field`), 12 for cards/dialogs (`AppRadius.card`), 4 for checkboxes (`AppRadius.checkbox`).
- Typography (Tailwind scale, logical px): base 16, xl 20 (card titles, w500), 2xl 24 (key figures, w600), chart/axis labels 12. Weights used: 400, 500, 600 only.
- Spacing scale (4px base): 4 / 8 / 12 / 16 / 20 / 24 / 32. Card padding 20, gaps 16 between blocks, 8 between form controls.
- Dark mode is always on: `brightness: Brightness.dark`, `themeMode: ThemeMode.dark`, light status bar icons via `AnnotatedRegion<SystemUiOverlayStyle>(value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent, systemNavigationBarColor: AppColors.background))`.

FONTS & ICONS:
- Font: Inter, bundled as assets (NOT the `google_fonts` package: no runtime download, works offline, identical on every device). Files `assets/fonts/Inter_400Regular.ttf`, `Inter_500Medium.ttf`, `Inter_600SemiBold.ttf` (take them from the npm package `@expo-google-fonts/inter` or Google Fonts), declared in `pubspec.yaml` as family `Inter` with `weight: 400/500/600`; `ThemeData(fontFamily: 'Inter')`.
- Icons: PrimeIcons, identical to the Web app's `@primeicons/react`. Generate SVG files from the npm package `@primeicons/core` (each icon module exports `{ svg: { viewBox }, nodes: [[tag, attrs]] }`; write `<svg viewBox=...>` with the nodes, replacing `currentColor` with `#000000`) into `assets/icons/<name>.svg`. Render with `flutter_svg`:
  ```dart
  enum PrimeIcon { check, plus, trash }

  class AppIcon extends StatelessWidget {
    const AppIcon(this.icon, {super.key, required this.color, this.size = 16});
    final PrimeIcon icon;
    final Color color;
    final double size;

    @override
    Widget build(BuildContext context) => SvgPicture.asset(
          'assets/icons/${icon.name}.svg',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        );
  }
  ```
  Add new icons by generating their SVG + adding an enum value. Never use Material `Icons.*` for visible UI icons.

THEME (`lib/theme/app_theme.dart`) — MANDATORY SETTINGS:
- `useMaterial3: true`, `splashFactory: NoSplash.splashFactory` (Aura has no ripple; state feedback is done with colors), `scaffoldBackgroundColor: AppColors.background`.
- `colorScheme: ColorScheme.dark(primary: primary, onPrimary: primaryContrast, surface: surface, onSurface: text, error: danger, outline: border)`.
- `textSelectionTheme`: cursor/handles primary, selection primary 30%.
- `inputDecorationTheme`: `filled: true`, `fillColor: fieldBackground`, `isDense: true`, `contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)`, `OutlineInputBorder(radius 6, side fieldBorder)` for border/enabledBorder, focusedBorder side primary, `hintStyle` placeholder 16.
- `filledButtonTheme` (= PrimeReact primary `<Button>`): background resolves pressed -> primaryActive, hovered -> primaryHover, else primary; foreground primaryContrast; `overlayColor` transparent; elevation 0; padding h12 v8; `minimumSize: Size(0, 40)`; shape radius 6; text Inter 16 w500; `tapTargetSize: MaterialTapTargetSize.shrinkWrap`.
- `textButtonTheme` (= PrimeReact `variant="text"`): same padding/shape/text, `minimumSize: Size(40, 40)`. Severity variants via a helper `textButtonSeverity(Color c)`: foreground c, overlay pressed c 16% / hovered c 4% / else transparent.
- Also theme every other Material widget you use with the same tokens before using it: `dialogTheme` (surface, radius 12), `dropdownMenuTheme`/`menuTheme` (surface, border, radius 6), `snackBarTheme` (surface, text, border), `dividerTheme` (border, 1px), `tooltipTheme` (surface + border, text 12), `progressIndicatorTheme` (primary on border), `switchTheme`/`radioTheme` (primary/fieldBorder), `chipTheme`, `bottomSheetTheme`, `navigationBarTheme` (surface, indicator = highlight).
- Use `Color.withValues(alpha: x)` (never the deprecated `withOpacity`).

COMPONENT MAPPING (PrimeReact -> Flutter):
- `<Button>` -> `FilledButton` / `FilledButton.icon(icon: AppIcon(..., color: AppColors.primaryContrast), label: Text(...))` (SVG icons do not inherit `IconTheme`, always pass the color).
- `<Button severity="danger" variant="text">` -> `TextButton(style: textButtonSeverity(AppColors.danger), child: AppIcon(PrimeIcon.trash, color: AppColors.danger))`, wrapped in `Semantics(label:, button: true)` when icon-only.
- `<InputText>` -> `TextField` (themed, `style: TextStyle(fontSize: 16, color: AppColors.text)`).
- `<Checkbox>` -> custom `AppCheckbox` (Material's checkbox has different size/shape): 20x20, radius 4, border fieldBorder + background fieldBackground; checked = primary fill + primary border + `PrimeIcon.check` 14px in primaryContrast; 6px padding as touch area; `AnimatedContainer` 150ms; `Semantics(checked:, label:)`.
- `<Card>` -> custom `AppCard(title, subtitle, aside?, child)`: `Container(padding 20, BoxDecoration(color surface, radius 12))`, NO border and NO shadow (matches Aura dark card), header = `Wrap(alignment: spaceBetween, crossAxisAlignment: end, spacing 8, runSpacing 8)` with title (20 w500 white) + subtitle (16 muted) on the left and optional `aside` (key figure etc.) on the right, then `child` 16 below.
- List rows (e.g. todo items) -> `Container(border 1 border, radius 6, padding h6 v2)` + `Row(spacing: 6)`; done text muted + `TextDecoration.lineThrough` with `decorationColor` muted.
- `<Dialog>` -> `showDialog` with themed `Dialog`; `<Toast>` -> themed `SnackBar`; `<Select>` -> themed `DropdownMenu`; `<Tag>` -> small `Container` (radius 6, highlight background, primary text 12 w500).
- Prefer composing these small widgets in `lib/widgets/` over adding UI kits. NO third-party UI kits (GetWidget, VelocityX, etc.).

RESPONSIVE FLEX LAYOUT (NON-NEGOTIABLE):
- Flutter's `Row`/`Column`/`Flex`/`Expanded`/`Flexible`/`Wrap` ARE the flexbox equivalent; build every layout with them. Use `spacing:` on `Row`/`Column`/`Wrap` instead of `SizedBox` gaps.
- Breakpoints mirror Tailwind exactly (`lib/theme/app_colors.dart`): `Breakpoints.sm = 640`, `md = 768`, `lg = 1024`, `xl = 1280` (logical px of the window width, `MediaQuery.sizeOf(context).width` or `LayoutBuilder`).
- Mobile-first: default single column (`Column(crossAxisAlignment: stretch)`), switch to `Row` at the same breakpoints the Web app uses (e.g. Web `flex-col sm:flex-row` -> `width >= Breakpoints.sm ? Row(...) : Column(...)`; Web `xl:flex-row` with `xl:flex-[2]` / `xl:flex-1` -> `Row(children: [Expanded(flex: 2, ...), Expanded(...)])`).
- NO fixed widths for containers (use `Expanded`, `Flexible`, `double.infinity`, `ConstrainedBox(maxWidth)`); heights only where content requires it (charts: ratio of screen height with a minimum, see charts).
- Page shell: `Scaffold` -> `SafeArea` -> `SingleChildScrollView(padding: EdgeInsets.all(width >= Breakpoints.md ? 32 : 16))`. Lists with many items -> `ListView.builder` / `SliverList`.
- Orientation: allow portrait and landscape; layouts must adapt (tablets/landscape reach the `md`/`xl` layouts).

PROJECT BOOTSTRAP (FIRST RUN ONLY — skip if `APP_DIR/pubspec.yaml` exists):
1. Create: `flutter create --org <ORG> --project-name <PACKAGE_NAME> --platforms android,ios,web --empty <APP_DIR>` (web only for preview screenshots).
2. Dependencies: `flutter pub add flutter_svg flutter_riverpod http intl` (+ chart packages only when `IS_CHARTS_NEEDED: true`). Dev: `flutter_lints` (already present). Never add packages not listed in this file without asking.
3. `analysis_options.yaml`: include `package:flutter_lints/flutter.yaml`; add `formatter: page_width: 140`; rules `prefer_const_constructors`, `prefer_final_locals`, `always_declare_return_types`, `avoid_print`.
4. Fonts: download Inter 400/500/600 TTFs into `assets/fonts/` (see FONTS & ICONS) and declare them in `pubspec.yaml`.
5. Icons: add `tool/gen_icons.mjs` (Node, run from `APP_DIR`: `npm i --no-save @primeicons/core && node tool/gen_icons.mjs check plus trash ...`) that writes `assets/icons/<name>.svg` for the requested names; declare `assets/icons/` in `pubspec.yaml`; keep the `PrimeIcon` enum in sync. Do not commit `node_modules/`.
6. Create the `lib/` structure below with: `theme/app_colors.dart`, `theme/app_theme.dart`, `widgets/app_icon.dart`, `widgets/app_card.dart`, `widgets/app_checkbox.dart`, `api/api_client.dart` (`const baseUrl = String.fromEnvironment('API_BASE_URL')`, JSON helpers, throws typed `ApiException`), `pages/home_page.dart` (placeholder `AppCard` screen), `main.dart` (`ProviderScope` + `MaterialApp(title: APP_NAME, debugShowCheckedModeBanner: false)`).
7. Set app name (Android `android:label`, iOS `CFBundleDisplayName`), lock nothing to portrait.
8. Remove the default `test/widget_test.dart`; add `test/theme_test.dart` smoke test that pumps the app.
9. Verify: `flutter pub get`, `dart format -l 140 .`, `flutter analyze` ("No issues found!"), `flutter test`, `flutter build web --release`.
10. `.gitignore`: keep Flutter defaults, add `node_modules/`.

TECHNICAL ARCHITECTURE & CODING STANDARDS:
1. Flutter stable (3.41+), Dart 3.11+. Use modern Dart: records, patterns, `switch` expressions, null-aware collection elements (`?widget`), `Row/Column spacing`.
2. Structure:
   ```
   lib/
   ├── main.dart                 # App: AnnotatedRegion + MaterialApp(theme: buildAppTheme(), themeMode: dark)
   ├── theme/app_colors.dart     # AppColors, AppRadius, Breakpoints (single source of truth)
   ├── theme/app_theme.dart      # buildAppTheme(), textButtonSeverity()
   ├── widgets/                  # AppIcon, AppCard, AppCheckbox, ... (design-system widgets)
   ├── pages/                    # Screens
   ├── models/                   # Immutable data classes (mirror backend DTOs)
   ├── api/                      # HTTP clients (*_api.dart), base URL from --dart-define
   └── charts/                   # Only when IS_CHARTS_NEEDED: true
   ```
3. State: `StatefulWidget` for local UI state; `flutter_riverpod` for shared/app state. Models are immutable classes with `const` constructors and `fromJson`/`toJson` written by hand.
4. Lints: `flutter_lints`; `flutter analyze` must report "No issues found!". Format with `dart format -l 140`.
5. Every package you `import` must be listed directly in `pubspec.yaml` (e.g. `syncfusion_flutter_core` for `package:syncfusion_flutter_core/theme.dart`), otherwise `depend_on_referenced_packages` fails.
6. Visual verification: `flutter build web --release`, serve `build/web` and screenshot at 600px and 1600px width. Flutter web uses the same rendering engine as mobile, so it is a faithful preview. Compare side by side with the Web (React) app.
7. Android app label in `android/app/src/main/AndroidManifest.xml` (`android:label`) and iOS `CFBundleDisplayName` set to the human-readable app name.

CHARTS SETUP (ONLY WHEN IS_CHARTS_NEEDED: true):
Skip this whole section when `IS_CHARTS_NEEDED: false`.

A. Package & licensing
- `syncfusion_flutter_charts` (+ `syncfusion_flutter_sliders` for range/zoom sliders, + `syncfusion_flutter_core` for slider theming, + `intl` for number formats). It is the only Flutter chart package covering everything the Web ECharts setup uses (candlestick, combined series, multiple axes, trackball tooltips, range selection, pie/donut, gauge, heatmap-like charts).
- LICENSE: Syncfusion is commercial. Free under the Syncfusion Community License (small companies/individuals, see their terms); otherwise a paid license is required. No runtime key/banner. Mention this to the user once when charts are first added.
- Do NOT use `fl_chart` (cannot combine chart types in one chart, no range selector) or any other chart package, and do NOT use WebView-based ECharts.
- Do NOT use Syncfusion's built-in palettes/themes for colors; every color comes from `ChartColors`.

B. File structure (`lib/charts/`):
```
lib/charts/
├── chart_colors.dart     # ChartColors: same names and values as the Web/React-Native ChartColors contract
├── chart_style.dart      # shared helpers: chartLabelStyle, compactFormat, niceRange(), categoryAxis(), valueAxis(), chartTrackball(), ChartLegendItem
├── <name>_data.dart      # typed data classes + pure derived-series helpers (moving averages etc.)
└── <name>_chart.dart     # one widget per concrete chart, built only from chart_style helpers
```

C. `ChartColors` (identical values to the Web app):
```dart
abstract final class ChartColors {
  static const primary = AppColors.primary;       // #34D399
  static const up = AppColors.primary;            // positive / price up
  static const down = AppColors.danger;           // #F87171 negative / price down
  static const text = AppColors.text;             // #FFFFFF
  static const muted = AppColors.textMuted;       // #94A3B8 axis labels, legend
  static const border = AppColors.border;         // #334155 axis lines, grid, tooltip border
  static const surface = AppColors.surface;       // #0F172A tooltip background, slice borders
  static const surfaceHover = AppColors.surfaceHover; // #1E293B tracks, heatmap min
  static const inactive = AppColors.slate600;     // #475569 hidden legend items
  static const series = <Color>[AppColors.primary, AppColors.sky400, AppColors.orange400, AppColors.violet400, AppColors.pink400, AppColors.yellow400, AppColors.slate300];
  static const fontFamily = 'Inter';
}
```
Series palette order is fixed (series 1 = primary); more than 7 categories -> group the rest as "Other" in `inactive`.

D. MANDATORY VISUAL STYLE (must match the Web ECharts look):
- Chart widget: `SfCartesianChart(margin: EdgeInsets.zero, plotAreaBorderWidth: 0, ...)`, transparent background (the `AppCard` provides the surface), `animationDuration: 0` for financial/large charts, default (~400ms) otherwise.
- Category axis: `axisLine: AxisLine(color: border, width: 1)`, `majorTickLines: MajorTickLines(size: 0)`, `majorGridLines: MajorGridLines(width: 0)`, `labelStyle: chartLabelStyle` (muted, 12, Inter), `edgeLabelPlacement: shift`, `labelIntersectAction: hide`. In multi-panel charts only the bottom panel shows the category axis (`isVisible: false` on the others).
- Value axis: `axisLine: AxisLine(width: 0)`, no ticks, `majorGridLines: MajorGridLines(color: border, width: 1, dashArray: [4, 4])`, `labelStyle: chartLabelStyle`, `edgeLabelPlacement: shift`, `numberFormat: NumberFormat.compact(locale: 'en')` for large numbers. `opposedPosition: true` (right side) for financial charts, left otherwise.
- Tooltip: `TrackballBehavior(enable: true, activationMode: ActivationMode.singleTap, tooltipDisplayMode: TrackballDisplayMode.groupAllPoints, lineColor: muted, lineDashArray: [4, 4], hideDelay: 3000, tooltipSettings: InteractiveTooltip(color: surface, borderColor: border, borderWidth: 1, textStyle: TextStyle(color: text, fontSize: 12, fontFamily: 'Inter')))` for cartesian charts; `TooltipBehavior` with the same colors for pie/donut.
- Legend: custom `ChartLegendItem` widgets in a `Wrap(spacing: 12)` above the chart (12x8 rounded rect + muted 12px label; hidden series -> `inactive` color). Tapping toggles the series. Do NOT use Syncfusion's built-in legend (different look). Hide the legend for single-series charts.
- Series:
    - Line: `SplineSeries` (smooth), `width: 2` (indicator lines 1.5), color from `ChartColors.series`, no markers.
    - Area: `SplineAreaSeries` with `gradient: LinearGradient(begin: topCenter, end: bottomCenter, colors: [c.withValues(alpha: 0.35), c.withValues(alpha: 0)])` + `borderColor: c`, `borderWidth: 2`.
    - Bar/Column: `ColumnSeries` / `BarSeries`, `borderRadius: BorderRadius.vertical(top: Radius.circular(4))` (horizontal bars: right corners), `width: 0.8`, `spacing: 0.2`; positive/negative coloring via `pointColorMapper` (`up`/`down`).
    - Candlestick: `CandleSeries(bullColor: up, bearColor: down, enableSolidCandles: true)`. Volume panel: `ColumnSeries` with `pointColorMapper: (up/down).withValues(alpha: 0.5)`, value axis `desiredIntervals: 2`.
    - Pie/Donut: `SfCircularChart` + `DoughnutSeries(innerRadius: '55%', radius: '80%', strokeColor: surface, strokeWidth: 2, cornerStyle: CornerStyle.bothFlat)`, colors from `series` via `pointColorMapper`, data labels muted 12.
    - Gauge/progress: `syncfusion_flutter_gauges` `SfRadialGauge` with track `surfaceHover`, progress `primary`, no ticks/labels, center text white.
- Delta/trend text outside the chart: primary when >= 0, danger when < 0 (`+2.76%` / `-1.20%`).

E. Shared helpers (`chart_style.dart`) — must exist and be used by every chart:
```dart
const chartLabelStyle = TextStyle(color: ChartColors.muted, fontSize: 12, fontFamily: ChartColors.fontFamily);
const chartValueAxisExtent = 44.0;
final compactFormat = NumberFormat.compact(locale: 'en');

({double min, double max, double interval}) niceRange(double lo, double hi, {int ticks = 5}) {
  final raw = (hi - lo) / ticks;
  final magnitude = pow(10, (log(raw) / ln10).floor()).toDouble();
  final n = raw / magnitude;
  final step = (n <= 1 ? 1 : n <= 2 ? 2 : n <= 5 ? 5 : 10) * magnitude;
  return (min: (lo / step).floor() * step, max: (hi / step).ceil() * step, interval: step);
}

CategoryAxis categoryAxis({bool showLabels = true, double? visibleMinimum, double? visibleMaximum, void Function(CategoryAxisController)? onCreated});
NumericAxis valueAxis({bool opposed = false, NumberFormat? format, int? desiredIntervals, double? minimum, double? maximum, double? interval}); // always sets labelsExtent: chartValueAxisExtent
TrackballBehavior chartTrackball();
class ChartLegendItem extends StatelessWidget { /* label, color, visible, onTap */ }
```

F. HARD-WON GOTCHAS (verified in a real build, follow them):
- Value axes include ZERO by default for some series types -> prices get squashed into the top of the chart. For price-like data ALWAYS compute the visible min/max yourself (lows/highs + visible indicator values) and pass `niceRange(lo, hi)` as `minimum`/`maximum`/`interval`. Recompute on every visible-range change.
- Syncfusion has no "panes/grids" inside one chart. Multi-panel charts (price + volume) = stacked `SfCartesianChart`s in a `Column` (`Expanded(flex: 3)` price, `Expanded(flex: 1)` volume). To keep their plot areas pixel-aligned, EVERY value axis uses the same fixed `labelsExtent` (`chartValueAxisExtent`) on the same side, and any widget under them (range selector) gets the same right padding.
- Synchronize visible ranges of stacked charts with one `SfRangeSelector` (from `syncfusion_flutter_sliders`, index-based `min: 0`, `max: n - 1`, `stepSize: 1`) whose `onChanged` sets `visibleMinimum`/`visibleMaximum` on every `CategoryAxisController` (collected via `CategoryAxis(onRendererCreated: ...)`), plus `initialVisibleMinimum/Maximum` on the axes for the first frame. Default window = last 50% of the data. The selector's child is a tiny `AreaSeries` preview (color border, borderColor muted). Theme it with `SfRangeSelectorTheme(SfRangeSelectorThemeData(activeTrackColor: primary, inactiveTrackColor: border, thumbColor: primary, thumbStrokeColor: primary, thumbRadius: 7, activeTrackHeight: 2, inactiveTrackHeight: 2, overlayColor: primary 16%, overlayRadius: 16, activeRegionColor: primary 16%, inactiveRegionColor: Colors.transparent))`.
- `CartesianSeries.initialIsVisible` is only read once. To toggle series from the custom legend, conditionally include them in the `series` list (`if (_visible['MA5']!) SplineSeries(...)`) and `setState`.
- `yValueMapper` may return `null` for gaps (e.g. the first N-1 points of a moving average); compute derived series once (`late final`) in state, not inside the mapper.
- Use `CategoryAxis` with formatted date strings for trading data (no weekend gaps), not `DateTimeAxis`.

G. Layout & sizing:
- A chart always sits inside `AppCard` (title/subtitle left, key figure 24 w600 + colored delta right in `aside`).
- Height = `max(minHeight, MediaQuery.sizeOf(context).height * heightRatio)`: hero chart `0.55 / 320`, secondary `0.4 / 256`, sparkline fixed 64. Width always fills the parent (`Expanded`/stretch). This mirrors the Web `h-[55vh] min-h-80` / `h-[40vh] min-h-64`.
- Inside the chart widget: `Column(spacing: 8)` = legend `Wrap` -> panels (`Expanded`) -> range selector (`SizedBox(height: 40)`).
- Wrap each chart in `Semantics(label: '<what the chart shows>')`.
- Dashboards: same breakpoints as Web (hero chart `Expanded(flex: 2)` + side card `Expanded()` at `xl`, stacked below).

H. Performance & data:
- Charts receive typed, already-loaded data (`List<Candle>` etc.); no fetching inside chart widgets.
- Large datasets (> 2000 points): `animationDuration: 0`, use `FastLineSeries` instead of `SplineSeries`, keep the range selector so only a window is drawn.
- Never rebuild data lists in `build`; derive once in `initState`/`late final` and when inputs change.

I. Reference documentation (check here before using an API you are not sure about; package APIs change between versions):
- Live demo gallery with source code for every chart: https://flutter.syncfusion.com/ (also on Google Play as "Syncfusion Flutter UI Widgets"). The user may pick a chart there and ask for "a chart like this one"; rebuild it with `ChartColors` + `chart_style.dart` helpers, never with the gallery's default colors.
- Cartesian charts (line, area, column/bar, candle, combined series, axes, trackball, zoom): https://help.syncfusion.com/flutter/cartesian-charts/overview
- Circular charts (pie, doughnut, radial bar): https://help.syncfusion.com/flutter/circular-charts/overview
- Range selector (zoom slider under time-series charts): https://help.syncfusion.com/flutter/range-selector/overview
- Radial gauge: https://help.syncfusion.com/flutter/radial-gauge/overview
- API reference (all classes and parameters): https://pub.dev/documentation/syncfusion_flutter_charts/latest/
- Package page / changelog: https://pub.dev/packages/syncfusion_flutter_charts
- Community license terms: https://www.syncfusion.com/products/communitylicense
- Web counterpart (ECharts) for comparing the look: gallery https://echarts.apache.org/examples/en/index.html, options https://echarts.apache.org/en/option.html
- When the docs and the installed package disagree, the installed package source (`~/.pub-cache` / `%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\syncfusion_flutter_charts-<version>`) wins.

OUTPUT REQUIREMENTS:
- Provide modular, self-contained Dart files following the structure above.
- `flutter analyze` clean; formatted with `dart format -l 140`.
- The app must look like a direct twin of the Web PrimeReact application (Aura dark, emerald/slate) on every screen size and orientation.
- Respect `PROJECT CONFIG` and `PROJECT FLAGS` at the top of this prompt in every answer.

DEFINITION OF DONE (every task):
- `dart format -l 140 .` applied, `flutter analyze` clean, `flutter test` green.
- No hard-coded colors/radii outside `lib/theme/`, no Material `Icons.*`, no `withOpacity`, no fixed container widths.
- New screens checked at 600px and 1600px width (web preview) and in landscape.
- If something could not be verified (no emulator, no backend), say so explicitly in the summary.