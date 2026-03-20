# flutter-SKILLS.md
# DML Hub — Master Flutter Skills Reference
# Company: DML Labs | Package: com.dmllabs.hub | Android-first
# Attach: When working on ANY Flutter layer — structure, build, test, perf, CI
# Always attach ALONGSIDE: SYSTEM_PROMPT.md
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---

## ⚠️ EVOLUTION RULE — READ BEFORE ANY SECTION

```
This file contains a CURRENT SNAPSHOT of structure and patterns.

RULE 1 — ACTUAL BEATS SNAPSHOT:
  If the real codebase differs from ANY map in this file:
  → FOLLOW the actual codebase
  → NEVER follow this file blindly over what exists on disk

RULE 2 — BEFORE CREATING A NEW FILE:
  → Check if the target folder exists in the real project first
  → If location is ambiguous: ASK the user, never guess

RULE 3 — BEFORE CREATING A NEW FOLDER:
  → NEVER create a new top-level folder without explicit instruction
  → New feature = new folder inside lib/features/{name}/
  → New shared util = goes inside lib/core/{closest-category}/

RULE 4 — WHEN STRUCTURE CHANGES:
  → The PRINCIPLES in each section remain true regardless of folder names
  → Folder paths = reference snapshot, not law
  → Principles = law
```

---

## ━━━ SKILL 1 — PROJECT STRUCTURE ━━━━━━━━━━━━━━━━━━━━━━━━━

### Principles (permanent — folder names may change, these never do)
```
P1: lib/ contains ONLY Dart code — no assets, no configs
P2: features/ = one folder per plugin/feature — fully self-contained
P3: core/ = shared kernel — zero feature-specific code
P4: main.dart = bootstrap ONLY — no UI, no business logic
P5: test/ mirrors lib/ structure exactly (test/features/todo/ mirrors lib/features/todo/)
P6: No file exceeds 300 lines — split if it does
P7: No cross-feature imports — features NEVER import from each other
    Exception: hub/ may read a provider from a plugin (for quick stats only)
```

### Current Snapshot (update label when structure changes)
```
# SNAPSHOT v1.0 — MVP structure
lib/
├── core/
│   ├── constants/         # AppRoutes · AppSpacing · AppConstants
│   ├── di/                # get_it injection container
│   ├── error/             # Failure classes · Exception classes
│   ├── extensions/        # BuildContext · String · DateTime extensions
│   ├── router/            # GoRouter instance + route definitions
│   ├── theme/             # AppTheme · AppColors · AppTextStyles
│   ├── usecases/          # UseCase<T,P> + UseCaseNoParams<T> base classes
│   ├── utils/             # logger (talker singleton)
│   └── widgets/           # AsyncValueWidget · AppLoadingWidget · AppErrorWidget
│
├── features/
│   ├── hub/               # Hub shell — plugin launcher + settings + biometric
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── todo/              # To-Do plugin — MVP feature
│       ├── data/
│       │   ├── database/  # AppDatabase · tables/ · daos/
│       │   ├── datasources/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── providers/
│           ├── screens/
│           └── widgets/
│
└── main.dart

# Future plugin slot pattern (add when implementing):
# lib/features/{plugin-name}/data/ domain/ presentation/

test/
├── core/
└── features/
    └── todo/
        └── domain/
            └── usecases/   # unit tests only for MVP
```

### What goes WHERE — quick reference
```
Entity (pure Dart, no Flutter)     → features/{f}/domain/entities/
Repository interface               → features/{f}/domain/repositories/
Use case                           → features/{f}/domain/usecases/
Drift table definition             → features/{f}/data/database/tables/
DAO                                → features/{f}/data/database/daos/
Repository implementation          → features/{f}/data/repositories/
Riverpod provider                  → features/{f}/presentation/providers/
Full screen widget                 → features/{f}/presentation/screens/
Reusable feature widget            → features/{f}/presentation/widgets/
Reusable cross-feature widget      → core/widgets/
App-wide constant                  → core/constants/
Color/theme token                  → core/theme/
Route path string                  → core/constants/app_routes.dart
Error/Failure class                → core/error/failures.dart
```

### What NEVER goes where
```
❌ Flutter import in domain/         (domain = pure Dart)
❌ Business logic in presentation/   (providers = orchestration only)
❌ DAO call outside data/            (always through repository)
❌ Magic string/number outside core/ (always a named constant)
❌ Feature code in core/             (core has zero feature knowledge)
```

---

## ━━━ SKILL 2 — pubspec.yaml PATTERNS ━━━━━━━━━━━━━━━━━━━━━━

### Version strategy
```yaml
# version: MAJOR.MINOR.PATCH+BUILD
# BUILD = auto-incremented on every CI build
# MAJOR = breaking changes to plugin API
# MINOR = new feature shipped
# PATCH = bug fix
version: 1.0.0+1
```

### Asset declaration pattern
```yaml
flutter:
  uses-material-design: true

  assets:
    - assets/images/          # PNG/JPG/WebP
    - assets/icons/           # SVG icons (if using flutter_svg later)
    - assets/lottie/          # Lottie JSON (if added later)
    # RULE: declare folder, not individual files
    # RULE: folder MUST exist even if empty — create .gitkeep

  fonts:
    - family: NunitoSans
      fonts:
        - asset: assets/fonts/NunitoSans-Regular.ttf
        - asset: assets/fonts/NunitoSans-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/NunitoSans-Bold.ttf
          weight: 700
        - asset: assets/fonts/NunitoSans-ExtraBold.ttf
          weight: 800
    # RULE: always bundle fonts — never rely on google_fonts network in release
```

### Dependency constraint rules
```yaml
# RULE: use ^ for minor-compatible (^2.5.1 = >=2.5.1 <3.0.0)
# RULE: pin exact version only when package has known breaking patch releases
# RULE: never use 'any' — always constrain
# RULE: dev_dependencies use ^ always

dependencies:
  some_package: ^2.5.1       # ✅ recommended
  critical_package: 2.5.1    # ✅ exact pin when needed
  bad_package: any           # ❌ never
```

---

## ━━━ SKILL 3 — ENVIRONMENTS & FLAVORS ━━━━━━━━━━━━━━━━━━━━━

### Flavor strategy (dev + prod, no staging for MVP)
```
lib/
├── main.dart          # ← DO NOT USE DIRECTLY
├── main_dev.dart      # flutter run --flavor dev -t lib/main_dev.dart
└── main_prod.dart     # flutter build apk --flavor prod -t lib/main_prod.dart
```

### main_dev.dart pattern
```dart
/// Development entry point.
/// Uses: verbose logging · debug banner · dev app name
void main() async {
  await _bootstrap(AppEnvironment.dev);
}
```

