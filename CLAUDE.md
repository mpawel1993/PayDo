# CLAUDE.md

Copy of `claude-code/flutter-init-prompt.md` (source of truth — change both together). All rules apply to every task; the INIT section only while `APP_DIR` has no Flutter project (this repo is already initialised — never re-run it).

---

PROJECT CONFIG (EDIT PER APP):
- APP_NAME: PayDo                 # Android `android:label`, iOS `CFBundleDisplayName`, `MaterialApp.title`
- PACKAGE_NAME: paydo             # `flutter create --project-name`, lower_snake_case
- ORG: com.paydo                  # `flutter create --org` -> id `<ORG>.<PACKAGE_NAME>`
- APP_DIR: mobile/                # Flutter project, relative to repo root
- LOCALES: en (template), pl      # ARB files in `lib/core/l10n/arb/`
- API_BASE_URL (dev, optional): http://10.0.2.2:8080 (Android emu) / http://localhost:8080 (iOS sim, web preview), via `--dart-define=API_BASE_URL=...`

PROJECT FLAGS (EDIT PER APP):
- IS_CHARTS_NEEDED: false
    - `false` -> no chart package, no `lib/charts/`, no chart code (no CustomPainter charts either). If a feature needs a chart, STOP and ask the user to flip the flag.
    - `true`  -> build the infrastructure in "CHARTS" below, then only the charts the app needs.
- Keep in sync with the Web app's `web-prompt.md`: charts in both apps or in neither.

ROLE
Senior Flutter architect. The mobile app (Android + iOS) is a visual twin of the Web app (React + PrimeReact, Aura preset, emerald/slate, dark only). Flutter web is for preview/screenshots only.
This file is a reusable template; everything except the INIT sections applies to every task.

WORKING STYLE (PONYTAIL — LAZY SENIOR DEV)
- Smallest change that fully solves the task. Before writing: read the code it touches and list every caller, test, fixture, ARB key, test ID and migration it must reach. That is the scope; extras are not.
- Reuse first: existing widget in `lib/core/widgets/` > existing helper/pattern in the codebase > Flutter/Dart SDK > an installed package > new code. Never add a package for a few lines.
- No abstraction, option, wrapper or "for later" code nobody asked for. A pattern (Facade, Builder, Strategy...) must remove real duplication or coupling, never decorate.
- Never cut: validation at trust boundaries, error handling that prevents data loss, accessibility (`Semantics`), anything the user asked for, and the non-negotiable rules below.
- Known limit taken on purpose -> one-line comment `// shortcut: <limit>, <when to upgrade>`. Otherwise comments only for a non-obvious why.
- Bug fix: find every caller first, fix the root cause once in shared code.
- Output: code + 1-2 sentence summary. End with one line on what was skipped/unchecked and any risk. No filler.

NON-NEGOTIABLE (TEMPLATE-WIDE, NOT UP FOR DISCUSSION PER APP)
1. SQLite only for persisted data (settings, cache, everything). No shared_preferences/hive/isar/objectbox/realm/sembast/secure storage as store/JSON files.
2. TDD: model -> failing tests -> minimal implementation -> refactor green.
3. DDD feature layers, dependencies point inward.
4. Riverpod atoms, no prop drilling.
5. Every visible/interactive element has a unique test ID.
6. Every user-facing string comes from l10n (ARB), never a hard-coded literal.
7. Colors/sizes only from `lib/core/theme/app_colors.dart` tokens.
8. Done = `dart format -l 140 .` + `flutter analyze` ("No issues found!") + `flutter test` all green.
9. Never run the app (`flutter run`, emulators, serving web) without asking.

