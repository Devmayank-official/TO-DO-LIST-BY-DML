# core-SKILLS.md
# DML Hub — Core Kernel Skills & Patterns
# Company: DML Labs | Package: com.dmllabs.hub
# Attach: When working on ANY shared/core layer, DI, routing, theming, error handling, logging
# Always attach ALONGSIDE: SYSTEM_PROMPT.md

---

## 📁 CORE FOLDER STRUCTURE

```
lib/
└── core/
    ├── constants/
    │   ├── app_constants.dart        # App-wide magic-free constants
    │   ├── app_routes.dart           # ALL route path constants (no inline strings)
    │   └── app_spacing.dart          # Spacing scale (4dp grid)
    │
    ├── di/
    │   ├── injection_container.dart  # get_it setup — ALL registrations here
    │   └── injection_container.config.dart  # (generated if using injectable)
    │
    ├── error/
    │   ├── failures.dart             # All typed Failure classes (sealed)
    │   └── exceptions.dart           # All typed Exception classes
    │
    ├── extensions/
    │   ├── context_extensions.dart   # BuildContext helpers
    │   ├── string_extensions.dart    # String utilities
    │   └── datetime_extensions.dart  # DateTime helpers
    │
    ├── router/
    │   ├── app_router.dart           # GoRouter instance + all routes
    │   └── app_router.g.dart         # (generated)
    │
    ├── theme/
    │   ├── app_theme.dart            # ThemeData (light + dark)
    │   ├── app_colors.dart           # Color token constants
    │   ├── app_text_styles.dart      # TextStyle token constants
    │   └── app_decorations.dart      # BoxDecoration presets
    │
    ├── usecases/
    │   └── usecase.dart              # Abstract UseCase<Type, Params> base
    │
    ├── utils/
    │   └── logger.dart               # talker instance (singleton)
    │
    └── widgets/
        ├── app_error_widget.dart     # Generic error display widget
        ├── app_loading_widget.dart   # Generic loading widget
        └── app_empty_widget.dart     # Generic empty state widget
```

---

## 🔴 SKILL 1 — ERROR HANDLING (Either Pattern)

### Rule
Every repository method and use case MUST return `Either<Failure, R>`.
Failures are typed, sealed, and defined ONCE in `core/error/failures.dart`.
NEVER throw exceptions across layer boundaries. ALWAYS catch and convert to Failure.

### Pattern: failures.dart
```dart
/// All typed failures for DML Hub.
/// Add new failure types here — never create failures outside this file.
sealed class Failure {
  final String message;
  const Failure(this.message);
}

/// Local database operation failed.
final class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Input validation failed.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Biometric/security authentication failed.
final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Notification scheduling/cancellation failed.
final class NotificationFailure extends Failure {
  const NotificationFailure(super.message);
}

/// Unexpected/unknown failure — last resort only.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
```

### Pattern: Repository method returning Either
```dart
/// CORRECT — repository implementation pattern
@override
Future<Either<Failure, Task>> createTask(Task task) async {
  try {
    final taskDto = TaskDto.fromEntity(task);
    final id = await _taskDao.insertTask(taskDto);
    return Right(task.copyWith(id: id));
  } on DriftWrappedException catch (e, stackTrace) {
    logger.e('TaskRepository: createTask failed', error: e, stackTrace: stackTrace);
    return Left(DatabaseFailure('Failed to create task: ${e.message}'));
  } catch (e, stackTrace) {
    logger.e('TaskRepository: createTask unexpected error', error: e, stackTrace: stackTrace);
    return Left(UnexpectedFailure('Unexpected error creating task'));
  }
}
```

### Pattern: Consuming Either in Riverpod provider
```dart
/// CORRECT — provider consuming use case Either result
@riverpod
Future<void> createTask(CreateTaskRef ref, Task task) async {
  final result = await ref.read(createTaskUseCaseProvider).call(task);
  result.fold(
    (failure) {
      logger.w('CreateTask failed: ${failure.message}');
      // Update error state — never throw
      ref.read(taskErrorProvider.notifier).state = failure.message;
    },
    (createdTask) {
      logger.i('Task created: ${createdTask.id}');
      ref.invalidate(taskListProvider);
    },
  );
}
```

---

## 💉 SKILL 2 — DEPENDENCY INJECTION (get_it)

