# CLAUDE.md

This file guides Claude Code (claude.ai/code) when working in this repository.

## 1. What this repo is

**PayDo** is an early-stage, multi-client product. Right now the repo holds only the **mobile app** (Flutter, Android + iOS). It is meant to be a pixel-accurate **visual twin of a Web app** (React 19 + PrimeReact 11, Aura preset, emerald primary / slate surface, **dark mode only**). The Web app is not in this repo yet.

Current state (as of 2026-11-04, commit `f4cf429 Init app`): **bare template**. The app shows one screen with the text `hello` on a dark background. The full design-system theme exists. No features, packages, widgets, icons, router, state management or API client exist yet.

```
PayDo/
├── CLAUDE.md                  # this file
├── README.md                  # just "# PayDo"
├── .gitignore                 # root: only ignores /.idea/
├── claude-code/
│   ├── flutter-init.md        # THE spec for the mobile app (~500 lines). Read the relevant section before any mobile work.
│   └── base.md                # staged as an empty file, deleted in the working tree (git status "AD"). Not in use.
└── mobile/                    # Flutter project (APP_DIR)
    ├── pubspec.yaml           # name: paydo, version 0.1.0+1, sdk ^3.11.1, no runtime deps besides flutter
    ├── analysis_options.yaml  # flutter_lints + extra rules, formatter page_width 140
    ├── lib/
    │   ├── main.dart          # App: AnnotatedRegion(systemOverlayStyle) > MaterialApp(dark theme) > Scaffold("hello")
    │   └── theme/
    │       ├── app_colors.dart  # AppColors (palette + semantic tokens), AppRadius, AppSpacing, Breakpoints
    │       ├── app_text.dart    # AppText type scale (xs..xxxl), Inter
    │       └── app_theme.dart   # buildAppTheme(), Severity, ButtonSize, severityColors(), filledButtonSeverity(),
    │                            # textButtonSeverity(), buttonSize(), systemOverlayStyle
    ├── assets/fonts/          # Inter 400/500/600/700 TTF + OFL.txt (bundled; no google_fonts package)
    ├── test/app_smoke_test.dart # pumps App, expects text 'hello'
    ├── android/               # Kotlin DSL Gradle, AGP 8.11.1, Kotlin 2.2.20, Gradle 8.14, Java 17
    ├── ios/                   # Swift, deployment target 13.0, scene-based (SceneDelegate + FlutterImplicitEngineDelegate)
    └── web/                   # ONLY for preview screenshots; NOT a production target
```

Planned but **not present**: `web/` (React app, `WEB_DIR`), `claude-code/web-prompt.md` (`WEB_PROMPT`), a backend (dev API expected at port 8080).

## 2. The spec: `claude-code/flutter-init.md`

This file is the binding spec for all mobile work. Everything in it applies on every task. This CLAUDE.md summarises it and records how the repo differs from it. When they disagree, the spec wins, except for the "current state" facts in section 8 below.

Rules about the spec file itself:
- Only `## 1. PROJECT CONFIG` and `## 2. PROJECT FLAGS` are per-app values. The rest is a reusable template.
- If the Web prompt (`WEB_PROMPT`) and the Flutter spec disagree on a **value** (color, radius, spacing, size), the **Web prompt wins**, and `flutter-init.md` must be updated.
- Values marked `(*)` are PrimeReact Aura component tokens reproduced from memory. Verify them against `@primeuix/themes` (`node_modules/@primeuix/themes/dist/aura/<component>/index.mjs`; rem × 16 = px) before relying on them, and fix the spec if they are wrong.
- Section 15 (Bootstrap) has already run. Do **not** run it again. After it ran, the project was cut back on purpose to the bare template.

Project config: `APP_NAME=PayDo`, `PACKAGE_NAME=paydo`, `ORG=com.paydo` (applicationId / bundle id `com.paydo.paydo`), `APP_DIR=mobile/`, `WEB_DIR=web/`, dev `API_BASE_URL=http://10.0.2.2:8080` (Android emulator) or `http://localhost:8080` (iOS simulator / web preview).

Flags: **`IS_CHARTS_NEEDED: false`**. Do not add a chart package, do not create `lib/charts/`, and do not draw charts with CustomPainter. If a feature needs a chart, stop and ask the user to flip the flag. When the flag is `true`, spec section 16 applies: Syncfusion only, never fl_chart or a WebView ECharts. The flag must be the same in the Web prompt.

## 3. Commands

Run everything from `mobile/`. The toolchain is Flutter 3.41.4 (stable) with Dart 3.11.1, on Windows.

