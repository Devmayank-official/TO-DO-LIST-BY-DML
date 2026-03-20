# todo-SKILLS.md
# DML Hub — To-Do Plugin Skills & Patterns
# Company: DML Labs | Package: com.dmllabs.hub
# Attach: When working on ANYTHING inside lib/features/todo/
# Always attach ALONGSIDE: SYSTEM_PROMPT.md + core-SKILLS.md

---

## 📁 TODO FEATURE FOLDER STRUCTURE

```
lib/features/todo/
│
├── data/
│   ├── datasources/
│   │   ├── todo_local_datasource.dart        # Abstract interface
│   │   └── todo_local_datasource_impl.dart   # Drift DAO orchestrator
│   ├── database/
│   │   ├── app_database.dart                 # Single Drift DB definition
│   │   ├── app_database.g.dart               # Generated
│   │   ├── daos/
│   │   │   ├── task_dao.dart                 # Task CRUD + queries
│   │   │   ├── project_dao.dart              # Project CRUD
│   │   │   ├── tag_dao.dart                  # Tag CRUD
│   │   │   ├── subtask_dao.dart              # Subtask CRUD
│   │   │   └── task_tag_dao.dart             # M2M join table DAO
│   │   └── tables/
│   │       ├── tasks_table.dart              # Drift table definition
│   │       ├── projects_table.dart
│   │       ├── tags_table.dart
│   │       ├── subtasks_table.dart
│   │       └── task_tags_table.dart          # M2M join
│   └── repositories/
│       └── task_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   ├── task.dart                         # Core Task entity
│   │   ├── project.dart                      # Project entity
│   │   ├── tag.dart                          # Tag entity
│   │   └── subtask.dart                      # Subtask entity
│   ├── repositories/
│   │   └── task_repository.dart              # Abstract contract
│   └── usecases/
│       ├── task/
│       │   ├── create_task_usecase.dart
│       │   ├── update_task_usecase.dart
│       │   ├── delete_task_usecase.dart
│       │   ├── complete_task_usecase.dart
│       │   ├── get_today_tasks_usecase.dart
│       │   ├── get_all_tasks_usecase.dart
│       │   └── pin_task_usecase.dart
│       ├── project/
│       │   ├── create_project_usecase.dart
│       │   ├── update_project_usecase.dart
│       │   ├── delete_project_usecase.dart
│       │   └── get_projects_usecase.dart
│       └── tag/
│           ├── create_tag_usecase.dart
│           └── get_tags_usecase.dart
│
└── presentation/
    ├── providers/
    │   ├── task_providers.dart               # Task list, today, filter
    │   ├── task_providers.g.dart
    │   ├── project_providers.dart
    │   ├── project_providers.g.dart
    │   ├── tag_providers.dart
    │   └── tag_providers.g.dart
    ├── screens/
    │   ├── todo_shell.dart                   # Plugin shell + BottomNavBar
    │   ├── today/
    │   │   └── todo_today_page.dart
    │   ├── tasks/
    │   │   ├── todo_all_tasks_page.dart
    │   │   └── todo_task_detail_page.dart
    │   ├── projects/
    │   │   ├── todo_projects_page.dart
    │   │   └── todo_project_detail_page.dart
    │   └── settings/
    │       └── todo_settings_page.dart
    └── widgets/
        ├── task_card.dart                    # Task list item
        ├── task_checkbox.dart                # Animated completion checkbox
        ├── subtask_item.dart                 # Subtask row inside detail
        ├── priority_badge.dart               # Color-coded priority chip
        ├── add_task_sheet.dart               # Bottom sheet for quick-add
        ├── task_filter_bar.dart              # Filter/sort toolbar
        └── project_chip.dart                # Project label chip
```

---

## 🗄️ SKILL 1 — DRIFT DATABASE SCHEMA

### Rule
Single `AppDatabase` class contains ALL tables for ALL plugins.
NEVER create separate database files per plugin.
Each plugin owns its tables but shares the single DB instance.
Migrations are centrally managed in `AppDatabase`.
ALL primary keys use `TextColumn` (UUID strings) — NEVER auto-increment integers.
ALL timestamps stored as `DateTimeColumn` with `withTimezone: false`.