### main_prod.dart pattern
```dart
/// Production entry point.
/// Uses: error-only logging · no debug banner · real app name
void main() async {
  await _bootstrap(AppEnvironment.prod);
}
```

### AppEnvironment pattern
```dart
/// App environment configuration.
/// Injected at startup — never read from dart-define at runtime.
enum AppEnvironment { dev, prod }

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.appName,
    required this.logLevel,
  });

  final AppEnvironment environment;
  final String appName;
  final TalkerLogType logLevel;

  bool get isDev  => environment == AppEnvironment.dev;
  bool get isProd => environment == AppEnvironment.prod;

  static const dev = AppConfig(
    environment: AppEnvironment.dev,
    appName: 'DML Hub DEV',
    logLevel: TalkerLogType.verbose,
  );

  static const prod = AppConfig(
    environment: AppEnvironment.prod,
    appName: 'DML Hub',
    logLevel: TalkerLogType.error,
  );
}
```

### android/app/build.gradle flavor config
```groovy
android {
    flavorDimensions "environment"

    productFlavors {
        dev {
            dimension "environment"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
            resValue "string", "app_name", "DML Hub DEV"
        }
        prod {
            dimension "environment"
            resValue "string", "app_name", "DML Hub"
        }
    }
}
```

### MVP shortcut (single environment — no flavor needed)
```
If building MVP without flavors:
→ Use main.dart directly
→ Replace AppConfig.dev/prod with a single AppConfig.current
→ Migrate to flavors when you need separate dev/prod app IDs on device
```

---

## ━━━ SKILL 4 — CLEAN ARCHITECTURE LAYER CONTRACTS ━━━━━━━━━━

### Layer import law (violation = architecture bug)
```
domain/     → imports: dart:core, dartz, freezed_annotation ONLY
             → NEVER imports: flutter, drift, dio, get_it, riverpod

data/       → imports: domain/ + drift + flutter_secure_storage + packages
             → NEVER imports: presentation/

presentation/ → imports: domain/ + riverpod + flutter + go_router
              → NEVER imports: data/ directly
              → NEVER imports: drift / DAOs

core/       → imports: dart:core + approved packages
             → NEVER imports: features/
```

### Data flow (one direction only)
```
UI Event
  ↓
Riverpod Provider          (presentation — orchestrates)
  ↓
Use Case                   (domain — validates + business logic)
  ↓
Repository Interface       (domain — contract)
  ↓
Repository Implementation  (data — concrete)
  ↓
DAO / DataSource           (data — persistence)
  ↓
Drift / SecureStorage      (data — storage engine)
```

### ASCII layer diagram
```
┌─────────────────────────────────────────┐
│  PRESENTATION  (Flutter + Riverpod)     │ ← User sees this
│  screens/ · widgets/ · providers/       │
└──────────────┬──────────────────────────┘
               │ reads/calls
┌──────────────▼──────────────────────────┐
│  DOMAIN  (Pure Dart — no Flutter)       │ ← Business rules live here
│  entities/ · usecases/ · repositories/ │
└──────────────┬──────────────────────────┘
               │ implemented by
┌──────────────▼──────────────────────────┐
│  DATA  (Drift + SecureStorage)          │ ← Persistence lives here
│  daos/ · repositories_impl/ · models/  │
└─────────────────────────────────────────┘
               ↕ both depend on
┌─────────────────────────────────────────┐
│  CORE  (Shared Kernel)                  │
│  errors/ · di/ · router/ · theme/      │
└─────────────────────────────────────────┘
```

---

## ━━━ SKILL 5 — CODE GENERATION (build_runner) ━━━━━━━━━━━━━━

### Generation order (MATTERS — wrong order = compile errors)
```
1. freezed          → generates *.freezed.dart (entities, params, states)
2. json_serializable → generates *.g.dart (fromJson/toJson on DTOs)
3. drift_dev         → generates app_database.g.dart + DAO mixins
4. riverpod_generator → generates *.g.dart (provider boilerplate)
```

### Commands
```bash
# One-time full build (use after: adding new annotated class)
dart run build_runner build --delete-conflicting-outputs

# Watch mode (use during: active development session)
dart run build_runner watch --delete-conflicting-outputs

# RULE: always use --delete-conflicting-outputs
# RULE: if build fails — run build (not watch) once to see full error
# RULE: never manually edit *.g.dart or *.freezed.dart files
```

### Common build_runner errors + fixes
```
ERROR: "Could not find a generator for..."
FIX:   Class missing annotation (@freezed / @riverpod / @DriftDatabase)

ERROR: "The method X is not defined for the class..."
FIX:   Generated file is stale → run build then hot restart

ERROR: "Conflicts detected"
FIX:   dart run build_runner build --delete-conflicting-outputs

ERROR: "No such file: *.freezed.dart"
FIX:   Run build before flutter run — generated files don't exist yet

ERROR: Two generators fighting over same output file
FIX:   Add @JsonSerializable() ONLY on DTOs, NEVER on @freezed entities
       (freezed handles its own json generation internally)
```

### What each generator produces
```
@freezed class Foo           → foo.freezed.dart (copyWith, ==, toString, pattern match)
@JsonSerializable() class    → foo.g.dart (fromJson, toJson)
@riverpod / @Riverpod()      → foo.g.dart (provider ref + code-gen boilerplate)
@DriftDatabase               → app_database.g.dart (query engine, DAO mixins)
@DriftAccessor               → task_dao.g.dart (mixin for DAO class)
```

---

## ━━━ SKILL 6 — DEPENDENCY INJECTION LIFECYCLE ━━━━━━━━━━━━━━

### Registration type decision matrix
```
TYPE                  USE WHEN                              EXAMPLE
─────────────────────────────────────────────────────────────────────
registerSingleton     One instance forever, sync create    AppDatabase, DAOs, Logger
registerLazySingleton One instance, created on first use   Repos (no startup cost)
registerFactory       New instance per call                UseCases (stateless)
registerSingletonAsync One instance, async init required   NotificationService.init()
registerFactoryAsync  New instance, async create           (rare — avoid)
```

### Pattern: registerSingleton vs registerLazySingleton
```dart
// registerSingleton: created IMMEDIATELY at initializeDependencies()
// Use for: things that MUST exist before app starts (DB, logger)
getIt.registerSingleton<AppDatabase>(AppDatabase());

// registerLazySingleton: created on FIRST getIt<T>() call
// Use for: things that can wait (repositories, services)
getIt.registerLazySingleton<TaskRepository>(
  () => TaskRepositoryImpl(taskDao: getIt<TaskDao>()),
);

// registerFactory: NEW instance every call
// Use for: use cases (they are stateless — no benefit sharing one)
getIt.registerFactory<CreateTaskUseCase>(
  () => CreateTaskUseCase(getIt<TaskRepository>()),
);
```