### Rule
ALL dependencies are registered in `injection_container.dart`.
NEVER instantiate repositories, use cases, or services directly in providers.
Providers READ from get_it via extension or direct `getIt<T>()` call.
Registration order: external → data sources → repositories → use cases → services.

### Pattern: injection_container.dart
```dart
/// DML Hub dependency injection container.
/// Registration order MUST be: DAOs → Repositories → UseCases → Services
final GetIt getIt = GetIt.instance;

/// Call once in main.dart before runApp()
Future<void> initializeDependencies() async {
  // ─── Database ────────────────────────────────────────────
  final database = AppDatabase();
  getIt.registerSingleton<AppDatabase>(database);

  // ─── DAOs ─────────────────────────────────────────────────
  getIt.registerSingleton<TaskDao>(TaskDao(getIt<AppDatabase>()));
  getIt.registerSingleton<ProjectDao>(ProjectDao(getIt<AppDatabase>()));
  getIt.registerSingleton<TagDao>(TagDao(getIt<AppDatabase>()));

  // ─── Repositories ─────────────────────────────────────────
  getIt.registerSingleton<TaskRepository>(
    TaskRepositoryImpl(taskDao: getIt<TaskDao>()),
  );
  getIt.registerSingleton<ProjectRepository>(
    ProjectRepositoryImpl(projectDao: getIt<ProjectDao>()),
  );

  // ─── Use Cases ────────────────────────────────────────────
  getIt.registerFactory<CreateTaskUseCase>(
    () => CreateTaskUseCase(getIt<TaskRepository>()),
  );
  getIt.registerFactory<CompleteTaskUseCase>(
    () => CompleteTaskUseCase(getIt<TaskRepository>()),
  );

  // ─── Services ─────────────────────────────────────────────
  getIt.registerSingleton<NotificationService>(
    NotificationServiceImpl(),
  );
  getIt.registerSingleton<BiometricService>(
    BiometricServiceImpl(),
  );
}
```

### Pattern: Accessing get_it inside Riverpod provider
```dart
/// Provider reading a use case from get_it
@riverpod
CreateTaskUseCase createTaskUseCase(CreateTaskUseCaseRef ref) {
  return getIt<CreateTaskUseCase>();
}

/// Repository provider — always via get_it, never direct instantiation
@riverpod
TaskRepository taskRepository(TaskRepositoryRef ref) {
  return getIt<TaskRepository>();
}
```

---

## 🔁 SKILL 3 — USE CASE BASE CLASS

### Rule
Every use case MUST extend `UseCase<Type, Params>` or `UseCaseNoParams<Type>`.
One use case = one action. Never combine actions.
Use case ONLY calls its repository — never calls other use cases or DAOs.

### Pattern: usecase.dart
```dart
/// Base class for use cases with parameters.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Base class for use cases with no parameters.
abstract class UseCaseNoParams<Type> {
  Future<Either<Failure, Type>> call();
}

/// Marker class for use cases that take no params.
class NoParams {
  const NoParams();
}
```

### Pattern: Concrete use case
```dart
/// Creates a new task in the repository.
/// Validates input before persisting.
class CreateTaskUseCase extends UseCase<Task, CreateTaskParams> {
  const CreateTaskUseCase(this._repository);
  final TaskRepository _repository;

  @override
  Future<Either<Failure, Task>> call(CreateTaskParams params) async {
    // Domain validation — ALWAYS validate in use case, not in repository
    if (params.title.trim().isEmpty) {
      return const Left(ValidationFailure('Task title cannot be empty'));
    }
    if (params.title.length > 500) {
      return const Left(ValidationFailure('Task title exceeds 500 characters'));
    }
    final task = Task(
      id: const Uuid().v4(),
      title: params.title.trim(),
      priority: params.priority,
      dueDate: params.dueDate,
      projectId: params.projectId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return _repository.createTask(task);
  }
}

/// Parameters for CreateTaskUseCase.
@freezed
class CreateTaskParams with _$CreateTaskParams {
  const factory CreateTaskParams({
    required String title,
    required TaskPriority priority,
    DateTime? dueDate,
    String? projectId,
    List<String>? tagIds,
  }) = _CreateTaskParams;
}
```

---

## 🗺️ SKILL 4 — ROUTING (go_router)

### Rule
ALL route paths are constants in `AppRoutes`. NEVER inline route strings.
Hub shell uses `StatefulShellRoute` for state preservation per branch.
Plugin routes are ALWAYS nested under /hub/{plugin-name}/.
Back navigation ALWAYS pops to /hub — never to an arbitrary route.