### Pattern: tasks_table.dart
```dart
/// Tasks table — core task data.
/// UUID primary key. All foreign keys reference other UUID columns.
class Tasks extends Table {
  /// UUID primary key — never auto-increment
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 500)();
  TextColumn get description => text().nullable()();

  /// Stored as enum name string: 'none' | 'low' | 'medium' | 'high'
  TextColumn get priority => text().withDefault(const Constant('none'))();

  /// Stored as enum name string: 'todo' | 'inProgress' | 'done' | 'cancelled'
  TextColumn get status => text().withDefault(const Constant('todo'))();

  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get dueTime => dateTime().nullable()();

  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();

  /// Stored as enum name string: 'daily' | 'weekly' | 'monthly' | 'yearly'
  TextColumn get recurrenceRule => text().nullable()();

  /// FK → projects.id (nullable — task may have no project)
  TextColumn get projectId => text().nullable()
    .references(Projects, #id, onDelete: KeyAction.setNull)();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### Pattern: projects_table.dart
```dart
/// Projects table — task grouping by context.
class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();

  /// Hex color string e.g. '#4A90D9'
  TextColumn get color => text().withDefault(const Constant('#4A90D9'))();
  TextColumn get icon => text().withDefault(const Constant('folder'))();

  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### Pattern: tags_table.dart
```dart
/// Tags table — cross-cutting labels for tasks.
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get color => text().withDefault(const Constant('#4A90D9'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### Pattern: task_tags_table.dart (M2M join)
```dart
/// Many-to-many join: one task can have many tags.
class TaskTags extends Table {
  TextColumn get taskId => text()
    .references(Tasks, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId => text()
    .references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {taskId, tagId};
}
```

### Pattern: subtasks_table.dart
```dart
/// Subtasks — 1 level deep ONLY. Never nested.
class Subtasks extends Table {
  TextColumn get id => text()();