### Reset pattern for testing
```dart
/// Call in setUp() of tests that need a clean DI container
Future<void> resetDependencies() async {
  await getIt.reset();
  await initializeDependencies(); // re-register with test fakes
}
```

---

## ━━━ SKILL 7 — WIDGET ARCHITECTURE ━━━━━━━━━━━━━━━━━━━━━━━━━

### Widget type decision rules
```
CONDITION                                    USE
─────────────────────────────────────────────────────────────────
Needs Riverpod state                       → ConsumerWidget
Needs Riverpod + local lifecycle           → ConsumerStatefulWidget
Pure display, no state                     → StatelessWidget (+ const)
Needs animation controller / lifecycle    → StatefulWidget
Never                                      → setState for app state
```

### const optimization rules
```dart
// RULE 1: Mark widget const if constructor args are all const
const TaskCard(task: task)   // ✅ if TaskCard has const constructor
TaskCard(task: task)         // ❌ wastes rebuild cycles

// RULE 2: Extract static children to const
Column(children: [
  const SizedBox(height: 16),    // ✅ const
  const _StaticHeader(),          // ✅ const private widget
  DynamicWidget(data: data),      // ✅ only dynamic part rebuilds
])

// RULE 3: Private widget classes over helper methods
// ❌ Bad — helper method rebuilds entire parent
Widget _buildHeader() => Text('Header');

// ✅ Good — private widget, independent rebuild
class _Header extends StatelessWidget {
  const _Header();
  @override Widget build(BuildContext context) => const Text('Header');
}
```

### Widget size rule
```
Single widget file > 150 lines → extract sub-widgets into:
  Same file as private classes (_WidgetName) if tightly coupled
  Separate file in widgets/ if reusable
```

### ConsumerWidget pattern (canonical)
```dart
/// Task list screen — reads stream of today's tasks.
class TodoTodayPage extends ConsumerWidget {
  const TodoTodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch → rebuilds on change (use in build)
    final tasksAsync = ref.watch(todayTasksProvider);

    return AsyncValueWidget(
      value: tasksAsync,
      data: (either) => either.fold(
        (failure) => AppErrorWidget(message: failure.message),
        (tasks)   => _TaskList(tasks: tasks),
      ),
    );
  }
}
```

---

## ━━━ SKILL 8 — CUSTOM PAINTER ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### When to use CustomPainter
```
USE CustomPainter for:         SKIP CustomPainter for:
─────────────────────────      ─────────────────────────────
Habit completion rings         Standard buttons/cards
Goal progress arcs             Simple colored containers
Calendar day cells             Text and icons
Custom chart bars              Material widgets
Animated path drawing          Linear progress indicators
```

### Performance rules
```dart
// RULE 1: Always wrap in RepaintBoundary
RepaintBoundary(
  child: CustomPaint(painter: HabitRingPainter(progress: 0.75)),
)

// RULE 2: shouldRepaint — only return true when data changes
@override
bool shouldRepaint(HabitRingPainter old) =>
  old.progress != progress || old.color != color;
// ❌ Never: return true; (causes repaint every frame)

// RULE 3: Never call setState from inside paint()
// RULE 4: Use canvas.save() / canvas.restore() when clipping
```

### Canonical CustomPainter pattern
```dart
class ProgressRingPainter extends CustomPainter {
  const ProgressRingPainter({
    required this.progress, // 0.0 to 1.0
    required this.color,
    this.strokeWidth = 6.0,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth;

    // Background track
    canvas.drawCircle(center, radius,
      Paint()
        ..color = color.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,              // start at top
      2 * math.pi * progress,    // sweep
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(ProgressRingPainter old) =>
    old.progress != progress || old.color != color;
}
```

---

## ━━━ SKILL 9 — RESPONSIVE & ADAPTIVE ━━━━━━━━━━━━━━━━━━━━━━━

### Breakpoints (Android-only, still needed for tablets/foldables)
```dart
abstract final class AppBreakpoints {
  static const double compact  = 0;     // phones < 600dp
  static const double medium   = 600;   // tablets, foldables
  static const double expanded = 840;   // large tablets
}

// Usage:
bool isCompact(BuildContext context) =>
  MediaQuery.sizeOf(context).width < AppBreakpoints.medium;
```

### LayoutBuilder pattern (preferred over MediaQuery in widgets)
```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < AppBreakpoints.medium) {
      return const _CompactLayout();
    }
    return const _ExpandedLayout();
  },
)
// RULE: Use LayoutBuilder inside widgets
// RULE: Use MediaQuery.sizeOf(context) at screen/shell level
// RULE: MediaQuery.of(context) → MediaQuery.sizeOf() — avoids unnecessary rebuilds
```

### Safe area rule
```dart
// ALWAYS use SafeArea on screens, NEVER on widgets inside screens
Scaffold(
  body: SafeArea(
    child: _ScreenContent(), // ✅
  ),
)
// ❌ Adding SafeArea inside a Card or ListTile
```

---

## ━━━ SKILL 10 — SLIVER & SCROLL PATTERNS ━━━━━━━━━━━━━━━━━━━

### When to use Slivers vs ListView
```
USE Slivers when:                     USE ListView when:
──────────────────────────────────    ─────────────────────────
Sticky section headers needed         Simple flat list
Collapsing AppBar                     No sticky headers
Mixed list + grid sections            No collapsing header
Multiple content types scrolling      Single content type
```

### Today screen sliver pattern (overdue + today sections)
```dart
CustomScrollView(
  slivers: [
    // ── Overdue Section ──────────────────────────────────
    SliverPersistentHeader(
      pinned: true,
      delegate: _SectionHeaderDelegate(
        title: 'Overdue',
        color: AppColors.error,
      ),
    ),
    SliverList.builder(
      itemCount: overdueTasks.length,
      itemBuilder: (_, i) => TaskCard(task: overdueTask[i]),
    ),

    // ── Today Section ─────────────────────────────────────
    SliverPersistentHeader(
      pinned: true,
      delegate: _SectionHeaderDelegate(
        title: 'Today',
        color: AppColors.dmlBlue,
      ),
    ),
    SliverList.builder(
      itemCount: todayTasks.length,
      itemBuilder: (_, i) => TaskCard(task: todayTasks[i]),
    ),

    // ── Bottom padding ────────────────────────────────────
    const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
    // 80dp = FAB clearance
  ],
)
```

### SliverPersistentHeaderDelegate pattern
```dart
class _SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _SectionHeaderDelegate({required this.title, required this.color});

  final String title;
  final Color color;

  @override double get minExtent => 36;
  @override double get maxExtent => 36;

  @override
  bool shouldRebuild(_SectionHeaderDelegate old) =>
    old.title != title || old.color != color;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Text(title,
        style: GoogleFonts.nunitoSans(
          fontSize: 12, fontWeight: FontWeight.w700,
          color: color, letterSpacing: 0.8,
        ),
      ),
    );
  }
}
```