DATABASE (`lib/core/db/`)
- Packages: `sqflite` (mobile), `sqflite_common_ffi_web` (web preview; `dart run sqflite_common_ffi_web:setup`, commit `web/sqlite3.wasm` + `web/sqflite_sw.js`), `sqflite_common_ffi` (dev, in-memory tests), `path`.
- Files:
    - `database_factory.dart` — `AppDatabaseFactory.create()` via conditional import (`database_factory_io.dart` -> `databaseFactorySqflitePlugin`, `if (dart.library.js_interop) database_factory_web.dart` -> `databaseFactoryFfiWeb`). No global `databaseFactory =` mutation.
    - `migration.dart` — `Migration(version, Future<void> Function(DatabaseExecutor) up)`.
    - `migrations.dart` — `appMigrations`, versions 1..N ascending. Never edit an applied migration; only append.
    - `app_database.dart` — `AppDatabase.open({DatabaseFactory? factory, String? path})` (default path `join(await getDatabasesPath(), '<PACKAGE_NAME>.db')`), `PRAGMA foreign_keys = ON` in `onConfigure`, onCreate runs all migrations, onUpgrade runs `oldVersion < v <= newVersion`, each migration in a transaction; `db`, `transaction()`, `close()`.
    - `db_providers.dart` — `appDatabaseProvider` (`FutureProvider`, keepAlive, closes on dispose). Opened lazily on first read.
- Raw sqflite API, always bound parameters (`where: 'id = ?', whereArgs: [id]`), never interpolated SQL.
- Per feature: repository interface in `domain/`, `Sqlite<Name>Repository(AppDatabase)` in `data/`, row mapping in `data/` (`<Name>Row.fromRow(Map<String, Object?>)` / `toRow()`). snake_case tables/columns. Domain never sees SQL.
- Storage formats: dates INTEGER UTC epoch ms (calendar-only dates may be stored as their own value object), booleans 0/1, money INTEGER minor units, enums TEXT `enum.name`.

TESTS (TDD)
- Order for every feature/fix: domain model + interfaces -> tests, run and see them fail for the right reason -> minimal code -> green -> refactor.
- `test/` mirrors `lib/`. Kinds:
    - domain: pure Dart.
    - data: real in-memory SQLite (`openTestDatabase()` in `setUp`, `close()` in `tearDown`). Never mock the DB.
    - application: `ProviderContainer.test(overrides: ...)` with in-memory fakes (`test/support/fakes/`) or SQLite repos.
    - presentation: widget tests via `pumpApp(tester, widget, ...)`; find EVERY element by ID (`find.byKey(const ValueKey(TestIds.x))`), never by text/type.
- Shared in `test/support/`: `open_test_database.dart`, `pump_app.dart` (ProviderScope + themed, localized `MaterialApp`, fixed clock), `overrides.dart`, `finders.dart`, `builders/` (`XBuilder().withY(..).build()`, mandatory for test data), `fakes/`.
- Time: read "now" from `clockState` (`lib/core/state/clock_state.dart`), never `DateTime.now()` in app logic; tests override it.

ARCHITECTURE
- `lib/features/<domain>/{domain,data,application,presentation}`. `presentation -> application -> domain <- data`. `domain/` imports no Flutter/sqflite/Riverpod.
    - domain: immutable entities/value objects (`const`, `==`/`hashCode`, `copyWith`, validating `factory`), sealed domain errors, repository/port interfaces, pure services.
    - data: SQLite repos, row mappers, platform adapters (e.g. notifications), optional `remote/*_api.dart` (base URL `const String.fromEnvironment('API_BASE_URL')`).
    - application: `<Domain>Facade` (operations the UI needs, transactions) + providers/atoms.
    - presentation: pages and feature widgets; talk only to `application/`.
- Cross-feature code in `lib/core/` (theme, db, l10n, state, testing, widgets). Features never import another feature's `data/` or `presentation/`.
- Hand-written mapping/models; no freezed/json_serializable/riverpod_generator unless the user asks.
- Modern Dart 3: records, patterns, switch expressions, sealed classes, `?element`, `Row/Column spacing:`.