```bash
flutter pub get
dart format -l 140 .                 # always width 140 (also set in analysis_options.yaml)
flutter analyze                      # must print "No issues found!"
flutter test                         # all tests
flutter test test/app_smoke_test.dart            # single file
flutter test --plain-name "shows hello"          # single test by name

flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080   # Android emulator
flutter run --dart-define=API_BASE_URL=http://localhost:8080  # iOS simulator / web
flutter build apk --release --dart-define=API_BASE_URL=<prod>
flutter build ipa --dart-define=API_BASE_URL=<prod>           # macOS only
```

Visual verification (spec 13.11): run `flutter build web --release`, then serve `build/web` on a **free** port. Check the port with `curl` first, because other local apps may be listening, and confirm the served `<title>` is `PayDo`. For example: `npx -y http-server -p 8790 -s -c-1 build/web`. Take screenshots with `puppeteer-core` driving the installed Chrome. Wait for `flutter-view` plus about 2.5 s, because a plain `chrome --headless --screenshot` captures a blank page. Capture widths **390 / 768 / 1600 px**, plus landscape and text scale 1.3.

Git: `core.autocrlf=true`, so platform files are CRLF. Scripted edits must handle `\r\n`. The default branch is `dev`.

## 4. Definition of done (every task)

1. `dart format -l 140 .` has been run, `flutter analyze` is clean, and `flutter test` passes.
2. There are no hard-coded colors, radii or font sizes outside `lib/theme/` (and `lib/charts/chart_colors.dart` if charts are ever added).
3. None of these appear: Material `Icons.*` in visible UI, `withOpacity` (use `withValues(alpha:)`), `MaterialStateProperty` (use `WidgetStateProperty`), fixed container widths, ripples or splashes, Material elevation or tint.
4. Texts, order, breakpoints and loading/empty/error states match the Web screen. When the Web source exists in `web/`, read it first.
5. New screens are checked at 390 / 768 / 1600 px, in landscape, and at text scale 1.3.
6. Say plainly what could not be verified (no emulator, no backend, no Web source).
7. Communication style from the spec: keep it very concise. No filler, and no code comments unless a line is genuinely non-obvious. Write files directly instead of pasting them into chat. The final reply is 1–2 sentences plus any manual steps.

## 5. Design system (single source of truth: `lib/theme/`)

PrimeReact has no Flutter port, so the look comes from one `ThemeData` (`buildAppTheme()`) plus small custom widgets. Widgets must use **semantic tokens**, never raw palette shades. The exceptions are accents and severity colors.

### Semantic color tokens (`AppColors`)
| token | value | meaning |
|---|---|---|
| `primary` / `primaryHover` / `primaryActive` | emerald-400 `#34D399` / -300 / -200 | primary actions, focus, selection |
| `primaryContrast` | slate-900 `#0F172A` | text and icons on primary |
| `background` | slate-950 `#020617` | scaffold / page |
| `surface` | slate-900 `#0F172A` | cards, dialogs, menus, app bar, drawer |
| `surfaceHover` | slate-800 `#1E293B` | hover rows, secondary bg |
| `border` | slate-700 `#334155` | borders, dividers |
| `fieldBackground` / `fieldBorder` / `fieldHoverBorder` / `fieldFocusBorder` | slate-950 / slate-600 / slate-500 / primary | inputs |
| `fieldDisabledBackground` / `fieldDisabledText` | slate-700 / slate-400 | disabled inputs |
| `text` / `textMuted` / `placeholder` | white / slate-400 / slate-500 | text |
| `highlight` / `highlightText` | primary @16% `0x2934D399` / white @87% | selected items |
| `success` / `warning` / `danger` / `info` | green-400 / orange-400 / red-400 / sky-400 | status |
| `mask` | black @60% | dialog/drawer barrier |

The raw palette in `app_colors.dart` has every emerald and slate shade (slate0..950), plus green/red/orange/sky 300–500/950 (and red200), violet400, pink400 and yellow400.

### Other tokens
- `AppRadius`: `checkbox` 4 (checkboxes, menu options), `field` 6 (inputs, buttons, tags, tooltips, menus, list rows), `card` 12 (cards, dialogs, panels, sheets).
- `AppSpacing`: `xs 4, sm 8, md 12, lg 16, card 20, xl 24, xxl 32`. Never use values outside this scale (component tokens excepted). Card padding is 20. Use 16 between blocks, 8 between form controls, page padding 16 (32 from md), and custom panel padding 16 (24 from md).
- `Breakpoints` (Tailwind): `sm 640, md 768, lg 1024, xl 1280, xxl 1536`. Measure on window width: `MediaQuery.sizeOf` for page decisions, `LayoutBuilder` for component decisions.
- `AppText` (Inter): `xs 12/16`, `sm 14/20`, `base 16/24` (default), `lg 18/28`, `xl 20/28 w500`, `xxl 24/32 w600`, `xxxl 30/36 w600`. Use only weights 400/500/600/700, and 700 only for tags and badges. Mapped into `textTheme` as `bodyMedium/bodyLarge`=base, `bodySmall`=sm, `labelLarge`=base w500, `titleLarge`=xl, `headlineSmall`=xxl, `displaySmall`=xxxl, `labelSmall`=xs.
- Control height is 40 (small 32, large 48). Minimum touch target is 40×40.