---

## ━━━ SKILL 11 — RIVERPOD DEEP DIVE ━━━━━━━━━━━━━━━━━━━━━━━━━

### ref rules (most violated)
```dart
// ref.watch  → ONLY in build() — subscribes, causes rebuild on change
// ref.read   → ONLY in callbacks/events — one-time read, no subscription
// ref.listen → ONLY in build() — side effects on change (snackbar, navigate)

// ✅ Correct
Widget build(BuildContext context, WidgetRef ref) {
  final tasks = ref.watch(todayTasksProvider); // in build ✅
  return ElevatedButton(
    onPressed: () => ref.read(createTaskProvider.notifier).call(params), // in callback ✅
  );
}

// ❌ Wrong
onPressed: () => ref.watch(someProvider), // watch in callback ❌
Widget build(...) {
  ref.read(listProvider); // read in build — misses updates ❌
}
```

### Provider family pattern
```dart
// family = parameterized provider
@riverpod
Future<List<Task>> projectTasks(ProjectTasksRef ref, String projectId) {
  return ref.watch(taskRepositoryProvider).watchTasksByProject(projectId);
}

// Usage:
ref.watch(projectTasksProvider('project-uuid-here'))
```

### autoDispose + keepAlive
```dart
// @riverpod → autoDispose by default (provider destroyed when no listeners)
// Add keepAlive when provider must survive navigation
@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) => getIt<AppDatabase>();

// RULE: keepAlive: true for singletons (DB, repos, services)
// RULE: default (autoDispose) for screen-level providers
```

### invalidate vs refresh
```dart
// invalidate → marks stale, provider re-runs on next read/watch
ref.invalidate(todayTasksProvider); // ✅ use after mutations

// refresh → immediately re-runs provider and returns new value
final fresh = ref.refresh(todayTasksProvider); // use when you need value now
```

### AsyncNotifier pattern (for complex async state)
```dart
@riverpod
class TaskList extends _$TaskList {
  @override
  Future<List<Task>> build() async {
    return _fetchTasks();
  }

  Future<void> completeTask(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await getIt<CompleteTaskUseCase>().call(CompleteTaskParams(taskId: id));
      return _fetchTasks();
    });
  }

  Future<List<Task>> _fetchTasks() async {
    final result = await getIt<TaskRepository>().getAllTasks();
    return result.fold((f) => throw f, (tasks) => tasks);
  }
}
```

---

## ━━━ SKILL 12 — ASYNC PATTERNS & ASYNCVALUE ━━━━━━━━━━━━━━━━

### AsyncValue consumption patterns
```dart
// Pattern 1: .when() — handles all states
tasksAsync.when(
  loading: () => const AppLoadingWidget(),
  error:   (e, st) { logger.error('', error: e, stackTrace: st);
                     return AppErrorWidget(message: e.toString()); },
  data:    (tasks) => TaskList(tasks: tasks),
)

// Pattern 2: .whenData() — only transforms data, passes through loading/error
AsyncValue<List<Task>> filtered = tasksAsync.whenData(
  (tasks) => tasks.where((t) => t.priority == TaskPriority.high).toList(),
);

// Pattern 3: .valueOrNull — when you only care about data (loading = null)
final count = ref.watch(taskCountProvider).valueOrNull ?? 0;

// Pattern 4: guard — wraps Future, catches exceptions into AsyncError
state = await AsyncValue.guard(() => repository.fetchTasks());
```

### Optimistic update pattern
```dart
Future<void> completeTask(String taskId) async {
  // 1. Optimistically update UI
  final previous = state;
  state = state.whenData(
    (tasks) => tasks.map((t) =>
      t.id == taskId ? t.copyWith(status: TaskStatus.done) : t
    ).toList(),
  );

  // 2. Persist
  final result = await getIt<CompleteTaskUseCase>()
    .call(CompleteTaskParams(taskId: taskId));

  // 3. Rollback on failure
  result.fold(
    (failure) { state = previous; logger.w(failure.message); },
    (_) => null,
  );
}
```

### Loading skeleton pattern
```dart
// Show skeleton while loading — never show empty + then snap to content
tasksAsync.when(
  loading: () => const _TaskListSkeleton(), // ← skeleton matches real layout
  error:   (e, _) => AppErrorWidget(message: e.toString()),
  data:    (tasks) => _TaskList(tasks: tasks),
)

class _TaskListSkeleton extends StatelessWidget {
  const _TaskListSkeleton();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, __) => const _SkeletonCard(),
    );
  }
}
```

---

## ━━━ SKILL 13 — DRIFT DEEP DIVE ━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### TypeConverter pattern (for enums and complex types)
```dart
// Register TypeConverter for enums instead of storing as raw strings
// Drift handles this automatically when using TextColumn for enums
// But for non-string types:

class DateTimeConverter extends TypeConverter<DateTime, int> {
  const DateTimeConverter();
  @override
  DateTime fromSql(int fromDb) =>
    DateTime.fromMillisecondsSinceEpoch(fromDb);
  @override
  int toSql(DateTime value) => value.millisecondsSinceEpoch;
}

// Usage in table:
IntColumn get createdAtMs => integer().map(const DateTimeConverter())();
```

### Transaction pattern (multiple writes atomically)
```dart
/// Complete task + create recurrence in a single transaction.
/// Either BOTH succeed or NEITHER — no partial state.
Future<void> completeAndRecur(String taskId, Task nextTask) async {
  await db.transaction(() async {
    await taskDao.completeTask(taskId);
    await taskDao.insertTask(nextTask.toCompanion());
  });
}
```

### Batch insert pattern (bulk operations)
```dart
/// Import multiple tasks at once — far faster than individual inserts.
Future<void> importTasks(List<Task> tasks) async {
  await db.batch((batch) {
    batch.insertAll(
      db.tasks,
      tasks.map((t) => t.toCompanion()).toList(),
      mode: InsertMode.insertOrReplace,
    );
  });
}
```

### Migration pattern (schemaVersion bump)
```dart
@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) async => m.createAll(),
  onUpgrade: (m, from, to) async {
    // RULE: use if (from < X) guards — never assume from version
    if (from < 2) {
      // v1 → v2: added isPinned column to tasks
      await m.addColumn(db.tasks, db.tasks.isPinned);
    }
    if (from < 3) {
      // v2 → v3: added recurrence tables
      await m.createTable(db.recurrenceRules);
    }
  },
  beforeOpen: (details) async {
    await customStatement('PRAGMA foreign_keys = ON');
  },
);
// RULE: increment schemaVersion in AppDatabase for EVERY schema change
// RULE: NEVER modify onCreate after app is shipped — only add onUpgrade
```