### Pattern: app_routes.dart
```dart
/// All route path constants for DML Hub.
/// NEVER use inline strings for navigation — ALWAYS use these constants.
abstract final class AppRoutes {
  // ─── Hub Shell ────────────────────────────────────────────
  static const String hub = '/hub';
  static const String hubSettings = '/hub/settings';

  // ─── To-Do Plugin ─────────────────────────────────────────
  static const String todoRoot    = '/hub/todo';
  static const String todoToday   = '/hub/todo/today';
  static const String todoTasks   = '/hub/todo/tasks';
  static const String todoProjects = '/hub/todo/projects';
  static const String todoSettings = '/hub/todo/settings';

  // ─── Future Plugin Slots (reserve now, implement later) ───
  // static const String habitsRoot  = '/hub/habits';
  // static const String journalRoot = '/hub/journal';
  // static const String notesRoot   = '/hub/notes';
  // static const String goalsRoot   = '/hub/goals';
}
```

### Pattern: app_router.dart
```dart
/// DML Hub application router.
/// Hub shell → StatefulShellRoute (preserves plugin scroll/state)
/// Plugin routes → nested under /hub/{plugin}
final appRouter = GoRouter(
  initialLocation: AppRoutes.hub,
  debugLogDiagnostics: true,
  routes: [
    // ─── Hub Shell ──────────────────────────────────────────
    GoRoute(
      path: AppRoutes.hub,
      builder: (context, state) => const HubHomePage(),
      routes: [
        GoRoute(
          path: 'settings',
          builder: (context, state) => const HubSettingsPage(),
        ),

        // ─── To-Do Plugin ───────────────────────────────────
        ShellRoute(
          builder: (context, state, child) => TodoShell(child: child),
          routes: [
            GoRoute(
              path: 'todo',
              redirect: (_, __) => AppRoutes.todoToday,
            ),
            GoRoute(
              path: 'todo/today',
              builder: (context, state) => const TodoTodayPage(),
            ),
            GoRoute(
              path: 'todo/tasks',
              builder: (context, state) => const TodoAllTasksPage(),
            ),
            GoRoute(
              path: 'todo/projects',
              builder: (context, state) => const TodoProjectsPage(),
            ),
            GoRoute(
              path: 'todo/settings',
              builder: (context, state) => const TodoSettingsPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
```

### Pattern: Navigating from Hub → Plugin (full-screen push)
```dart
/// Hub Home card tapped — push plugin full-screen
/// CORRECT navigation pattern
InkWell(
  onTap: () => context.push(AppRoutes.todoToday),
  child: PluginCard(plugin: todoPlugin),
)

/// NEVER use Navigator.push() — go_router ONLY
/// NEVER use context.go() for plugin launch (loses back stack)
/// ALWAYS use context.push() to preserve Hub in back stack
```

---

## 🎨 SKILL 5 — THEME SYSTEM

### Pattern: app_colors.dart
```dart
/// DML Labs brand color tokens.
/// NEVER hardcode colors in widgets — ALWAYS reference these tokens
/// or use Theme.of(context).colorScheme.{role}
abstract final class AppColors {
  // ─── Brand ────────────────────────────────────────────────
  static const Color dmlBlue         = Color(0xFF4A90D9);
  static const Color dmlBlueDark     = Color(0xFF2D6BAD);
  static const Color dmlBlueDeep     = Color(0xFF1A3A5C);

  // ─── Surface (Dark Theme) ─────────────────────────────────
  static const Color surfaceDeepNavy = Color(0xFF0A1628);
  static const Color surfaceDark     = Color(0xFF0D1B2A);
  static const Color surfaceCard     = Color(0xFF1A2840);
  static const Color surfaceElevated = Color(0xFF1E3050);

  // ─── Content ──────────────────────────────────────────────
  static const Color contentPrimary  = Color(0xFFE8F0FE);
  static const Color contentSecondary= Color(0xFFB0C4DE);
  static const Color contentDisabled = Color(0xFF5A7A9A);

  // ─── Semantic ─────────────────────────────────────────────
  static const Color priorityHigh    = Color(0xFFCF6679);
  static const Color priorityMedium  = Color(0xFFE8A838);
  static const Color priorityLow     = Color(0xFF4A90D9);
  static const Color priorityNone    = Color(0xFF5A7A9A);
  static const Color success         = Color(0xFF4CAF82);
  static const Color error           = Color(0xFFCF6679);
}
```

