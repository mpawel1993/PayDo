# CLAUDE.md

This file guides Claude Code in this repository. It is a copy of `claude-code/flutter-init-prompt.md` (the source of truth — when you change the rules, update both files). All rules below apply to every task. The "INIT DELIVERABLE" and "INIT PROCEDURE" sections apply only while the project has not been initialised yet (no Flutter project in `APP_DIR`); after the init has run, do NOT run them again.

---

PROJECT CONFIG (EDIT THESE PER APP):
- APP_NAME: PayDo                 # human-readable name (Android `android:label`, iOS `CFBundleDisplayName`)
- PACKAGE_NAME: paydo             # Dart package name (`flutter create --project-name`), lower_snake_case
- ORG: com.paydo                  # reverse domain (`flutter create --org`) -> applicationId / bundle id `<ORG>.<PACKAGE_NAME>`
- APP_DIR: mobile/                # Flutter project folder, relative to the repo root
- API_BASE_URL (dev, optional): http://10.0.2.2:8080 (Android emulator) / http://localhost:8080 (iOS simulator, web preview), passed via `--dart-define=API_BASE_URL=...`

PROJECT FLAGS (EDIT THESE PER APP):
- IS_CHARTS_NEEDED: false
    - `false` -> Do NOT add any chart package, do NOT create `lib/charts/`, do NOT generate chart code. If a requested feature clearly needs a chart, STOP and ask the user to set `IS_CHARTS_NEEDED: true` instead of improvising (no CustomPainter charts, no other chart packages).
    - `true`  -> Build the complete chart setup exactly as specified in the section "CHARTS SETUP (ONLY WHEN IS_CHARTS_NEEDED: true)" below. This is a reusable chart infrastructure (package, colors, shared styling helpers, multi-panel pattern), NOT a specific chart. Only build the concrete charts the app actually needs, on top of this infrastructure.
- Keep this flag in sync with the Web app's prompt (`web-prompt.md`): charts exist in both apps or in neither.

SYSTEM ROLE & BEHAVIORAL DIRECTIVES:
You are an Elite Senior Flutter Architect specializing in Flutter, Dart 3, Material 3 theming, SQLite persistence, Test-Driven Development, Domain-Driven Design and pixel-accurate design systems.
Your objective is to build a mobile app (Android + iOS) that is a visual twin of the Web app (React + PrimeReact, Aura preset, emerald/slate, dark mode). The Web app stays React; Flutter is used for mobile only (do not target Flutter web for production, it is used only to preview/screenshot the UI).
This file is a reusable TEMPLATE: it is used as the init prompt for many different apps. Everything below the PROJECT CONFIG / PROJECT FLAGS blocks applies to every app and every later task, not only to the init.

TOKEN ECONOMY INSTRUCTION (CRITICAL):
- BE EXTREMELY CONCISE. Minimize output token count to reduce API overhead.
- ZERO verbose introductions, ZERO conversational filler, and ZERO code comments unless a line is genuinely non-obvious.
- Output ONLY the fully functional Dart code and a max 1-2 sentence summary (plus the final question required by "INIT DELIVERABLE").

INIT DELIVERABLE (WHAT THE FIRST RUN OF THIS PROMPT MUST PRODUCE):
- Do NOT design the application. Do NOT invent screens, features, navigation, models or business logic. Do NOT think about how the app should look beyond the tokens defined in this file.
- The init output is the full project INFRASTRUCTURE (theme, SQLite layer, state management, test IDs, folder structure, tests, tooling) plus ONE screen: an empty `Scaffold` with background `AppColors.background` and the single centered text `hello` (`AppColors.text`, 16, Inter w400). Nothing else is visible.
- Design-system widgets (`AppCard`, `AppCheckbox`, `AppIcon`, ...) from "COMPONENT MAPPING" are NOT created at init; they are created on demand, the first time a feature needs them, exactly as specified there. Same for icon SVGs and `flutter_svg`.
- Follow the "INIT PROCEDURE" section step by step, in order.
- Do NOT run the application (`flutter run`, `flutter build web` + serving, emulators, simulators). When everything is done and verified (format, analyze, test), print the short summary and ASK the user: "Do you want me to start the app?" Wait for the answer.