### Common Drift mistakes
```
❌ Forgetting PRAGMA foreign_keys = ON → cascade deletes silently fail
❌ Calling DAO from a provider directly → bypasses repository layer
❌ Using Future for list queries → misses real-time updates
❌ Forgetting --delete-conflicting-outputs on schema change
❌ Changing schemaVersion without adding onUpgrade handler → crashes on upgrade
```

---

## ━━━ SKILL 14 — SECURE STORAGE PATTERNS ━━━━━━━━━━━━━━━━━━━━

### Key naming convention
```dart
abstract final class StorageKeys {
  // ── Hub-level keys ────────────────────────────────────────
  static const String themeMode         = 'hub.theme_mode';
  static const String biometricEnabled  = 'hub.biometric_enabled';

  // ── Plugin-level keys (prefix = plugin id) ────────────────
  static const String todoDefaultPriority     = 'todo.default_priority';
  static const String todoNotificationOffset  = 'todo.notification_offset';
  static const String todoShowCompleted       = 'todo.show_completed';

  // RULE: always prefix with feature name — prevents key collision
  // RULE: use dot notation: {feature}.{key_name}
  // RULE: all keys defined here — never inline strings
}
```

### Safe read pattern (never assume key exists)
```dart
/// Read with default fallback — key may not exist on first launch.
Future<ThemeMode> readThemeMode() async {
  try {
    final value = await _storage.read(key: StorageKeys.themeMode);
    if (value == null) return ThemeMode.system; // ← default
    return ThemeMode.values.byName(value);
  } catch (e, st) {
    logger.error('SecureStorage: readThemeMode failed', error: e, stackTrace: st);
    return ThemeMode.system;
  }
}
```

### Migration pattern (key rename between versions)
```dart
/// Migrate old key format to new key format on app upgrade.
Future<void> migrateStorageV1toV2() async {
  final old = await _storage.read(key: 'themeMode'); // old key (no prefix)
  if (old != null) {
    await _storage.write(key: StorageKeys.themeMode, value: old);
    await _storage.delete(key: 'themeMode');
    logger.info('StorageMigration: themeMode key migrated');
  }
}
```

---

## ━━━ SKILL 15 — ANDROID MANIFEST & BUILD CONFIG ━━━━━━━━━━━━━

### AndroidManifest.xml — DML Hub required permissions
```xml
<!-- Required for MVP — add only what's needed -->
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />

<!-- RULE: NO internet permission — local-only app -->
<!-- RULE: Add permissions only when the feature that needs them is built -->
```

### build.gradle — critical settings
```groovy
android {
    namespace "com.dmllabs.hub"
    compileSdk 34

    defaultConfig {
        applicationId "com.dmllabs.hub"
        minSdk 21           // Android 5.0 — covers 99%+ of Android devices
        targetSdk 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        multiDexEnabled true  // required for large apps
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    buildTypes {
        release {
            minifyEnabled true        // enables R8 shrinking
            shrinkResources true      // removes unused resources
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'),
                          'proguard-rules.pro'
        }
        debug {
            minifyEnabled false
            applicationIdSuffix ".debug"  // co-install debug + release
        }
    }
}
```

### proguard-rules.pro — common Flutter rules
```proguard
# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Drift
-keep class com.dmllabs.hub.** { *; }

# local_auth
-keep class androidx.biometric.** { *; }

# flutter_local_notifications
-keep class com.dexterous.** { *; }

# Dart/Flutter reflection
-keepattributes *Annotation*
-keepattributes Signature
```

### Runtime permission flow (Android 13+ notifications)
```dart
/// Request notification permission — call ONCE on first launch.
Future<void> requestNotificationPermission() async {
  final granted = await getIt<NotificationService>().requestPermission();
  if (!granted) {
    logger.warning('Notification permission denied by user');
    // RULE: never re-request immediately — respect user choice
    // RULE: show rationale only if user explicitly triggers a notification feature
  }
}
```

---

## ━━━ SKILL 16 — UNIT TESTING PATTERNS ━━━━━━━━━━━━━━━━━━━━━━

### File naming and location
```
lib/features/todo/domain/usecases/task/create_task_usecase.dart
test/features/todo/domain/usecases/task/create_task_usecase_test.dart
# RULE: test file = source file path + _test.dart suffix
# RULE: test/ mirrors lib/ exactly
```

### Mocktail setup pattern (preferred over mockito — no codegen needed)
```dart
// Fake repository — preferred for repositories (full control)
class FakeTaskRepository extends Fake implements TaskRepository {
  final List<Task> _tasks = [];

  @override
  Future<Either<Failure, Task>> createTask(Task task) async {
    _tasks.add(task);
    return Right(task);
  }

  @override
  Stream<Either<Failure, List<Task>>> watchTodayTasks() =>
    Stream.value(Right(_tasks));
}

// Mock — use for services where you only care about call verification
class MockNotificationService extends Mock implements NotificationService {}
```

### Arrange-Act-Assert pattern
```dart
group('CreateTaskUseCase', () {
  late CreateTaskUseCase useCase;
  late FakeTaskRepository fakeRepository;
  late MockNotificationService mockNotifications;

  setUp(() {
    fakeRepository    = FakeTaskRepository();
    mockNotifications = MockNotificationService();
    useCase = CreateTaskUseCase(fakeRepository, mockNotifications);
    // RULE: registerFallbackValue for any custom type used with any()
    registerFallbackValue(FakeTask());
  });

  test('returns ValidationFailure when title is empty', () async {
    // Arrange
    final params = CreateTaskParams(title: '', priority: TaskPriority.none);

    // Act
    final result = await useCase(params);

    // Assert
    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('Expected failure'),
    );
  });

  test('returns Right(Task) on valid input', () async {
    // Arrange
    final params = CreateTaskParams(
      title: 'Buy groceries',
      priority: TaskPriority.medium,
    );

    // Act
    final result = await useCase(params);

    // Assert
    expect(result.isRight(), true);
    result.fold(
      (_) => fail('Expected success'),
      (task) {
        expect(task.title, 'Buy groceries');
        expect(task.priority, TaskPriority.medium);
        expect(task.id.isNotEmpty, true);
      },
    );
  });
});
```

---

## ━━━ SKILL 17 — WIDGET TESTING PATTERNS ━━━━━━━━━━━━━━━━━━━━

### Widget test boilerplate with ProviderScope
```dart
void main() {
  testWidgets('TaskCard shows title and priority badge', (tester) async {
    // Arrange
    final task = Task(
      id: 'test-id', title: 'Test task',
      priority: TaskPriority.high, status: TaskStatus.todo,
      isRecurring: false, createdAt: DateTime.now(),
      updatedAt: DateTime.now(), isPinned: false,
    );

    // Act
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(body: TaskCard(task: task, index: 0)),
        ),
      ),
    );

    // Assert
    expect(find.text('Test task'), findsOneWidget);
    expect(find.byType(PriorityBadge), findsOneWidget);
  });
}
```