### Pattern: app_theme.dart
```dart
/// DML Hub Material 3 theme — dark-first.
abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.dmlBlue,
      onPrimary: Colors.white,
      primaryContainer: AppColors.dmlBlueDeep,
      onPrimaryContainer: Color(0xFFB8D4F0),
      surface: AppColors.surfaceDark,
      onSurface: AppColors.contentPrimary,
      surfaceContainerHighest: AppColors.surfaceCard,
      error: AppColors.error,
    ),
    fontFamily: GoogleFonts.nunitoSans().fontFamily,
    cardTheme: CardTheme(
      color: AppColors.surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      indicatorColor: AppColors.dmlBlueDeep,
      labelTextStyle: WidgetStateProperty.all(
        GoogleFonts.nunitoSans(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.dmlBlue,
      brightness: Brightness.light,
    ),
    fontFamily: GoogleFonts.nunitoSans().fontFamily,
  );
}
```

### Pattern: app_spacing.dart
```dart
/// 4dp base grid spacing constants.
/// NEVER hardcode padding/margin values — ALWAYS use AppSpacing
abstract final class AppSpacing {
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 12.0;
  static const double lg  = 16.0;
  static const double xl  = 24.0;
  static const double xxl = 32.0;
  static const double xxxl= 48.0;

  // ─── Border Radius ────────────────────────────────────────
  static const double radiusSm   = 8.0;
  static const double radiusMd   = 12.0;
  static const double radiusLg   = 16.0;
  static const double radiusFull = 999.0;

  // ─── Page Padding ─────────────────────────────────────────
  static const EdgeInsets pagePadding =
      EdgeInsets.symmetric(horizontal: lg, vertical: lg);
  static const EdgeInsets cardPadding =
      EdgeInsets.all(lg);
}
```

---

## 📝 SKILL 6 — LOGGING (talker)

### Rule
NEVER use print(). ALWAYS use the logger singleton from `core/utils/logger.dart`.
Use correct log levels: verbose → debug → info → warning → error → critical.
ALWAYS log with context: class name + method name in message.
ALWAYS pass error object and stackTrace to error/critical logs.

### Pattern: logger.dart
```dart
/// DML Hub global logger singleton.
/// Import this instance wherever logging is needed.
final logger = TalkerFlutter.init(
  settings: TalkerSettings(
    enabled: true,
    useConsoleLogs: kDebugMode,
    maxHistoryItems: 500,
  ),
);
```

### Pattern: Correct log level usage
```dart
logger.verbose('TaskDao: query params = $params');       // trace-level detail
logger.debug('TaskRepository: fetching today tasks');    // dev-time debug
logger.info('Task created successfully: $taskId');       // business events
logger.warning('Recurrence rule null, skipping');        // unexpected but recoverable
logger.error('TaskRepository: insert failed', error: e, stackTrace: st); // failures
logger.critical('AppDatabase: failed to open', error: e); // app cannot continue
```

---

## 🔢 SKILL 7 — DATA CLASSES (freezed)

### Rule
ALL entities, DTOs, params, and state classes MUST use freezed.
Entities live in domain/entities/. DTOs live in data/models/.
DTOs have fromJson/toJson. Entities do NOT have json serialization.
ALWAYS use copyWith() for mutations — never mutate directly.

### Pattern: Entity (domain layer — NO json)
```dart
/// Core Task entity — domain layer, no serialization.
@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    String? description,
    required TaskPriority priority,
    required TaskStatus status,
    DateTime? dueDate,
    DateTime? dueTime,
    required bool isRecurring,
    RecurrenceRule? recurrenceRule,
    String? projectId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isPinned,
  }) = _Task;
}

enum TaskPriority { none, low, medium, high }
enum TaskStatus { todo, inProgress, done, cancelled }
```