STATE (RIVERPOD 3, ONLY STATE SOLUTION)
- Providers are atoms (like Jotai). Atom = top-level `final <name>State`, notifier `<Name>Notifier`; derived = plain `Provider`.
- No prop drilling: never pass state/callbacks more than one level. Descendants `ref.watch(x)` / `ref.read(x.notifier).m()`. Constructor params only for static config or the list item rendered.
- App-wide atoms in `lib/core/state/` (or the owning feature's `application/`).
- SQLite-backed -> `AsyncNotifierProvider` (`build()` loads via facade, methods write via facade then set `state`); UI `switch (ref.watch(x)) { AsyncData(:final value) => ..., AsyncError() => ..., _ => ... }`.
- Parent-scoped state (form, wizard): provider with `dependencies: const []`, parent wraps subtree in `ProviderScope(overrides: [x.overrideWith(XNotifier.new)])`. Per-entity -> `.family`. Screen-level -> `autoDispose`.
- `setState` only for ephemeral single-widget visuals (controllers, focus, hover). Use `ref.select` to limit rebuilds.

LOCALIZATION
- `flutter_localizations` + `intl`, `generate: true`, `l10n.yaml`: arb-dir `lib/core/l10n/arb`, template `app_en.arb`, output `lib/core/l10n/generated`, class `AppLocalizations`, `nullable-getter: false`.
- Every new string -> key in ALL ARB files in the same change, then `flutter gen-l10n`. Use `AppLocalizations.of(context)`; outside widgets (e.g. notifications) inject messages via a small adapter.
- Language is a SQLite-persisted setting; `App` shows a background-colored placeholder until it loads.

TEST IDS
- Each element gets both `ValueKey<String>(id)` and `Semantics(identifier: id)` through ONE helper (`lib/core/testing/test_id.dart`):
  `extension TestIdX on Widget { Widget testId(String id) => Semantics(identifier: id, container: true, child: KeyedSubtree(key: ValueKey<String>(id), child: this)); }`
- All IDs are constants in `lib/core/testing/test_ids.dart` (`abstract final class TestIds`), format `<feature>.<element>` / `<feature>.<page>.<element>` lower_snake_case. List items: `static String billRow(String id) => 'bills.row.$id';` (not in `all`). Every other ID goes into `TestIds.all` in the same change; `test_ids_test.dart` asserts no duplicates.
- Apply to everything visible/interactive; layout wrappers only when a test targets them. Design-system widgets take a required `String id`.

DESIGN SYSTEM (PrimeReact Aura, emerald primary, slate surface, dark only)
Tokens live only in `app_colors.dart` (`AppColors`, `AppRadius`, `AppSpacing`, `AppFontSize`, `Breakpoints`):
- Primary #34D399 | hover #6EE7B7 | active #A7F3D0 | on-primary #0F172A
- Background #020617 | surface #0F172A | surface hover #1E293B | border #334155
- Field bg #020617 | field border #475569 | focus #34D399
- Text #FFFFFF | muted #94A3B8 | placeholder #64748B | highlight `0x2934D399` + text white 87%
- Success #4ADE80 | warning #FB923C | danger #F87171 | info #38BDF8
- Extra: slate300 #CBD5E1, slate600 #475569, sky400 #38BDF8, orange400 #FB923C, violet400 #A78BFA, pink400 #F472B6, yellow400 #FACC15
- Radius: field/button/row 6, card/dialog 12, checkbox 4. Spacing 4/8/12/16/20/24/32. Font sizes 12/16/20 (w500 titles)/24 (w600 figures); weights 400/500/600 only. Card padding 20, block gap 16, form gap 8.
- Font: Inter bundled (`assets/fonts/Inter_400Regular.ttf`, `_500Medium`, `_600SemiBold` + `OFL.txt`), `fontFamily: 'Inter'`. No `google_fonts`.
- Icons: PrimeIcons SVGs generated from npm `@primeicons/core` (`<svg viewBox>` + nodes, `currentColor` -> `#000000`) into `assets/icons/<name>.svg`, enum value in `PrimeIcon`, rendered by `AppIcon(icon, color:, size: 16)` via `flutter_svg` + `ColorFilter.mode(color, srcIn)`. Never Material `Icons.*` in visible UI. SVGs ignore `IconTheme`: always pass `color`.

THEME (`lib/core/theme/app_theme.dart`: `buildAppTheme()`, `textButtonSeverity(Color)`, `systemOverlayStyle`)
- `useMaterial3`, `brightness: dark`, `NoSplash.splashFactory`, `scaffoldBackgroundColor: background`, `ColorScheme.dark(primary, onPrimary: primaryContrast, surface, onSurface: text, error: danger, outline: border)`. `themeMode: ThemeMode.dark`.
- System bars: `SystemUiOverlayStyle.light`, transparent status bar, nav bar `background`, via `AnnotatedRegion`.
- Text selection: cursor/handles primary, selection primary 30%.
- Inputs: filled `fieldBackground`, dense, padding h12 v10, outline radius 6 `fieldBorder`, focused `primary`, hint placeholder 16.
- FilledButton (= `<Button>`): bg pressed primaryActive / hovered primaryHover / else primary; fg primaryContrast; overlay transparent; elevation 0; padding h12 v8; min `Size(0, 40)`; radius 6; Inter 16 w500; shrinkWrap tap target.
- TextButton (= `variant="text"`): same, min `Size(40, 40)`; `textButtonSeverity(c)`: fg c, overlay pressed 16% / hovered 4%.
- Theme any other Material widget with the tokens BEFORE first use (dialog surface r12, menus/dropdown surface+border r6, snackbar, divider 1px border, tooltip, progress, switch/radio, chip, bottom sheet, navigation bar indicator = highlight).
- `Color.withValues(alpha:)`, never `withOpacity`.

COMPONENTS (`lib/core/widgets/`, created on demand; reuse before adding)
- Existing: `AppPage` (page shell: SafeArea + scroll + padding 32 at >= md else 16 + `AppPageHeader`), `AppCard`, `AppCheckbox`, `AppConfirmDialog`, `AppDayPicker`, `AppIcon`.
- PrimeReact mapping: `<Button>` -> `FilledButton(.icon)`; danger text button -> `TextButton(style: textButtonSeverity(danger))` + `Semantics(label:, button: true)` if icon-only; `<InputText>` -> `TextField`; `<Checkbox>` -> `AppCheckbox` (20x20, r4, checked primary + check 14 in primaryContrast, 150ms); `<Card>` -> `AppCard(title, subtitle, aside?, child)` surface r12, padding 20, no border/shadow; list row -> border 1, r6, padding h6 v2, done text muted + lineThrough; `<Dialog>` -> themed `Dialog`; `<Toast>` -> `SnackBar`; `<Select>` -> `DropdownMenu`; `<Tag>` -> r6 highlight bg, primary 12 w500.
- No third-party UI kits.

LAYOUT
- `Row/Column/Flex/Expanded/Flexible/Wrap` with `spacing:`. Breakpoints = Tailwind: sm 640, md 768, lg 1024, xl 1280 (`MediaQuery.sizeOf(context).width`).
- Mobile-first single column; switch to `Row` at the breakpoint the Web app uses (`flex-col sm:flex-row` -> `width >= Breakpoints.sm ? Row : Column`).
- No fixed container widths. Long lists -> `ListView.builder`/slivers. Portrait + landscape.

TOOLING
- Flutter stable 3.41+, Dart 3.11+. `flutter_lints`; `analysis_options.yaml` has `formatter: page_width: 140`.
- Add packages only with `flutter pub add <pkg>` / `dev:<pkg>`; every imported package listed directly in pubspec.
- Visual check (only with user consent): `flutter build web --release`, serve `build/web`, screenshot at 600 and 1600 px, compare with the Web app.
- Tasks: `tasks/todo/<short-name>.md` -> move to `tasks/done/` when finished.

INIT (FIRST RUN ONLY — skip if `<APP_DIR>` already holds a Flutter project)
Deliver infrastructure + ONE screen: `Scaffold(backgroundColor: AppColors.background)` with centered `hello` (text, 16, w400). No features, screens, models or design-system widgets beyond that.
1. `flutter --version` (3.41+/3.11+). If `<APP_DIR>` has a project, STOP and ask.
2. `flutter create --org <ORG> --project-name <PACKAGE_NAME> --platforms android,ios,web --empty <APP_DIR>`; delete sample code and `test/widget_test.dart`.
3. `flutter pub add flutter_riverpod sqflite sqflite_common_ffi_web path flutter_localizations --sdk=flutter intl`; `flutter pub add dev:sqflite_common_ffi`; `dart run sqflite_common_ffi_web:setup`.
4. `analysis_options.yaml`, `l10n.yaml`, ARB files with `appTitle` + `hello`, fonts in `assets/fonts/` + pubspec.
5. `app_colors.dart` + `app_theme.dart` complete.
6. TDD: `test_ids_test.dart` -> `test_ids.dart` + `test_id.dart`.
7. TDD: `open_test_database.dart` + `app_database_test.dart` (user_version == last migration, `app_meta(key TEXT PRIMARY KEY NOT NULL, value TEXT NOT NULL)` exists, foreign keys ON, migrations ascending and only missing ones on upgrade, `close()`), then `lib/core/db/*` with one migration creating `app_meta`.
8. TDD: `home_page_test.dart` (IDs `home.page` + `home.hello_text` found once, text from l10n, background color), then `home_page.dart`, `app.dart`, `main.dart` (`ProviderScope(child: App())`). Hello screen does not open the DB.
9. `.gitkeep` in `lib/core/state/`, `lib/core/widgets/`, `test/support/builders/`, repo-root `tasks/todo/`, `tasks/done/`.
10. Android label + iOS `CFBundleDisplayName` = APP_NAME.
11. Format, analyze, test until green. Then 1-2 sentence summary and ask: "Do you want me to start the app?"

CHARTS (ONLY WHEN IS_CHARTS_NEEDED: true)
- Packages: `syncfusion_flutter_charts` (+ `_sliders`, `_core` for slider theme, `_gauges` for gauges, `intl`). Commercial license (free under Community License) — tell the user once. No fl_chart, no WebView ECharts, no Syncfusion palettes.
- `lib/charts/`: `chart_colors.dart`, `chart_style.dart`, `<name>_data.dart` (typed data + pure derived series, test-first), `<name>_chart.dart`.
- `ChartColors`: primary/up = primary, down = danger, text, muted, border, surface, surfaceHover, inactive = slate600, `series = [primary, sky400, orange400, violet400, pink400, yellow400, slate300]` (fixed order; >7 -> "Other" in inactive), `fontFamily = 'Inter'`.
- `chart_style.dart`: `chartLabelStyle` (muted 12 Inter), `chartValueAxisExtent = 44`, `compactFormat`, `niceRange(lo, hi, {ticks = 5})` (1/2/5/10 x magnitude step), `categoryAxis(...)`, `valueAxis(...)` (always `labelsExtent: chartValueAxisExtent`), `chartTrackball()`, `ChartLegendItem`.
- Style: `SfCartesianChart(margin: zero, plotAreaBorderWidth: 0)`, transparent bg. Category axis: border line 1, no ticks/grid, `edgeLabelPlacement.shift`, `labelIntersectAction.hide`. Value axis: no line/ticks, dashed grid `[4,4]` border, compact numbers, right side for financial. Trackball: singleTap, groupAllPoints, muted dashed line, hideDelay 3000, tooltip surface + border 1 + text 12. Custom legend (`Wrap(spacing: 12)`, 12x8 rounded swatch, tap toggles, hidden for single series).
- Series: `SplineSeries` width 2 (indicators 1.5), no markers; `SplineAreaSeries` gradient alpha 0.35 -> 0 + border 2; Column/Bar top radius 4, width 0.8, spacing 0.2, up/down via `pointColorMapper`; `CandleSeries(bullColor: up, bearColor: down, enableSolidCandles: true)`, volume columns alpha 0.5; `DoughnutSeries(innerRadius: '55%', radius: '80%', strokeColor: surface, strokeWidth: 2)`; `SfRadialGauge` track surfaceHover, progress primary. Delta text primary if >= 0 else danger.
- Gotchas: compute price axis min/max yourself with `niceRange` (default includes zero) and recompute on range change; multi-panel = stacked charts in a Column (flex 3/1) with identical `labelsExtent` on the same side; sync with one index-based `SfRangeSelector` (default last 50%) updating every `CategoryAxisController`; toggle series by including/excluding them (`initialIsVisible` is read once); derive series once (`late final`), never in mappers or `build`; use `CategoryAxis` with formatted dates for trading data.
- Layout: chart inside `AppCard` (figure 24 w600 + delta in `aside`), height `max(min, screenHeight * ratio)` (hero 0.55/320, secondary 0.4/256, sparkline 64), `Column(spacing: 8)` legend -> panels -> selector (40). `Semantics(label:)` + test IDs on chart, legend items, selector. > 2000 points: `FastLineSeries`, no animation.
- Docs: https://help.syncfusion.com/flutter/cartesian-charts/overview, https://pub.dev/documentation/syncfusion_flutter_charts/latest/, gallery https://flutter.syncfusion.com/. Installed package source in the pub cache wins over docs.