### Theme behaviour (`app_theme.dart`)
- Material 3, `Brightness.dark`, `ThemeMode.dark` only. There is no light theme and no toggle (`theme` and `darkTheme` are both `buildAppTheme()`).
- Ripples are off everywhere (`NoSplash`, transparent overlay, hover and highlight colors). State feedback comes from color changes only. Elevation and surface tint are 0 or transparent. Overlays may use the shadow `0x66000000` blur 12 offset (0,4).
- `Severity { primary, secondary, success, info, warn, danger }` → `severityColors(s)` returns a record `(bg, hover, active, fg, accent)`. Use `filledButtonSeverity(s)` for filled buttons (primary is the default `FilledButtonTheme`), `textButtonSeverity(color)` for text buttons, and `buttonSize(ButtonSize.small|normal|large)` to merge sizes.
- Buttons: padding h12 v8, min height 40, radius 6, Inter 16 w500, icon 16. Disabled is 60% alpha. Outlined buttons use an emerald-700 border. Hovered overlay is 4% and pressed is 16% of the foreground color.
- Inputs: filled with `fieldBackground`, dense, padding h12 v8 (gives 40 px total height), 1 px borders (focus = primary, error = danger), and `floatingLabelBehavior.never`. Put a separate label `Text` above the field, like a Web `<label>`.
- `systemOverlayStyle` uses a transparent status bar with light icons and a `background`-colored nav bar. It is applied in `main.dart` and in `appBarTheme`.
- Already themed: dialog, bottom sheet (drag handle), menu/dropdown/popup/menuButton, snackbar (floating), divider, tooltip (slate-700), progress, chip, navigation bar/rail, drawer (280, right border), app bar (bottom border), list tile, data table, tab bar, date picker, scrollbar and card.

## 6. Architecture rules (for code that does not exist yet)

When adding the first feature, follow spec section 13. Add each piece **only when a feature needs it, never preemptively**.

```
lib/
├── main.dart          # runApp(ProviderScope(child: App())) once Riverpod is added
├── app_router.dart    # go_router, SAME paths as the Web app; ShellRoute for the shell
├── config.dart        # const apiBaseUrl = String.fromEnvironment('API_BASE_URL')
├── theme/             # exists
├── widgets/           # design-system widgets, one file each, snake_case (app_card.dart, app_text_field.dart, ...)
├── pages/             # <name>_page.dart; page-private widgets in pages/<name>/
├── models/            # immutable DTOs mirroring backend / Web TS interfaces 1:1
├── api/               # api_client.dart + <feature>_api.dart
└── state/             # <feature>_provider.dart (Riverpod)
```