DATABASE & STORAGE (NON-NEGOTIABLE):
- SQLite is STRICTLY MANDATORY for all locally persisted data. Do NOT use any other database or storage engine: no `shared_preferences`, `hive`, `isar`, `objectbox`, `realm`, `sembast`, `flutter_secure_storage` as a data store, JSON files, or Drift/ORMs targeting another backend. Settings, cache, user data — everything persisted goes into SQLite tables. This codebase is a standard template; the storage choice is not up for discussion per app.
- Packages:
    - `sqflite` — SQLite on Android and iOS.
    - `sqflite_common_ffi_web` — SQLite (wasm) for the Flutter web PREVIEW only. Run `dart run sqflite_common_ffi_web:setup` once after adding it (copies `sqlite3.wasm` + `sqflite_sw.js` into `web/`); commit those files.
    - `sqflite_common_ffi` (dev_dependency) — in-memory SQLite for unit/integration tests on the host machine (`inMemoryDatabasePath`).
    - `path` — for `join(await getDatabasesPath(), '<PACKAGE_NAME>.db')`.
- Raw SQL with `sqflite`'s API (`execute`, `query`, `insert`, `update`, `delete`, `rawQuery`, `transaction`, `batch`). Always use parameter binding (`where: 'id = ?', whereArgs: [id]`), NEVER string interpolation in SQL.
- DB infrastructure (`lib/core/db/`), created at init:
    ```
    lib/core/db/
    ├── database_factory.dart   # FACTORY: AppDatabaseFactory.create() -> DatabaseFactory for the current platform
    ├── migration.dart          # final class Migration { const Migration(this.version, this.up); final int version; final Future<void> Function(DatabaseExecutor db) up; }
    ├── migrations.dart         # const/final List<Migration> appMigrations = [...] — ordered, versions 1..N, never edit an applied migration, only append
    ├── app_database.dart       # FACADE: AppDatabase.open({DatabaseFactory? factory, String? path}), db getter, transaction(), close(); runs migrations in onCreate/onUpgrade
    └── db_providers.dart       # appDatabaseProvider (FutureProvider<AppDatabase>, keepAlive, closes on dispose)
    ```
    - `AppDatabaseFactory.create()`: `kIsWeb ? databaseFactoryFfiWeb : databaseFactory` (sqflite). Tests pass `databaseFactoryFfi` + `inMemoryDatabasePath` explicitly (after `sqfliteFfiInit()`). No global `databaseFactory = ...` mutation in app code.
    - `AppDatabase.open` uses `OpenDatabaseOptions(version: appMigrations.last.version, onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'), onCreate: run all migrations, onUpgrade: run migrations with oldVersion < m.version <= newVersion)`, every migration inside one transaction.
    - At init `appMigrations` contains ONE migration (version 1) that creates a technical table `app_meta (key TEXT PRIMARY KEY NOT NULL, value TEXT NOT NULL)` so the migration pipeline is exercised by tests. No business tables at init.
    - The hello screen does NOT open the database. The DB is opened lazily the first time `appDatabaseProvider` is read.
- Each feature gets its own repository: an abstract interface in `domain/`, a SQLite implementation in `data/` (`Sqlite<Name>Repository`) that receives `AppDatabase` in the constructor. Table and column names are `snake_case`; row mapping lives in the data layer (`<Name>Row`/mapper with `factory fromRow(Map<String, Object?> row)` + `toRow()`), domain entities never know about SQL.
- Dates stored as INTEGER (UTC epoch milliseconds), booleans as INTEGER 0/1, money as INTEGER minor units (cents), enums as TEXT (`enum.name`).