### Override provider in widget test
```dart
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      todayTasksProvider.overrideWith(
        (ref) => Stream.value(Right([fakeTask])),
      ),
    ],
    child: const MaterialApp(home: TodoTodayPage()),
  ),
);
```

### Common widget test finders
```dart
find.text('Label')                       // by text
find.byType(TaskCard)                    // by widget type
find.byKey(const Key('task-card-0'))     // by key (add keys for testability)
find.byIcon(Icons.check_rounded)         // by icon
find.descendant(of: find.byType(Card),  // nested finder
  matching: find.byType(Text))
```

---

## ━━━ SKILL 18 — ANDROID BUILD GUIDE ━━━━━━━━━━━━━━━━━━━━━━━━

### Build types explained
```
debug   → development + testing · NOT optimized · debugger attachable
profile → performance profiling · partial optimization · DevTools connectable
release → production · fully optimized · obfuscated · signed
```

### Debug APK — local testing
```bash
# Build debug APK (fast, no signing needed)
flutter build apk --debug --flavor dev -t lib/main_dev.dart

# Output: build/app/outputs/flutter-apk/app-dev-debug.apk
# Install on connected device:
adb install build/app/outputs/flutter-apk/app-dev-debug.apk
```

### Release APK — signed, optimized
```bash
# Build release APK (single fat APK — all ABIs)
flutter build apk --release --flavor prod -t lib/main_prod.dart

# Build split APKs by ABI (RECOMMENDED — smaller per-device size)
flutter build apk --release --split-per-abi \
  --flavor prod -t lib/main_prod.dart \
  --obfuscate --split-debug-info=build/debug-info/

# Output: build/app/outputs/flutter-apk/
#   app-arm64-v8a-prod-release.apk   (~7 MB — modern devices)
#   app-armeabi-v7a-prod-release.apk (~6 MB — older 32-bit)
#   app-x86_64-prod-release.apk      (~7 MB — emulators/x86)

# RULE: Use split-per-abi for direct distribution
# RULE: Use fat APK only for testing on unknown device type
```

### AAB — Play Store upload
```bash
# Build Android App Bundle (required for Play Store)
flutter build appbundle --release \
  --flavor prod -t lib/main_prod.dart \
  --obfuscate --split-debug-info=build/debug-info/

# Output: build/app/outputs/bundle/prodRelease/app-prod-release.aab
# RULE: AAB is NOT directly installable — Play Store handles splitting
# RULE: Always upload the .aab to Play Store, never the .apk
```

### Obfuscation flags explained
```bash
--obfuscate                          # renames Dart classes/methods (harder to reverse)
--split-debug-info=build/debug-info/ # saves symbols for crash deobfuscation
# RULE: ALWAYS use both together — obfuscate without split-debug-info
#        makes crash reports unreadable
# RULE: NEVER commit build/debug-info/ to git
# RULE: archive debug-info alongside each release build
```

### Build size optimization flags
```bash
flutter build apk --release \
  --split-per-abi \          # -60% size vs fat APK
  --obfuscate \              # -5% additional
  --split-debug-info=... \   # required with --obfuscate
  --no-tree-shake-icons      # remove if NOT using all Material icons
                             # (tree-shake-icons = default ON in release)
```

### Phase 12+ stubs — other platforms
```
iOS (.ipa)      → Phase 12+ · Requires: macOS + Xcode 15+ + Apple Developer account
                  Command: flutter build ipa --release
                  Note: impossible in Linux container

macOS (.dmg)    → Phase 12+ · Requires: macOS build machine
                  Command: flutter build macos --release

Windows (.exe)  → Phase 12+ · Requires: Windows build machine
                  Command: flutter build windows --release

Linux (.deb)    → Phase 12+ · Requires: Linux desktop dependencies
                  Command: flutter build linux --release

Web (bundle)    → Phase 12+ · Requires: web platform enabled
                  Command: flutter build web --release
```

---

## ━━━ SKILL 19 — CODE SIGNING ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### Keystore generation (once — store securely)
```bash
keytool -genkeypair \
  -v \
  -keystore android/keystore/release.keystore \
  -alias dml_hub_key \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass YOUR_STORE_PASSWORD \
  -keypass YOUR_KEY_PASSWORD \
  -dname "CN=DML Labs, OU=DML Hub, O=DML Labs, L=Unknown, S=Unknown, C=IN"

# CRITICAL: back up release.keystore — if lost, you CANNOT update your Play Store app
# CRITICAL: never commit release.keystore to git (in .gitignore already)
```

### key.properties (NEVER commit to git)
```properties
# android/key.properties — add to .gitignore
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=dml_hub_key
storeFile=keystore/release.keystore
```

### build.gradle signing config
```groovy
// At top of android/app/build.gradle:
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias     keystoreProperties['keyAlias']
            keyPassword  keystoreProperties['keyPassword']
            storeFile    keystoreProperties['storeFile']
              ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

---

## ━━━ SKILL 20 — BUILD OPTIMIZATION ━━━━━━━━━━━━━━━━━━━━━━━━━

### Asset compression rules
```yaml
# pubspec.yaml — compress images before adding to assets/
# PNG: use pngcrush or squoosh
# JPG: quality 80% max for photos
# Use WebP for all app images > 10KB
# Use SVG for icons (via flutter_svg) — infinitely scalable, tiny size
```

### Flutter size analysis
```bash
# Analyze APK contents — shows what's taking space
flutter build apk --analyze-size --target-platform android-arm64

# Output: build/app-arm64-v8a-release.apk-code-size-analysis_*.json
# Open: https://flutter.github.io/devtools/app_size.html
```

### Tree shaking rules
```dart
// Icons: only import what you use
// ❌ Imports entire icons set
import 'package:flutter/material.dart'; // includes all Material icons

// ✅ For custom icon usage: use IconData directly
const Icon(IconData(0xe3af, fontFamily: 'MaterialIcons'))
// Or: let --tree-shake-icons remove unused icons automatically (default in release)
```

---

## ━━━ SKILL 21 — PERFORMANCE PROFILING ━━━━━━━━━━━━━━━━━━━━━━

### Profile mode commands
```bash
# Run in profile mode (connects to DevTools)
flutter run --profile

# Open DevTools
dart devtools
# Then connect to the profile URL shown in terminal
```

### What to look for in DevTools
```
Performance tab:
  → Frame chart: each bar = one frame
  → RED bars > 16ms = jank (drops below 60fps)
  → UI thread (top) vs Raster thread (bottom)
  → If UI thread spikes: expensive build() calls
  → If Raster thread spikes: complex painting / shaders