  /// FK → tasks.id (cascade delete — subtasks die with parent)
  TextColumn get taskId => text()
    .references(Tasks, #id, onDelete: KeyAction.cascade)();

  TextColumn get title => text().withLength(min: 1, max: 300)();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### Pattern: app_database.dart
```dart
/// Single DML Hub Drift database.
/// ALL plugin tables registered here.
/// Migrations centrally managed.
@DriftDatabase(
  tables: [
    Tasks,
    Projects,
    Tags,
    TaskTags,
    Subtasks,
    // Future: HabitEntries, JournalEntries, Notes, Goals...
  ],
  daos: [
    TaskDao,
    ProjectDao,
    TagDao,
    TaskTagDao,
    SubtaskDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      logger.info('AppDatabase: Schema v1 created');
    },
    onUpgrade: (m, from, to) async {
      logger.info('AppDatabase: Migrating schema $from → $to');
      // Add migration steps here for each version bump
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      logger.debug('AppDatabase: Opened (v${details.versionNow})');
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'dml_hub_db');
  }
}
```

---

## 📊 SKILL 2 — DRIFT DAOs

### Rule
One DAO per table/domain. NEVER mix concerns across DAOs.
ALL DAOs extend `DatabaseAccessor<AppDatabase>`.
Watch methods return `Stream<>` — NEVER Future for list queries (use reactive streams).
ALWAYS use Drift's type-safe query API — NEVER raw SQL strings.
ALWAYS handle cascade deletes via Drift's `KeyAction.cascade` on foreign keys.

### Pattern: task_dao.dart
```dart
/// Data access object for Tasks table.
/// All task persistence operations go through here.
@DriftAccessor(tables: [Tasks, TaskTags, Tags, Subtasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  /// Watch today's tasks: due today + overdue + pinned (reactive stream)
  Stream<List<Task>> watchTodayTasks() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(tasks)
      ..where((t) =>
        t.status.isNotIn(['done', 'cancelled']) &
        (
          t.isPinned.equals(true) |
          t.dueDate.isSmallerOrEqualValue(endOfDay) // today + overdue
        ),
      )
      ..orderBy([
        (t) => OrderingTerm(expression: t.isPinned, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.asc),
        (t) => OrderingTerm(expression: t.priority, mode: OrderingMode.desc),
      ])
    ).watch();
  }

  /// Watch all incomplete tasks (reactive stream)
  Stream<List<Task>> watchAllTasks({
    String? projectId,
    String? priority,
    String? status,
  }) {
    final query = select(tasks)
      ..where((t) {
        Expression<bool> condition = const Constant(true);
        if (projectId != null) condition = condition & t.projectId.equals(projectId);
        if (priority != null) condition = condition & t.priority.equals(priority);
        if (status != null) condition = condition & t.status.equals(status);
        return condition;
      })
      ..orderBy([
        (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.asc),
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  /// Get count of today's active tasks (for Hub quick stat)
  Stream<int> watchTodayTaskCount() {
    final today = DateTime.now();
    final endOfDay = DateTime(today.year, today.month, today.day + 1);

    final countExp = tasks.id.count();
    final query = selectOnly(tasks)
      ..addColumns([countExp])
      ..where(
        tasks.status.isNotIn(['done', 'cancelled']) &
        tasks.dueDate.isSmallerOrEqualValue(endOfDay),
      );
    return query.map((row) => row.read(countExp) ?? 0).watchSingle();
  }

  /// Insert a new task — returns generated row ID
  Future<int> insertTask(TasksCompanion task) => into(tasks).insert(task);

  /// Update existing task
  Future<bool> updateTask(TasksCompanion task) => update(tasks).replace(task);

  /// Soft-delete: mark as cancelled (preserves history)
  Future<void> cancelTask(String id) {
    return (update(tasks)..where((t) => t.id.equals(id)))
      .write(TasksCompanion(
        status: const Value('cancelled'),
        updatedAt: Value(DateTime.now()),
      ));
  }

  /// Hard delete — use only for explicit "delete forever" actions
  Future<int> deleteTask(String id) {
    return (delete(tasks)..where((t) => t.id.equals(id))).go();
  }

  /// Mark task complete + set updatedAt
  Future<void> completeTask(String id) {
    return (update(tasks)..where((t) => t.id.equals(id)))
      .write(TasksCompanion(
        status: const Value('done'),
        updatedAt: Value(DateTime.now()),
      ));
  }

  /// Toggle pin state
  Future<void> togglePin(String id, bool isPinned) {
    return (update(tasks)..where((t) => t.id.equals(id)))
      .write(TasksCompanion(
        isPinned: Value(isPinned),
        updatedAt: Value(DateTime.now()),
      ));
  }
}
```

### Pattern: project_dao.dart
```dart
/// Data access object for Projects table.
@DriftAccessor(tables: [Projects])
class ProjectDao extends DatabaseAccessor<AppDatabase> with _$ProjectDaoMixin {
  ProjectDao(super.db);

  /// Watch all active (non-archived) projects
  Stream<List<Project>> watchActiveProjects() {
    return (select(projects)
      ..where((p) => p.isArchived.equals(false))
      ..orderBy([(p) => OrderingTerm(expression: p.name)])
    ).watch();
  }

  Future<int> insertProject(ProjectsCompanion project) =>
      into(projects).insert(project);

  Future<bool> updateProject(ProjectsCompanion project) =>
      update(projects).replace(project);

  Future<int> deleteProject(String id) =>
      (delete(projects)..where((p) => p.id.equals(id))).go();
}
```

---

## 🏛️ SKILL 3 — REPOSITORY CONTRACT + IMPLEMENTATION

### Pattern: task_repository.dart (domain — abstract)
```dart
/// Abstract contract for all task persistence operations.
/// Domain layer owns this — data layer implements it.
/// ALL methods return Either<Failure, R> — no exceptions leak out.
abstract class TaskRepository {
  // ─── Tasks ─────────────────────────────────────────────────
  Stream<Either<Failure, List<Task>>> watchTodayTasks();
  Stream<Either<Failure, List<Task>>> watchAllTasks({
    String? projectId,
    String? priority,
    String? status,
  });
  Stream<Either<Failure, int>> watchTodayTaskCount();
  Future<Either<Failure, Task>> createTask(Task task);
  Future<Either<Failure, Task>> updateTask(Task task);
  Future<Either<Failure, Unit>> completeTask(String taskId);
  Future<Either<Failure, Unit>> deleteTask(String taskId);
  Future<Either<Failure, Unit>> pinTask(String taskId, bool isPinned);

  // ─── Projects ──────────────────────────────────────────────
  Stream<Either<Failure, List<Project>>> watchActiveProjects();
  Future<Either<Failure, Project>> createProject(Project project);
  Future<Either<Failure, Project>> updateProject(Project project);
  Future<Either<Failure, Unit>> deleteProject(String projectId);

  // ─── Tags ──────────────────────────────────────────────────
  Stream<Either<Failure, List<Tag>>> watchAllTags();
  Future<Either<Failure, Tag>> createTag(Tag tag);
}
```

### Pattern: task_repository_impl.dart (data — concrete)
```dart
/// Concrete task repository — wraps Drift DAOs.
/// ONLY class allowed to call DAOs directly.
/// ALL exceptions caught here — NEVER propagate to domain.
class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl({
    required TaskDao taskDao,
    required ProjectDao projectDao,
    required TagDao tagDao,
  })  : _taskDao = taskDao,
        _projectDao = projectDao,
        _tagDao = tagDao;

  final TaskDao _taskDao;
  final ProjectDao _projectDao;
  final TagDao _tagDao;

  @override
  Stream<Either<Failure, List<Task>>> watchTodayTasks() {
    return _taskDao.watchTodayTasks().map(
      (rows) => Right<Failure, List<Task>>(
        rows.map((r) => _mapRowToTask(r)).toList(),
      ),
    ).handleError((e, st) {
      logger.error('TaskRepository: watchTodayTasks stream error', error: e, stackTrace: st);
      return Left<Failure, List<Task>>(DatabaseFailure('Failed to watch today tasks'));
    });
  }

  @override
  Future<Either<Failure, Task>> createTask(Task task) async {
    try {
      final companion = TasksCompanion.insert(
        id: task.id,
        title: task.title,
        description: Value(task.description),
        priority: task.priority.name,
        status: task.status.name,
        dueDate: Value(task.dueDate),
        dueTime: Value(task.dueTime),
        isPinned: Value(task.isPinned),
        isRecurring: Value(task.isRecurring),
        recurrenceRule: Value(task.recurrenceRule?.name),
        projectId: Value(task.projectId),
        createdAt: task.createdAt,
        updatedAt: task.updatedAt,
      );
      await _taskDao.insertTask(companion);
      logger.info('TaskRepository: Task created — ${task.id}');
      return Right(task);
    } on DriftWrappedException catch (e, st) {
      logger.error('TaskRepository: createTask DB error', error: e, stackTrace: st);
      return Left(DatabaseFailure('Failed to save task'));
    } catch (e, st) {
      logger.error('TaskRepository: createTask unexpected', error: e, stackTrace: st);
      return Left(UnexpectedFailure('Unexpected error creating task'));
    }
  }

  @override
  Future<Either<Failure, Unit>> completeTask(String taskId) async {
    try {
      await _taskDao.completeTask(taskId);
      logger.info('TaskRepository: Task completed — $taskId');
      return const Right(unit);
    } on DriftWrappedException catch (e, st) {
      logger.error('TaskRepository: completeTask failed', error: e, stackTrace: st);
      return Left(DatabaseFailure('Failed to complete task'));
    }
  }

  /// Maps Drift row → domain Task entity
  Task _mapRowToTask(Task row) => Task(
    id: row.id,
    title: row.title,
    description: row.description,
    priority: TaskPriority.values.byName(row.priority),
    status: TaskStatus.values.byName(row.status),
    dueDate: row.dueDate,
    dueTime: row.dueTime,
    isPinned: row.isPinned,
    isRecurring: row.isRecurring,
    recurrenceRule: row.recurrenceRule != null
        ? RecurrenceRule.values.byName(row.recurrenceRule!)
        : null,
    projectId: row.projectId,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}
```

---

## ⚡ SKILL 4 — USE CASES (All MVP Actions)

### Pattern: complete_task_usecase.dart
```dart
/// Marks a task as done.
/// Side effects: cancels notification, handles recurrence spawn.
class CompleteTaskUseCase extends UseCase<Unit, CompleteTaskParams> {
  const CompleteTaskUseCase(this._repository, this._notificationService);

  final TaskRepository _repository;
  final NotificationService _notificationService;

  @override
  Future<Either<Failure, Unit>> call(CompleteTaskParams params) async {
    if (params.taskId.isEmpty) {
      return const Left(ValidationFailure('Task ID cannot be empty'));
    }

    // 1. Mark complete in DB
    final result = await _repository.completeTask(params.taskId);
    if (result.isLeft()) return result;

    // 2. Cancel existing notification
    await _notificationService.cancelNotification(params.taskId);

    // 3. Recurrence: if recurring, spawn next occurrence
    if (params.isRecurring && params.recurrenceRule != null) {
      await _spawnNextRecurrence(params);
    }

    return const Right(unit);
  }

  Future<void> _spawnNextRecurrence(CompleteTaskParams params) async {
    final nextDue = _calculateNextDue(params.dueDate, params.recurrenceRule!);
    if (nextDue == null) return;

    final newTask = Task(
      id: const Uuid().v4(),
      title: params.title,
      priority: params.priority,
      status: TaskStatus.todo,
      isRecurring: true,
      recurrenceRule: params.recurrenceRule,
      dueDate: nextDue,
      projectId: params.projectId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPinned: false,
    );

    await _repository.createTask(newTask);
    logger.info('CompleteTaskUseCase: Spawned recurrence → ${newTask.id}');
  }

  DateTime? _calculateNextDue(DateTime? current, RecurrenceRule rule) {
    if (current == null) return null;
    return switch (rule) {
      RecurrenceRule.daily   => current.add(const Duration(days: 1)),
      RecurrenceRule.weekly  => current.add(const Duration(days: 7)),
      RecurrenceRule.monthly => DateTime(current.year, current.month + 1, current.day),
      RecurrenceRule.yearly  => DateTime(current.year + 1, current.month, current.day),
    };
  }
}

@freezed
class CompleteTaskParams with _$CompleteTaskParams {
  const factory CompleteTaskParams({
    required String taskId,
    required String title,
    required TaskPriority priority,
    required bool isRecurring,
    RecurrenceRule? recurrenceRule,
    DateTime? dueDate,
    String? projectId,
  }) = _CompleteTaskParams;
}
```

### Pattern: get_today_tasks_usecase.dart
```dart
/// Returns a reactive stream of today's tasks (due + overdue + pinned).
class GetTodayTasksUseCase {
  const GetTodayTasksUseCase(this._repository);
  final TaskRepository _repository;

  Stream<Either<Failure, List<Task>>> call() {
    return _repository.watchTodayTasks();
  }
}
```

---

## 🔌 SKILL 5 — RIVERPOD PROVIDERS

### Pattern: task_providers.dart
```dart
// ─── Repository Provider ──────────────────────────────────────
@riverpod
TaskRepository taskRepository(TaskRepositoryRef ref) {
  return getIt<TaskRepository>();
}

// ─── Today Tasks Stream ───────────────────────────────────────
@riverpod
Stream<Either<Failure, List<Task>>> todayTasks(TodayTasksRef ref) {
  return ref.watch(taskRepositoryProvider).watchTodayTasks();
}

// ─── Today Task Count (for Hub quick stat) ────────────────────
@riverpod
Stream<int> todayTaskCount(TodayTaskCountRef ref) {
  return ref.watch(taskRepositoryProvider)
    .watchTodayTaskCount()
    .map((either) => either.fold((_) => 0, (count) => count));
}

// ─── All Tasks Stream ─────────────────────────────────────────
@riverpod
Stream<Either<Failure, List<Task>>> allTasks(AllTasksRef ref) {
  final filter = ref.watch(taskFilterProvider);
  return ref.watch(taskRepositoryProvider).watchAllTasks(
    projectId: filter.projectId,
    priority: filter.priority?.name,
    status: filter.status?.name,
  );
}

// ─── Task Filter State ────────────────────────────────────────
@riverpod
class TaskFilter extends _$TaskFilter {
  @override
  TaskFilterState build() => const TaskFilterState();

  void setProject(String? projectId) =>
      state = state.copyWith(projectId: projectId);

  void setPriority(TaskPriority? priority) =>
      state = state.copyWith(priority: priority);

  void setStatus(TaskStatus? status) =>
      state = state.copyWith(status: status);

  void reset() => state = const TaskFilterState();
}

@freezed
class TaskFilterState with _$TaskFilterState {
  const factory TaskFilterState({
    String? projectId,
    TaskPriority? priority,
    TaskStatus? status,
    @Default(TaskSortBy.dueDate) TaskSortBy sortBy,
  }) = _TaskFilterState;
}

enum TaskSortBy { dueDate, priority, createdAt, title }

// ─── Create Task Action ───────────────────────────────────────
@riverpod
Future<void> createTask(CreateTaskRef ref, CreateTaskParams params) async {
  final useCase = getIt<CreateTaskUseCase>();
  final result = await useCase(params);
  result.fold(
    (failure) {
      logger.w('CreateTask failed: ${failure.message}');
      ref.read(taskActionErrorProvider.notifier).state = failure.message;
    },
    (_) {
      logger.i('Task created successfully');
      ref.invalidate(todayTasksProvider);
      ref.invalidate(allTasksProvider);
    },
  );
}

// ─── Complete Task Action ─────────────────────────────────────
@riverpod
Future<void> completeTask(CompleteTaskRef ref, CompleteTaskParams params) async {
  final useCase = getIt<CompleteTaskUseCase>();
  final result = await useCase(params);
  result.fold(
    (failure) => logger.w('CompleteTask failed: ${failure.message}'),
    (_) {
      ref.invalidate(todayTasksProvider);
      ref.invalidate(allTasksProvider);
    },
  );
}

// ─── Action Error State ───────────────────────────────────────
@riverpod
class TaskActionError extends _$TaskActionError {
  @override
  String? build() => null;

  void clear() => state = null;
}
```

---

## 🐚 SKILL 6 — TODO PLUGIN SHELL

### Rule
`TodoShell` is the scaffold that wraps ALL To-Do plugin screens.
It owns the plugin-level `NavigationBar` (Today / Tasks / Projects).
NEVER put Hub-level navigation inside TodoShell.
The `child` parameter from ShellRoute is the active screen content.
Settings tab navigates to /hub/todo/settings (pushed, not a tab).

### Pattern: todo_shell.dart
```dart
/// To-Do plugin shell — provides plugin-level BottomNavigationBar.
/// Wraps all /hub/todo/* screens. Owned entirely by the To-Do plugin.
class TodoShell extends StatelessWidget {
  const TodoShell({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    AppRoutes.todoToday,
    AppRoutes.todoTasks,
    AppRoutes.todoProjects,
  ];

  int _locationToIndex(String location) {
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(), // Back to Hub
          tooltip: 'Back to DML Hub',
        ),
        title: Text(
          _tabTitle(currentIndex),
          style: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.todoSettings),
            tooltip: 'To-Do Settings',
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => context.go(_tabs[index]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today_rounded),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist_rounded),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Projects',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task'),
        backgroundColor: AppColors.dmlBlue,
      ),
    );
  }

  String _tabTitle(int index) => switch (index) {
    0 => 'Today',
    1 => 'All Tasks',
    2 => 'Projects',
    _ => 'To-Do',
  };

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTaskSheet(),
    );
  }
}
```

---

## 📅 SKILL 7 — TODAY SCREEN

### Pattern: todo_today_page.dart
```dart
/// Today view — due today + overdue + pinned tasks.
/// Uses reactive Riverpod stream from watchTodayTasks.
class TodoTodayPage extends ConsumerWidget {
  const TodoTodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(todayTasksProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(todayTasksProvider),
      child: tasksAsync.when(
        loading: () => const AppLoadingWidget(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (either) => either.fold(
          (failure) => AppErrorWidget(message: failure.message),
          (tasks) => tasks.isEmpty
              ? const _TodayEmptyState()
              : _TodayTaskList(tasks: tasks),
        ),
      ),
    );
  }
}

class _TodayTaskList extends StatelessWidget {
  const _TodayTaskList({required this.tasks});
  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    // Separate overdue from today
    final now = DateTime.now();
    final overdue = tasks.where((t) =>
      t.dueDate != null && t.dueDate!.isBefore(DateTime(now.year, now.month, now.day))
    ).toList();
    final todayTasks = tasks.where((t) =>
      t.isPinned || (t.dueDate != null && !t.dueDate!.isBefore(DateTime(now.year, now.month, now.day)))
    ).toList();

    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        if (overdue.isNotEmpty) ...[
          _SectionHeader(title: 'Overdue', color: AppColors.error),
          ...overdue.asMap().entries.map((e) =>
            TaskCard(task: e.value, index: e.key).animate()
              .fadeIn(delay: Duration(milliseconds: e.key * 50))
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (todayTasks.isNotEmpty) ...[
          _SectionHeader(title: 'Today', color: AppColors.dmlBlue),
          ...todayTasks.asMap().entries.map((e) =>
            TaskCard(task: e.value, index: e.key + overdue.length)
              .animate()
              .fadeIn(delay: Duration(milliseconds: (e.key + overdue.length) * 50))
          ),
        ],
      ],
    );
  }
}
```

---

## ✅ SKILL 8 — TASK CARD + COMPLETION ANIMATION

### Rule
TaskCard is a pure display widget — all actions dispatched via providers.
Completion animation: checkbox scale → task strikethrough → fade out (300ms total).
NEVER call use cases directly from widgets — ALWAYS go through providers.
Swipe-to-delete uses Dismissible — confirm with SnackBar undo action.

### Pattern: task_card.dart
```dart
/// Task list item with animated completion checkbox.
class TaskCard extends ConsumerStatefulWidget {
  const TaskCard({super.key, required this.task, required this.index});
  final Task task;
  final int index;

  @override
  ConsumerState<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<TaskCard> {
  bool _completing = false;

  Future<void> _onComplete() async {
    if (_completing) return;
    setState(() => _completing = true);

    // Slight delay for animation to breathe
    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    await ref.read(completeTaskProvider(CompleteTaskParams(
      taskId: widget.task.id,
      title: widget.task.title,
      priority: widget.task.priority,
      isRecurring: widget.task.isRecurring,
      recurrenceRule: widget.task.recurrenceRule,
      dueDate: widget.task.dueDate,
      projectId: widget.task.projectId,
    )).future);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _completing ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // ─── Animated Checkbox ──────────────────────
              TaskCheckbox(
                isDone: widget.task.status == TaskStatus.done,
                onTap: _onComplete,
              ),
              const SizedBox(width: AppSpacing.md),

              // ─── Task Content ───────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: GoogleFonts.nunitoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _completing
                          ? AppColors.contentDisabled
                          : Theme.of(context).colorScheme.onSurface,
                        decoration: _completing
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      ),
                      child: Text(widget.task.title, maxLines: 2),
                    ),
                    if (widget.task.dueDate != null)
                      _DueDateLabel(dueDate: widget.task.dueDate!),
                  ],
                ),
              ),

              // ─── Priority Badge ──────────────────────────
              if (widget.task.priority != TaskPriority.none)
                PriorityBadge(priority: widget.task.priority),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Pattern: task_checkbox.dart (the dopamine widget)
```dart
/// Animated task completion checkbox.
/// Scale pulse on tap → color fill → checkmark appear.
class TaskCheckbox extends StatelessWidget {
  const TaskCheckbox({
    super.key,
    required this.isDone,
    required this.onTap,
  });
  final bool isDone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDone ? AppColors.dmlBlue : Colors.transparent,
          border: Border.all(
            color: isDone ? AppColors.dmlBlue : AppColors.contentSecondary,
            width: 2,
          ),
        ),
        child: isDone
          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
              .animate().scale(duration: 150.ms, curve: Curves.easeOutBack)
          : null,
      ),
    ).animate(target: isDone ? 1 : 0)
     .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 100.ms)
     .then()
     .scale(begin: const Offset(1.2, 1.2), end: const Offset(1, 1), duration: 100.ms);
  }
}
```

---

## 🔔 SKILL 9 — LOCAL NOTIFICATIONS

### Rule
NotificationService is a domain-level abstraction — plugin doesn't know about flutter_local_notifications directly.
ALWAYS use task UUID as notification ID (converted to int via hashCode).
ALWAYS cancel notification on task complete/delete.
ALWAYS request permissions before scheduling (Android 13+).
Notification channels: one per plugin (todo_channel, habits_channel, etc.)

### Pattern: NotificationService (domain interface)
```dart
/// Abstract notification service — platform-agnostic.
abstract class NotificationService {
  Future<void> initialize();
  Future<Either<Failure, Unit>> scheduleTaskNotification(Task task);
  Future<Either<Failure, Unit>> cancelNotification(String taskId);
  Future<Either<Failure, Unit>> cancelAllNotifications();
  Future<bool> requestPermission();
}
```

### Pattern: NotificationServiceImpl
```dart
class NotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _todoChannelId = 'dml_todo_channel';
  static const _todoChannelName = 'To-Do Reminders';

  @override
  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);

    // Create notification channel (Android 8+)
    const channel = AndroidNotificationChannel(
      _todoChannelId,
      _todoChannelName,
      description: 'Reminders for your To-Do tasks',
      importance: Importance.high,
    );
    await _plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

    logger.info('NotificationService: Initialized');
  }

  @override
  Future<Either<Failure, Unit>> scheduleTaskNotification(Task task) async {
    if (task.dueDate == null) return const Right(unit); // nothing to schedule
    try {
      final scheduledDate = TZDateTime.from(
        task.dueDate!,
        local,
      );
      await _plugin.zonedSchedule(
        task.id.hashCode,
        'Task Due: ${task.title}',
        task.priority != TaskPriority.none
            ? '${task.priority.name.toUpperCase()} priority'
            : 'Tap to open DML Hub',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _todoChannelId,
            _todoChannelName,
            importance: Importance.high,
            priority: Priority.high,
            color: AppColors.dmlBlue,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      logger.info('NotificationService: Scheduled for task ${task.id}');
      return const Right(unit);
    } catch (e, st) {
      logger.error('NotificationService: schedule failed', error: e, stackTrace: st);
      return Left(NotificationFailure('Failed to schedule reminder'));
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelNotification(String taskId) async {
    try {
      await _plugin.cancel(taskId.hashCode);
      return const Right(unit);
    } catch (e, st) {
      logger.error('NotificationService: cancel failed', error: e, stackTrace: st);
      return Left(NotificationFailure('Failed to cancel reminder'));
    }
  }

  @override
  Future<bool> requestPermission() async {
    final result = await _plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
    return result ?? false;
  }
}
```

---

## 🔁 SKILL 10 — RECURRENCE RULES

```dart
/// Recurrence rule enum — stored as string in DB.
enum RecurrenceRule {
  daily,    // Every 24 hours from due date
  weekly,   // Every 7 days from due date
  monthly,  // Same day next calendar month
  yearly,   // Same date next year
}
```

---

## 🏷️ SKILL 11 — PRIORITY BADGE WIDGET

```dart
/// Color-coded priority indicator chip.
class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.priority});
  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        priority.name.toUpperCase(),
        style: GoogleFonts.nunitoSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color get _color => switch (priority) {
    TaskPriority.high   => AppColors.priorityHigh,
    TaskPriority.medium => AppColors.priorityMedium,
    TaskPriority.low    => AppColors.priorityLow,
    TaskPriority.none   => AppColors.priorityNone,
  };
}
```

---

## 📊 SKILL 12 — TODO QUICK STAT PROVIDER (Hub Integration)

```dart
/// Exposes today's task count to Hub Home plugin card.
/// This is the ONLY provider Hub reads from the To-Do plugin.
/// All other cross-plugin communication goes through Hub providers.
@riverpod
Stream<int> todayTaskCount(TodayTaskCountRef ref) {
  return getIt<TaskRepository>()
    .watchTodayTaskCount()
    .map((either) => either.fold((_) => 0, (count) => count));
}
```

---

# END OF todo-SKILLS.md
# Attach with: SYSTEM_PROMPT.md + core-SKILLS.md
# Optionally attach: hub-SKILLS.md (when working on Hub ↔ To-Do integration)
# When to attach: ANY work inside lib/features/todo/