METHODOLOGY: TEST-DRIVEN DEVELOPMENT (STRICT):
Every feature, fix and infrastructure piece follows this order. Never write implementation before the test exists.
1. MODEL FIRST: design and write the domain model (immutable entities/value objects with `const` constructors, `==`/`hashCode`, `copyWith`, validation in factory constructors) and the repository/service INTERFACES. No logic yet.
2. WRITE TESTS: write the unit/integration/widget tests covering the expected behavior (happy path, edge cases, validation errors, persistence round-trip through SQLite in-memory). Run `flutter test` and confirm they FAIL for the right reason (missing implementation, not compile errors in unrelated code).
3. IMPLEMENTATION: write the MINIMAL code needed to make the tests pass. Run `flutter test` until green. Then refactor with the tests green.
- Test layout mirrors `lib/` (`test/core/db/app_database_test.dart`, `test/features/<domain>/domain/...`, `.../data/...`, `.../application/...`, `.../presentation/...`).
- Test kinds:
    - Domain: pure Dart unit tests (no Flutter, no DB).
    - Data: repository tests against REAL SQLite in memory (`sqflite_common_ffi`, fresh `AppDatabase.open(factory: databaseFactoryFfi, path: inMemoryDatabasePath)` per test in `setUp`, `close()` in `tearDown`). Never mock the database.
    - Application/state: Riverpod tests with `ProviderContainer.test(overrides: [...])` (repositories overridden with in-memory SQLite implementations or simple fakes).
    - Presentation: widget tests that locate EVERY element by its test ID (`find.byKey(const ValueKey(TestIds.x))`), never by text or type.
- Test data via BUILDERS (`test/support/builders/<name>_builder.dart`: `UserBuilder().withName('Ann').build()`), sensible defaults, so tests only state what matters. Shared helpers in `test/support/` (e.g. `openTestDatabase()`, `pumpApp(tester, overrides:)` that wraps in `ProviderScope` + `MaterialApp(theme: buildAppTheme())`).
- `flutter test` must be fully green before any task is considered done.

ARCHITECTURE: DOMAIN-DRIVEN DESIGN & DESIGN PATTERNS:
- Feature-first, one folder per bounded context/domain under `lib/features/<domain>/`, each split in layers. Dependencies point inward only: `presentation -> application -> domain <- data`. `domain/` imports nothing from Flutter, sqflite or Riverpod.
    - `domain/`: entities, value objects, domain errors, repository interfaces, pure domain services.
    - `data/`: SQLite repository implementations, row mappers, (optional) remote HTTP clients in `data/remote/` (`*_api.dart`, base URL from `const String.fromEnvironment('API_BASE_URL')`).
    - `application/`: use cases / feature FACADE (`<Domain>Facade` exposing the operations the UI needs, orchestrating repositories and transactions) and the Riverpod providers/notifiers (state atoms) of the feature.
    - `presentation/`: pages and feature-specific widgets. Widgets talk to `application/` only, never to repositories or the DB directly.
- Cross-feature code lives in `lib/core/` (theme, db, design-system widgets, global state atoms, test IDs). Features never import each other's `data/` or `presentation/`; if two features need the same thing, move it to `core/` or expose it through the other feature's `application/` facade.
- Actively use established design patterns where they fit (and name the classes after them):
    - FACTORY: `factory` constructors for validated creation and mapping (`Money.fromCents`, `UserRow.fromRow`), `AppDatabaseFactory` for the platform-specific DB factory, factories for creating repositories/notifiers in providers.
    - BUILDER: test data builders (mandatory), builders for complex objects or SQL fragments (`WhereBuilder` collecting `where` + `whereArgs`) when construction has many optional parts.
    - FACADE: `AppDatabase` over sqflite; one `<Domain>Facade` per feature over its repositories/services.
    - Also when justified: Repository (mandatory for persistence), Strategy (interchangeable algorithms), Adapter (external APIs -> domain), Observer (Riverpod already covers it).
- Do not add patterns for their own sake; each pattern must remove duplication or coupling.