Widget Inspector:
  → Enable "Highlight repaints" → red flash = widget repainting
  → Red flashing on scroll = missing const or missing RepaintBoundary
  → Enable "Show layout bounds" → diagnose overflow

Memory tab:
  → Watch for growing heap → possible stream subscription leak
  → Common leak: StreamSubscription not cancelled in dispose()
```

### Common jank fixes
```dart
// FIX 1: Move heavy computation off UI thread
final result = await compute(heavyFunction, input);
// compute() runs in a separate Isolate

// FIX 2: Cache expensive Image.network with cacheWidth
Image.network(url, cacheWidth: 200) // decode at display size, not full res

// FIX 3: Use ListView.builder NOT ListView(children:[]) for long lists
// ListView.builder is lazy — only builds visible items
// ListView(children:[]) builds ALL items immediately

// FIX 4: Add RepaintBoundary around expensive animated widgets
RepaintBoundary(child: AnimatedProgressRing(...))

// FIX 5: Avoid Opacity widget for animation — use FadeTransition
FadeTransition(opacity: _animation, child: widget) // GPU composited
// Opacity(opacity: 0.5, child: widget) // triggers repaint on every frame
```

---

## ━━━ SKILL 22 — JANK & 16ms FRAME BUDGET ━━━━━━━━━━━━━━━━━━

### Frame budget breakdown
```
Total budget per frame:  16.67ms (60fps) / 8.33ms (120fps)

Typical allocation:
  Widget build():    ~4ms max
  Layout:            ~3ms max
  Paint:             ~4ms max
  Rasterize:         ~4ms max
  → Any single phase exceeding budget = dropped frame
```

### Isolate pattern for heavy work
```dart
// Anything taking > 4ms on UI thread → move to Isolate

// Simple: use compute() for single function
final sortedTasks = await compute(_sortTasks, tasks);