- **Allowed packages:** `flutter_svg`, `flutter_riverpod` (3.x), `go_router`, `http`, `intl`. Chart packages are allowed only if the flag is set. **Ask before adding anything else**: no UI kits, no freezed or json_serializable, no google_fonts. `file_picker` and `flutter_secure_storage` need the user's approval first. Every imported package must be a direct dependency, because of the `depend_on_referenced_packages` lint.
- **State:** use `StatefulWidget` for local UI state. Use Riverpod `Notifier`/`AsyncNotifier` for shared state (no codegen, no `StateNotifier`/`StateProvider`), with one provider per Web store (e.g. Web `useTodoStore` → `todoProvider`). Providers own data loading. Never fetch in `build`.
- **Models:** immutable, with `const` constructors, `final` fields, hand-written `fromJson(Map<String, Object?>)`/`toJson()`, `copyWith`, and `==`/`hashCode` (or records). Use `DateTime` with ISO-8601 on the wire. **Money is `int` minor units (cents)** unless the backend or Web uses something else. Never use `double` for money math.
- **API:** `ApiClient` wraps `package:http` with `get/post/put/delete<T>(path, {body, fromJson})`, JSON headers and a 15 s timeout. A non-2xx response throws `ApiException(statusCode, message)`. The auth token comes from a provider.
- **Errors:** never swallow exceptions. Show them with `AppToast`/`AppMessage` using the Web texts. Use `debugPrint` only in debug, and never `print` (it is linted).
- **Design-system widgets** take data and callbacks only (no providers inside) and use `const` constructors. Each multi-part PrimeReact component (`Card.Root/Header/Title/...`) becomes ONE widget with named params. See the full PrimeReact → Flutter mapping in spec section 9 (`AppCard`, `AppPanel`, `AppTextField`, `AppCheckbox`, `AppRadio`, `AppTag`, `AppToast`, `AppMessage`, `AppListRow`, `AppDataTable`, `AppPaginator`, `AppSkeleton`, `showAppDialog`, `showAppConfirm`, `ResponsiveFlex`, ...).
- **Icons:** use PrimeIcons as SVGs in `assets/icons/<kebab-name>.svg`, generated by `tool/gen_icons.mjs` from `@primeicons/core` (`npm i --no-save`; never commit `node_modules/`). Render them through a `PrimeIcon` enum (camelCase) and an `AppIcon(icon, color:, size: 16)` widget using `flutter_svg`. Always pass `color`, since SVGs ignore `IconTheme`. Sizes: 16 default, 14 in small controls, 12 in tags, 20 in the top bar. None of this exists yet. Create it with the first icon you need, and declare `assets/icons/` in pubspec.
- **Layout:** build with flex (`Row`/`Column`/`Wrap`/`Expanded`) and use `spacing:` instead of `SizedBox` gaps. Lay out mobile-first in one column, and switch to `Row` at the same breakpoint as the Web app. Use `GridView` only when unavoidable, and `ListView.builder` for long lists. Constrain content to `maxWidth: Breakpoints.xl`. Allow both orientations. Respect text scaling and never clamp it below 1.0. Use the Tailwind→Flutter table in spec section 10.
- **Shell and pages (spec section 11):** below md, use an AppBar with a drawer, or a bottom `NavigationBar` for 2–5 destinations. From md, use a `NavigationRail` or a 256 px side nav. Each page is `Scaffold > SafeArea > SingleChildScrollView(padding 16/32) > Center > ConstrainedBox(xl) > Column(stretch, spacing 16)`. Data pages need loading (skeletons), empty and error (+ retry) states, and a `RefreshIndicator`.
- **A11y:** every interactive widget has a semantic label. Icon-only buttons get `Semantics(button: true, label:)` plus a `Tooltip`. Use a `FocusTraversalGroup` per form. Use only the token pairs above for contrast.
- **Tests:** one widget smoke test per page (with `ProviderScope` overrides and a fake API), plus model JSON round-trip and pure helper unit tests.
- **Web parity naming:** Web `src/pages/Dashboard.tsx` → `lib/pages/dashboard_page.dart`. Keep the same routes, labels and texts. If the Web app is localized, use `flutter_localizations` + ARB files with the same keys. Format numbers, dates and currency with `intl`, using the same locale and patterns as Web `Intl.*`.

## 7. Lints (`mobile/analysis_options.yaml`)

`package:flutter_lints/flutter.yaml` plus `prefer_const_constructors`, `prefer_const_declarations`, `prefer_final_locals`, `prefer_final_fields`, `always_declare_return_types`, `avoid_print`, `use_super_parameters`, `unawaited_futures`. Do **not** enable `require_trailing_commas`, because the 140-wide formatter manages commas. The code style is an expression-bodied `build` where that is natural, with Dart 3 features (records, `switch` expressions, patterns, sealed classes, null-aware elements).

## 8. Known gaps / deviations from the spec (verify before "fixing")

- `mobile/web/manifest.json` has `"orientation": "portrait-primary"`, but the spec says to lock nothing to portrait. This only matters for the web preview.
- The Android launch theme is still the Flutter default: `styles.xml` uses `Theme.Light.NoTitleBar`, and `launch_background.xml` is white. This causes a white flash on cold start. The spec plans a splash on `#020617` via `flutter_native_splash` only once the user provides an icon. Launcher icons are the Flutter defaults.
- The Android release build is signed with debug keys (template TODO), and `applicationId` still has the template TODO comment.
- iOS `CFBundleDisplayName` is `PayDo` and `CFBundleName` is `paydo`. Android `android:label` is `PayDo`.
- `mobile/README.md` is the Flutter template default ("A new Flutter project.").
- `claude-code/base.md` is staged as empty and deleted in the working tree. Ask before committing or restoring it.
- The `web/` React app and `claude-code/web-prompt.md` do not exist. Until they do, Web parity cannot be checked. Say so in task summaries.
- `flutter pub get` reports that newer incompatible versions of some transitive packages exist. This is informational and needs no action.