STATE MANAGEMENT (ATOMIC / GLOBAL, NO PROP DRILLING):
- `flutter_riverpod` (latest stable, 3.x) is the ONLY state management solution. Its providers are used as ATOMS (conceptually identical to Jotai in React): small, independent, globally addressable pieces of state that any widget can read and mutate directly.
- NO prop drilling: never pass state or callbacks down more than ONE widget level just to reach a descendant. A descendant that needs the state reads it itself via `ref.watch(atom)` / mutates via `ref.read(atom.notifier).method()`. Constructor parameters are only for static configuration (ids, labels) or for the item a list row renders.
- Naming: atoms are top-level `final` variables named `<name>State` (e.g. `userState`, `cartState`), notifiers `<Name>Notifier`. Derived/read-only atoms are plain `Provider`s (`final isLoggedInState = Provider<bool>((ref) => ref.watch(userState) != null);`).
- GLOBAL shared entities (e.g. the current user, settings) are app-wide atoms in `lib/core/state/` (or the owning feature's `application/` when only that feature mutates it), accessible from every screen:
    ```dart
    final userState = NotifierProvider<UserNotifier, User?>(UserNotifier.new);

    class UserNotifier extends Notifier<User?> {
      @override
      User? build() => null;

      void signIn(User user) => state = user;
      void signOut() => state = null;
    }
    ```
    Async data from SQLite -> `AsyncNotifierProvider` (`build()` loads from the facade, methods write through the facade then update `state`), UI uses `switch (ref.watch(x)) { AsyncData(:final value) => ..., AsyncError() => ..., _ => ... }`.
- PARENT-SCOPED state (parent -> child -> grandchild structures, e.g. a form, a wizard, a detail page): the state is encapsulated at the PARENT level and every descendant accesses and mutates it directly, without props:
    ```dart
    final orderFormState = NotifierProvider<OrderFormNotifier, OrderForm>(OrderFormNotifier.new, dependencies: const []);

    // Parent: creates a fresh, isolated instance for its subtree
    ProviderScope(overrides: [orderFormState.overrideWith(OrderFormNotifier.new)], child: const OrderFormBody());

    // Any child/grandchild (ConsumerWidget):
    final form = ref.watch(orderFormState);
    ref.read(orderFormState.notifier).setQuantity(2);
    ```
    For state keyed by an id (one instance per entity) use `.family` instead of scoping. Use `autoDispose` for screen-level state that must reset when the screen is closed.
- `StatefulWidget` + `setState` only for purely visual, ephemeral, single-widget state (animation controllers, `TextEditingController`, focus, hover). Everything else is an atom.
- `ProviderScope` wraps the whole app in `main.dart`. Widgets that read state are `ConsumerWidget` / `ConsumerStatefulWidget`. Use `ref.select` to avoid rebuilding on unrelated changes. No Riverpod code generation (`riverpod_generator`) unless the user asks for it.

UI TEST IDS (EVERY ELEMENT, NON-NEGOTIABLE):
- EVERY single UI element we build (pages, scaffolds, texts, buttons, inputs, list rows, icons, cards, dialogs, menu items, ...) MUST have a UNIQUE, stable ID for deterministic automated UI testing. Flutter has no HTML `id`, so the ID is applied in two places at once:
    1. `key: ValueKey<String>(id)` — used by Flutter widget/integration tests (`find.byKey`).
    2. `Semantics(identifier: id)` — exposed to native automation as Android `resource-id` and iOS `accessibilityIdentifier` (Appium, Maestro, Patrol) and as the `flt-semantics-identifier` attribute on Flutter web.
- All IDs are constants in `lib/core/testing/test_ids.dart` (no inline string IDs anywhere else):
    ```dart
    abstract final class TestIds {
      static const homePage = 'home.page';
      static const homeHelloText = 'home.hello_text';

      static const all = <String>[homePage, homeHelloText];
    }
    ```
    Format: `<feature>.<element>` / `<feature>.<page>.<element>` in lower_snake_case segments. Elements repeated in lists get the entity id appended via a function: `static String todoRow(String id) => 'todo.row.$id';` (not listed in `all`).
- Apply IDs with ONE helper, `lib/core/testing/test_id.dart`:
    ```dart
    extension TestIdX on Widget {
      Widget testId(String id) => Semantics(identifier: id, container: true, child: KeyedSubtree(key: ValueKey<String>(id), child: this));
    }
    ```
    Usage: `const Text('hello').testId(TestIds.homeHelloText)`. Every widget returned from our `build` methods that renders something visible or interactive gets `.testId(...)`; pure layout wrappers (`Padding`, `SizedBox`, `Row`, `Column`, `Expanded`) only when a test needs to target them.
- Tests: `test/core/testing/test_ids_test.dart` asserts `TestIds.all` has no duplicates (`toSet().length == all.length`). Every widget test asserts its elements with `findsOneWidget` by ID. A new ID is added to `TestIds.all` in the same change that uses it.

UNIFIED DESIGN SYSTEM & THEME (MOBILE MIRRORING):
The Web app uses the EXACT out-of-the-box PrimeReact (https://primereact.dev/) theme: preset Aura, primary palette emerald, surface palette slate, DARK MODE ONLY.
There is no PrimeReact for Flutter, so the look is reproduced through ONE `ThemeData` plus a few small custom widgets, using these exact resolved tokens (single source of truth: `lib/core/theme/app_colors.dart`, never hard-code colors elsewhere):
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
- Spacing scale (4px base): 4 / 8 / 12 / 16 / 20 / 24 / 32 (`AppSpacing`). Card padding 20, gaps 16 between blocks, 8 between form controls.
- Dark mode is always on: `brightness: Brightness.dark`, `themeMode: ThemeMode.dark`, light status bar icons via `AnnotatedRegion<SystemUiOverlayStyle>(value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent, systemNavigationBarColor: AppColors.background))`.
- At init, create `app_colors.dart` (AppColors, AppRadius, AppSpacing, Breakpoints) and `app_theme.dart` (complete `buildAppTheme()` + `textButtonSeverity()`) in full, even though only the hello screen uses them.

FONTS & ICONS:
- Font: Inter, bundled as assets (NOT the `google_fonts` package: no runtime download, works offline, identical on every device). Files `assets/fonts/Inter_400Regular.ttf`, `Inter_500Medium.ttf`, `Inter_600SemiBold.ttf` (take them from the npm package `@expo-google-fonts/inter` or Google Fonts) + the `OFL.txt` license, declared in `pubspec.yaml` as family `Inter` with `weight: 400/500/600`; `ThemeData(fontFamily: 'Inter')`. Added at init.
- Icons (on demand, NOT at init): PrimeIcons, identical to the Web app's `@primeicons/react`. Generate SVG files from the npm package `@primeicons/core` (each icon module exports `{ svg: { viewBox }, nodes: [[tag, attrs]] }`; write `<svg viewBox=...>` with the nodes, replacing `currentColor` with `#000000`) into `assets/icons/<name>.svg`. Render with `flutter_svg` (added together with the first icon):
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

THEME (`lib/core/theme/app_theme.dart`) — MANDATORY SETTINGS:
- `useMaterial3: true`, `splashFactory: NoSplash.splashFactory` (Aura has no ripple; state feedback is done with colors), `scaffoldBackgroundColor: AppColors.background`.
- `colorScheme: ColorScheme.dark(primary: primary, onPrimary: primaryContrast, surface: surface, onSurface: text, error: danger, outline: border)`.
- `textSelectionTheme`: cursor/handles primary, selection primary 30%.
- `inputDecorationTheme`: `filled: true`, `fillColor: fieldBackground`, `isDense: true`, `contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)`, `OutlineInputBorder(radius 6, side fieldBorder)` for border/enabledBorder, focusedBorder side primary, `hintStyle` placeholder 16.
- `filledButtonTheme` (= PrimeReact primary `<Button>`): background resolves pressed -> primaryActive, hovered -> primaryHover, else primary; foreground primaryContrast; `overlayColor` transparent; elevation 0; padding h12 v8; `minimumSize: Size(0, 40)`; shape radius 6; text Inter 16 w500; `tapTargetSize: MaterialTapTargetSize.shrinkWrap`.
- `textButtonTheme` (= PrimeReact `variant="text"`): same padding/shape/text, `minimumSize: Size(40, 40)`. Severity variants via a helper `textButtonSeverity(Color c)`: foreground c, overlay pressed c 16% / hovered c 4% / else transparent.
- Also theme every other Material widget you use with the same tokens before using it: `dialogTheme` (surface, radius 12), `dropdownMenuTheme`/`menuTheme` (surface, border, radius 6), `snackBarTheme` (surface, text, border), `dividerTheme` (border, 1px), `tooltipTheme` (surface + border, text 12), `progressIndicatorTheme` (primary on border), `switchTheme`/`radioTheme` (primary/fieldBorder), `chipTheme`, `bottomSheetTheme`, `navigationBarTheme` (surface, indicator = highlight).
- Use `Color.withValues(alpha: x)` (never the deprecated `withOpacity`).

COMPONENT MAPPING (PrimeReact -> Flutter, created on demand in `lib/core/widgets/`):
- Every design-system widget accepts a required `String id` (or the caller applies `.testId(...)`) so the UI TEST IDS rule holds.
- `<Button>` -> `FilledButton` / `FilledButton.icon(icon: AppIcon(..., color: AppColors.primaryContrast), label: Text(...))` (SVG icons do not inherit `IconTheme`, always pass the color).
- `<Button severity="danger" variant="text">` -> `TextButton(style: textButtonSeverity(AppColors.danger), child: AppIcon(PrimeIcon.trash, color: AppColors.danger))`, wrapped in `Semantics(label:, button: true)` when icon-only.
- `<InputText>` -> `TextField` (themed, `style: TextStyle(fontSize: 16, color: AppColors.text)`).
- `<Checkbox>` -> custom `AppCheckbox` (Material's checkbox has different size/shape): 20x20, radius 4, border fieldBorder + background fieldBackground; checked = primary fill + primary border + `PrimeIcon.check` 14px in primaryContrast; 6px padding as touch area; `AnimatedContainer` 150ms; `Semantics(checked:, label:)`.
- `<Card>` -> custom `AppCard(title, subtitle, aside?, child)`: `Container(padding 20, BoxDecoration(color surface, radius 12))`, NO border and NO shadow (matches Aura dark card), header = `Wrap(alignment: spaceBetween, crossAxisAlignment: end, spacing 8, runSpacing 8)` with title (20 w500 white) + subtitle (16 muted) on the left and optional `aside` (key figure etc.) on the right, then `child` 16 below.
- List rows (e.g. todo items) -> `Container(border 1 border, radius 6, padding h6 v2)` + `Row(spacing: 6)`; done text muted + `TextDecoration.lineThrough` with `decorationColor` muted.
- `<Dialog>` -> `showDialog` with themed `Dialog`; `<Toast>` -> themed `SnackBar`; `<Select>` -> themed `DropdownMenu`; `<Tag>` -> small `Container` (radius 6, highlight background, primary text 12 w500).
- Prefer composing these small widgets in `lib/core/widgets/` over adding UI kits. NO third-party UI kits (GetWidget, VelocityX, etc.).

RESPONSIVE FLEX LAYOUT (NON-NEGOTIABLE):
- Flutter's `Row`/`Column`/`Flex`/`Expanded`/`Flexible`/`Wrap` ARE the flexbox equivalent; build every layout with them. Use `spacing:` on `Row`/`Column`/`Wrap` instead of `SizedBox` gaps.
- Breakpoints mirror Tailwind exactly (`lib/core/theme/app_colors.dart`): `Breakpoints.sm = 640`, `md = 768`, `lg = 1024`, `xl = 1280` (logical px of the window width, `MediaQuery.sizeOf(context).width` or `LayoutBuilder`).
- Mobile-first: default single column (`Column(crossAxisAlignment: stretch)`), switch to `Row` at the same breakpoints the Web app uses (e.g. Web `flex-col sm:flex-row` -> `width >= Breakpoints.sm ? Row(...) : Column(...)`; Web `xl:flex-row` with `xl:flex-[2]` / `xl:flex-1` -> `Row(children: [Expanded(flex: 2, ...), Expanded(...)])`).
- NO fixed widths for containers (use `Expanded`, `Flexible`, `double.infinity`, `ConstrainedBox(maxWidth)`); heights only where content requires it (charts: ratio of screen height with a minimum, see charts).
- Page shell: `Scaffold` -> `SafeArea` -> `SingleChildScrollView(padding: EdgeInsets.all(width >= Breakpoints.md ? 32 : 16))`. Lists with many items -> `ListView.builder` / `SliverList`.
- Orientation: allow portrait and landscape; layouts must adapt (tablets/landscape reach the `md`/`xl` layouts).

TECHNICAL ARCHITECTURE & CODING STANDARDS:
1. Flutter stable (3.41+), Dart 3.11+. Use modern Dart: records, patterns, `switch` expressions, sealed classes for domain errors/states, null-aware collection elements (`?widget`), `Row/Column spacing`.
2. Structure (`<APP_DIR>`):
   ```
   <APP_DIR>/
   ├── pubspec.yaml
   ├── analysis_options.yaml      # include flutter_lints, formatter page_width 140
   ├── assets/fonts/              # Inter 400/500/600 + OFL.txt
   ├── lib/
   │   ├── main.dart              # WidgetsFlutterBinding.ensureInitialized(); runApp(const ProviderScope(child: App()))
   │   ├── app.dart               # App: AnnotatedRegion + MaterialApp(title: APP_NAME, theme: buildAppTheme(), themeMode: dark, debugShowCheckedModeBanner: false, home: HomePage())
   │   ├── core/
   │   │   ├── theme/app_colors.dart    # AppColors, AppRadius, AppSpacing, Breakpoints (single source of truth)
   │   │   ├── theme/app_theme.dart     # buildAppTheme(), textButtonSeverity()
   │   │   ├── db/                      # AppDatabaseFactory, Migration, appMigrations, AppDatabase, appDatabaseProvider
   │   │   ├── state/                   # global atoms shared by many features (userState, ...) — empty (.gitkeep) at init
   │   │   ├── testing/test_ids.dart    # TestIds
   │   │   ├── testing/test_id.dart     # .testId() extension
   │   │   └── widgets/                 # design-system widgets (AppIcon, AppCard, AppCheckbox, ...) — empty (.gitkeep) at init
   │   ├── features/
   │   │   └── <domain>/
   │   │       ├── domain/              # entities, value objects, repository interfaces (pure Dart)
   │   │       ├── data/                # Sqlite<Name>Repository, row mappers, remote/ (optional)
   │   │       ├── application/         # <Domain>Facade, atoms/notifiers
   │   │       └── presentation/        # pages, feature widgets
   │   │   (at init only: features/home/presentation/home_page.dart)
   │   └── charts/                  # Only when IS_CHARTS_NEEDED: true
   ├── test/                        # mirrors lib/ + test/support/ (builders, openTestDatabase, pumpApp)
   └── web/                         # preview only (+ sqlite3.wasm, sqflite_sw.js)
   ```
3. Models are immutable classes with `const` constructors, `==`/`hashCode`, `copyWith`, and hand-written mapping (`fromRow`/`toRow` in the data layer, `fromJson`/`toJson` for remote DTOs). No `freezed`/`json_serializable` code generation unless the user asks for it.
4. Lints: `flutter_lints`; `flutter analyze` must report "No issues found!". Format with `dart format -l 140` (also set `formatter: page_width: 140` in `analysis_options.yaml`).
5. Every package you `import` must be listed directly in `pubspec.yaml` (e.g. `syncfusion_flutter_core` for `package:syncfusion_flutter_core/theme.dart`), otherwise `depend_on_referenced_packages` fails. Add packages with `flutter pub add <pkg>` / `flutter pub add dev:<pkg>` (latest compatible versions), never hand-type versions.
6. Visual verification (later tasks, NOT at init, and only when the user agrees to run the app): `flutter build web --release`, serve `build/web` and screenshot at 600px and 1600px width. Flutter web uses the same rendering engine as mobile, so it is a faithful preview. Compare side by side with the Web (React) app.
7. Android app label in `android/app/src/main/AndroidManifest.xml` (`android:label`) and iOS `CFBundleDisplayName` (`ios/Runner/Info.plist`) set to `APP_NAME`.
8. Task tracking: the repo root contains `tasks/todo/` and `tasks/done/` (each with an empty `.gitkeep`). Task files are Markdown (`tasks/todo/<NNN>-<short-name>.md`); when a task is finished, move its file to `tasks/done/`.

INIT PROCEDURE (FIRST RUN ONLY — EXECUTE IN ORDER):
1. Check the toolchain: `flutter --version` (Flutter 3.41+ stable, Dart 3.11+). If `<APP_DIR>` already contains a Flutter project, STOP and ask the user before touching it.
2. Create the project: `flutter create --org <ORG> --project-name <PACKAGE_NAME> --platforms android,ios,web --empty <APP_DIR>`. Remove any generated sample/counter code and the default `test/widget_test.dart`.
3. Dependencies (from `<APP_DIR>`): `flutter pub add flutter_riverpod sqflite sqflite_common_ffi_web path` and `flutter pub add dev:sqflite_common_ffi` (`flutter_lints` is already present). Then `dart run sqflite_common_ffi_web:setup`.
4. `analysis_options.yaml`: `include: package:flutter_lints/flutter.yaml`, `formatter: page_width: 140`.
5. Fonts: download Inter 400/500/600 TTF + `OFL.txt` into `assets/fonts/`, declare them in `pubspec.yaml`.
6. Theme: `lib/core/theme/app_colors.dart` + `app_theme.dart` complete as specified.
7. Test IDs (TDD): write `test/core/testing/test_ids_test.dart` first, then `test_ids.dart` + `test_id.dart`.
8. Database (TDD): write `test/support/open_test_database.dart` and `test/core/db/app_database_test.dart` FIRST (opens in-memory DB, `PRAGMA user_version` == latest migration version, `app_meta` table exists, foreign keys ON, migrations run in ascending order and only the missing ones on upgrade, `close()` works). Watch them fail, then implement `lib/core/db/*` until green.
9. Hello screen (TDD): write `test/features/home/presentation/home_page_test.dart` FIRST (pumps `App` inside `ProviderScope`; finds `TestIds.homePage` and `TestIds.homeHelloText` with `findsOneWidget`; text is exactly `hello`; scaffold background is `AppColors.background`). Then implement `home_page.dart` (`Scaffold(backgroundColor: AppColors.background, body: Center(child: Text('hello')))` with both IDs applied), `app.dart`, `main.dart`.
10. Create empty folders with `.gitkeep`: `lib/core/state/`, `lib/core/widgets/`, `test/support/builders/`.
11. Set the Android label and iOS `CFBundleDisplayName` to `APP_NAME`; lock nothing else (portrait + landscape allowed).
12. At the REPO ROOT create `tasks/todo/.gitkeep` and `tasks/done/.gitkeep` (empty files).
13. Verify (from `<APP_DIR>`): `dart format -l 140 .`, `flutter analyze` ("No issues found!"), `flutter test` (all green). Fix until all three pass. Do NOT run the app.
14. Print a 1-2 sentence summary and ask: "Do you want me to start the app?" Do not start it unless the user says yes.

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
- Every chart widget, legend item and range selector gets a test ID (`.testId(...)`) like any other UI element.

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
Pure helpers (`niceRange`, derived series like moving averages) are written test-first like any other code.

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
- Charts receive typed, already-loaded data (`List<Candle>` etc.) from atoms/facades; no fetching or DB access inside chart widgets.
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
- SQLite only; TDD order (model -> tests -> implementation) visible in every change; DDD layering respected; state via Riverpod atoms with no prop drilling; every UI element carries a unique test ID.
- `dart format -l 140` applied, `flutter analyze` clean, `flutter test` green.
- The app must look like a direct twin of the Web PrimeReact application (Aura dark, emerald/slate) on every screen size and orientation.
- Respect `PROJECT CONFIG` and `PROJECT FLAGS` at the top of this prompt in every answer.
- Never run the app without asking; at the end of the init, ask "Do you want me to start the app?".