// Complex: use Isolate.spawn for ongoing background work
static List<Task> _sortTasks(List<Task> tasks) {
  // RULE: this function runs in a separate Isolate
  // RULE: no Flutter APIs, no get_it, no providers inside Isolate
  return tasks..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
}
```

### const widget checklist
```dart
// These MUST be const — lint catches most, but double-check:
const SizedBox(height: 16)          // ✅
const EdgeInsets.all(16)            // ✅
const Text('Static label')          // ✅
const Icon(Icons.check)             // ✅
const BorderRadius.circular(12)     // ✅
const Duration(milliseconds: 300)   // ✅
const Color(0xFF4A90D9)             // ✅
```

---

## ━━━ SKILL 23 — GITHUB ACTIONS CI (ADVANCED) ━━━━━━━━━━━━━━━

### Full CI with caching (saves 3+ min per run)
```yaml
# .github/workflows/ci.yml
name: DML Hub CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.2'
          channel: stable
          cache: true                      # ← caches Flutter SDK

      - name: Pub cache
        uses: actions/cache@v4
        with:
          path: ~/.pub-cache
          key: pub-${{ hashFiles('**/pubspec.lock') }}
          restore-keys: pub-               # ← caches pub packages

      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: flutter analyze
      - run: flutter test

      # Build release APK on main branch only
      - name: Build release APK
        if: github.ref == 'refs/heads/main'
        run: |
          flutter build apk --release --split-per-abi \
            --obfuscate --split-debug-info=build/debug-info/

      # Upload APK as artifact (downloadable from Actions UI)
      - name: Upload APK
        if: github.ref == 'refs/heads/main'
        uses: actions/upload-artifact@v4
        with:
          name: dml-hub-release-apk
          path: build/app/outputs/flutter-apk/*-release.apk
          retention-days: 30

      - name: Telegram — success
        if: success()
        run: |
          curl -s -X POST \
            "https://api.telegram.org/bot${{ secrets.TELEGRAM_TOKEN }}/sendMessage" \
            -H "Content-Type: application/json" \
            -d '{"chat_id":"${{ secrets.TELEGRAM_CHAT_ID }}","text":"✅ CI passed: ${{ github.ref_name }}"}'

      - name: Telegram — failure
        if: failure()
        run: |
          curl -s -X POST \
            "https://api.telegram.org/bot${{ secrets.TELEGRAM_TOKEN }}/sendMessage" \
            -H "Content-Type: application/json" \
            -d '{"chat_id":"${{ secrets.TELEGRAM_CHAT_ID }}","text":"❌ CI failed: ${{ github.ref_name }}\n${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}"}'
```

---

## ━━━ SKILL 24 — LOCAL DEV SCRIPTS ━━━━━━━━━━━━━━━━━━━━━━━━━━

### Makefile (place at project root)
```makefile
# DML Hub — Dev shortcuts
# Usage: make <target>

.PHONY: get clean codegen analyze test build-debug build-release install

# Install dependencies
get:
	flutter pub get

# Full clean + reinstall
clean:
	flutter clean && flutter pub get

# Run code generation
codegen:
	dart run build_runner build --delete-conflicting-outputs

# Watch mode code generation (keep running during dev)
codegen-watch:
	dart run build_runner watch --delete-conflicting-outputs

# Analyze + format check
analyze:
	flutter analyze && dart format --set-exit-if-changed .

# Run all tests
test:
	flutter test --coverage

# Format all code
format:
	dart format .

# Fix auto-fixable lint issues
fix:
	dart fix --apply

# Build debug APK
build-debug:
	flutter build apk --debug -t lib/main_dev.dart
	@echo "APK: build/app/outputs/flutter-apk/app-debug.apk"

# Build release APKs (split by ABI)
build-release:
	flutter build apk --release --split-per-abi \
		--obfuscate --split-debug-info=build/debug-info/ \
		-t lib/main_prod.dart
	@echo "APKs: build/app/outputs/flutter-apk/"

# Install debug APK on connected device
install:
	adb install -r build/app/outputs/flutter-apk/app-debug.apk

# Full dev pipeline: clean → get → codegen → analyze → test
ready:
	make clean && make codegen && make analyze && make test
	@echo "✅ Project ready"
```

### Flutter CLI quick reference
```bash
# Project
flutter create --org com.dmllabs --platforms=android .
flutter pub get
flutter pub outdated          # shows upgradable packages
flutter pub upgrade           # upgrades within constraints
flutter pub upgrade --major-versions  # upgrades across major (careful)

# Code quality
flutter analyze               # lint
dart format .                 # format
dart format --set-exit-if-changed .  # format check (CI)
dart fix --apply              # auto-fix lint issues

# Running
flutter run -d <device-id>
flutter run --flavor dev -t lib/main_dev.dart
flutter run --profile         # profile mode
flutter run --release         # release mode on device

# Devices
flutter devices               # list connected devices
flutter emulators             # list emulators
flutter emulators --launch <id>

# Building
flutter build apk --debug
flutter build apk --release --split-per-abi
flutter build appbundle --release
flutter build apk --analyze-size --target-platform android-arm64

# Testing
flutter test
flutter test --coverage
flutter test test/features/todo/  # specific folder
flutter test --name "CreateTask"  # specific test by name

# Other
flutter clean
flutter doctor -v
flutter --version
dart --version
```

---

## ━━━ SKILL 25 — COMMON ERROR ENCYCLOPEDIA ━━━━━━━━━━━━━━━━━━

```
ERROR: "Could not find a generator for import..."
CAUSE: Missing @riverpod / @freezed / @DriftDatabase annotation
FIX:   Add annotation → dart run build_runner build --delete-conflicting-outputs

ERROR: "MissingPluginException(No implementation found for method...)"
CAUSE: Native plugin not initialized / flutter clean needed
FIX:   flutter clean && flutter pub get → restart (not hot reload)

ERROR: "Gradle build failed: Minimum supported Gradle version is X"
CAUSE: Java version mismatch
FIX:   Verify JAVA_HOME points to JDK 17 (not 21 JRE) → ./gradlew wrapper --gradle-version X

ERROR: "setState() called after dispose()"
CAUSE: async operation completes after widget unmounted
FIX:   if (!mounted) return; — check before every setState() / ref.read() in async

ERROR: "type 'Null' is not a subtype of type 'X'"
CAUSE: Nullable field accessed without null check on async data
FIX:   Use ?. null-safe access or guard with if (value == null) return

ERROR: "ProviderScope not found in widget tree"
CAUSE: MaterialApp not wrapped in ProviderScope
FIX:   runApp(ProviderScope(child: DmlHubApp()))

ERROR: Drift "Expected schemaVersion X but found Y"
CAUSE: schemaVersion incremented without onUpgrade handler
FIX:   Add migration step in onUpgrade for the version jump

ERROR: "A value of type 'Either<Failure, X>' can't be assigned to 'X'"
CAUSE: Either not folded/unwrapped before use
FIX:   result.fold((failure) => ..., (value) => ...)

ERROR: flutter_local_notifications crash on Android 12+
CAUSE: SCHEDULE_EXACT_ALARM permission not declared or not granted
FIX:   Add permission to manifest + check permission before scheduling

ERROR: "Bad state: Stream has already been listened to"
CAUSE: Non-broadcast stream subscribed twice
FIX:   Use .asBroadcastStream() or restructure to single subscriber

ERROR: build_runner "Conflicts detected in..."
CAUSE: Stale generated files conflict with new generation
FIX:   dart run build_runner build --delete-conflicting-outputs

ERROR: "RenderFlex overflowed by X pixels"
CAUSE: Column/Row child too large for available space
FIX:   Wrap child in Flexible/Expanded, or use SingleChildScrollView
```

---

## ━━━ SKILL 26 — PACKAGE UPGRADE STRATEGY ━━━━━━━━━━━━━━━━━━━

### Safe upgrade workflow
```bash
# Step 1: Check what's outdated
flutter pub outdated

# Step 2: Read changelog for each outdated package BEFORE upgrading
# Check: pub.dev/{package}/changelog

# Step 3: Upgrade within constraints (safe)
flutter pub upgrade

# Step 4: Run codegen (package updates often change generated code)
dart run build_runner build --delete-conflicting-outputs

# Step 5: Analyze + test
flutter analyze && flutter test

# Step 6: If all green → commit
git add pubspec.lock && git commit -m "chore: upgrade dependencies"
```

### Breaking change detection
```bash
# Upgrade across major versions (potentially breaking)
flutter pub upgrade --major-versions

# RULE: Never upgrade multiple major-version packages at once
# RULE: One package at a time for major upgrades
# RULE: Read migration guide for every major version bump
# RULE: After major upgrade: full clean → codegen → analyze → test
```

### Version pinning rules
```yaml
# Pin exact when: package has history of breaking patch releases
drift: 2.18.0          # exact pin — DB migrations are critical

# Range when: stable, well-maintained package
flutter_riverpod: ^2.5.1

# NEVER: any / empty constraint
some_package: any      # ❌
```

---

## ━━━ SKILL 27 — GIT WORKFLOW (SOLO DEV) ━━━━━━━━━━━━━━━━━━━━

### Branch strategy
```
main       → stable, tagged releases only · CI must pass · never force-push
develop    → active development · daily commits · CI runs here
feature/*  → one branch per feature (feature/todo-recurrence)
fix/*      → bug fixes (fix/task-completion-animation)
chore/*    → non-functional (chore/upgrade-dependencies)
```

### Commit message convention (Conventional Commits)
```
format: <type>(<scope>): <description>

Types:
  feat     → new feature         feat(todo): add task recurrence
  fix      → bug fix             fix(todo): completion animation not firing
  chore    → maintenance         chore: upgrade flutter to 3.22.2
  refactor → restructure         refactor(core): split DI into feature modules
  test     → tests only          test(todo): add create task use case tests
  docs     → documentation       docs: update SKILLS.md structure snapshot
  perf     → performance         perf(today): replace ListView with SliverList
  style    → formatting          style: run dart format

Examples:
  feat(hub): add biometric lock with face id fallback
  fix(todo): task due date not persisting on update
  chore(deps): upgrade drift to 2.18.0
  refactor(todo): extract subtask logic into separate use case
```

### Tag strategy for releases
```bash
# Tag format: v{version}+{build}
# Must match pubspec.yaml version exactly

git tag -a v1.0.0+1 -m "Release: DML Hub v1.0.0 — MVP To-Do plugin"
git push origin v1.0.0+1

# View all release tags:
git tag -l "v*" --sort=-version:refname
```

### Daily workflow
```bash
# Start work
git checkout develop
git pull origin develop
git checkout -b feature/todo-subtask-reorder

# During work: commit frequently (every logical unit)
git add -A
git commit -m "feat(todo): add subtask drag-to-reorder UI"

# Done: merge back to develop
git checkout develop
git merge --no-ff feature/todo-subtask-reorder
git push origin develop
git branch -d feature/todo-subtask-reorder

# Release: develop → main
git checkout main
git merge --no-ff develop
git tag -a v1.1.0+5 -m "Release: Subtask reorder"
git push origin main --tags
```

---

# END OF flutter-SKILLS.md
# ─────────────────────────────────────────────────────────────
# Attach with: SYSTEM_PROMPT.md
# When to attach:
#   Structure questions    → SKILL 1
#   Build & release        → SKILL 18, 19, 20
#   Architecture questions → SKILL 4, 5, 6
#   Testing                → SKILL 16, 17
#   Performance issues     → SKILL 21, 22
#   CI/CD                  → SKILL 23, 24
#   Errors/debugging       → SKILL 25
#   Package management     → SKILL 26
#   Git workflow           → SKILL 27
# ─────────────────────────────────────────────────────────────