### Pattern: DTO (data layer — WITH json)
```dart
/// Task DTO — data layer only, maps to/from Drift and domain entity.
@freezed
class TaskDto with _$TaskDto {
  const factory TaskDto({
    required String id,
    required String title,
    String? description,
    required String priority,
    required String status,
    DateTime? dueDate,
    DateTime? dueTime,
    required bool isRecurring,
    String? recurrenceRule,
    String? projectId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isPinned,
  }) = _TaskDto;

  factory TaskDto.fromJson(Map<String, dynamic> json) =>
      _$TaskDtoFromJson(json);

  /// Convert domain entity to DTO
  factory TaskDto.fromEntity(Task task) => TaskDto(
    id: task.id,
    title: task.title,
    description: task.description,
    priority: task.priority.name,
    status: task.status.name,
    dueDate: task.dueDate,
    dueTime: task.dueTime,
    isRecurring: task.isRecurring,
    recurrenceRule: task.recurrenceRule?.name,
    projectId: task.projectId,
    createdAt: task.createdAt,
    updatedAt: task.updatedAt,
    isPinned: task.isPinned,
  );
}

/// Extension for converting DTO back to domain entity
extension TaskDtoX on TaskDto {
  Task toEntity() => Task(
    id: id,
    title: title,
    description: description,
    priority: TaskPriority.values.byName(priority),
    status: TaskStatus.values.byName(status),
    dueDate: dueDate,
    dueTime: dueTime,
    isRecurring: isRecurring,
    recurrenceRule: recurrenceRule != null
        ? RecurrenceRule.values.byName(recurrenceRule!)
        : null,
    projectId: projectId,
    createdAt: createdAt,
    updatedAt: updatedAt,
    isPinned: isPinned,
  );
}
```

---

## 🧩 SKILL 8 — RIVERPOD CODE-GEN PATTERNS

### Rule
ALL providers MUST use @riverpod annotation (code-gen only).
NEVER use Provider(), StateProvider(), etc. manually.
Providers are in feature/presentation/providers/ ONLY.
Providers orchestrate — they NEVER contain business logic.
Always run: `dart run build_runner watch --delete-conflicting-outputs`

### Pattern: Simple async provider
```dart
/// Watches all tasks reactively from repository.
@riverpod
Stream<Either<Failure, List<Task>>> taskList(TaskListRef ref) {
  return ref.watch(taskRepositoryProvider).watchAllTasks();
}
```

### Pattern: StateNotifier-style with @riverpod
```dart
/// Manages task filter/sort state for AllTasks screen.
@riverpod
class TaskFilter extends _$TaskFilter {
  @override
  TaskFilterState build() => const TaskFilterState();

  void setPriority(TaskPriority? priority) {
    state = state.copyWith(priority: priority);
  }

  void setStatus(TaskStatus? status) {
    state = state.copyWith(status: status);
  }

  void reset() {
    state = const TaskFilterState();
  }
}

@freezed
class TaskFilterState with _$TaskFilterState {
  const factory TaskFilterState({
    TaskPriority? priority,
    TaskStatus? status,
    TaskSortBy sortBy = TaskSortBy.dueDate,
  }) = _TaskFilterState;
}
```

---

## 🧱 SKILL 9 — SHARED CORE WIDGETS

### Rule
Generic/reusable widgets live in core/widgets/.
Feature-specific widgets live in features/{name}/presentation/widgets/.
NEVER duplicate loading/error/empty widgets across features.
ALL widgets must use const constructor where possible.

### Pattern: AsyncValue handling widget
```dart
/// Generic async result handler — use this EVERY time you consume AsyncValue.
/// NEVER write inline if (state.isLoading) ... chains in screen widgets.
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const AppLoadingWidget(),
      error: (error, _) => AppErrorWidget(message: error.toString()),
      data: data,
    );
  }
}
```

---

## ⚙️ SKILL 10 — main.dart BOOTSTRAP PATTERN

### Pattern: main.dart
```dart
/// DML Hub application entry point.
/// Bootstrap order: logger → dependencies → biometric check → runApp
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Init logger first — always
  logger.info('DML Hub: Starting bootstrap sequence');

  // 2. Init all dependencies
  await initializeDependencies();
  logger.info('DML Hub: Dependencies initialized');

  // 3. Init notifications
  await getIt<NotificationService>().initialize();
  logger.info('DML Hub: Notifications initialized');

  // 4. Launch app
  runApp(
    ProviderScope(
      observers: [TalkerRiverpodObserver(talker: logger)],
      child: const DmlHubApp(),
    ),
  );
}

class DmlHubApp extends StatelessWidget {
  const DmlHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DML Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system, // overridden by settings provider
      routerConfig: appRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
```

---

# END OF core-SKILLS.md
# Attach with: SYSTEM_PROMPT.md
# When to attach: Working on core/, DI, routing, theming, error handling, logging, main.dart
