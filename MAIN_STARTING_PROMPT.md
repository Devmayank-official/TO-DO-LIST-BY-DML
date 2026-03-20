# MAIN_STARTING_PROMPT.md
# DML Hub — MVP Project Kickoff Prompt
# Company: DML Labs | GLM-5 Optimized | RISEN + CO-STAR + CoT Frameworks
# Use: ONCE — at the very start of the project to scaffold the entire MVP
# Attach: SYSTEM_PROMPT.md + core-SKILLS.md + hub-SKILLS.md + todo-SKILLS.md

---

<!--
═══════════════════════════════════════════════════════════
PROMPTING FRAMEWORKS APPLIED IN THIS FILE:

1. CO-STAR  → Context · Objective · Style · Tone · Audience · Response
2. RISEN    → Role · Instructions · Steps · End-goal · Narrowing
3. CoT      → Chain-of-Thought: explicit reasoning before each layer
4. Few-Shot → Reference patterns from SKILLS.md files
5. XML Tags → Clear parse boundaries for GLM-5 instruction-following
6. Negative → Explicit DO NOT rules at each step
═══════════════════════════════════════════════════════════
-->

<prompt>

<co_star>
  <context>
    You are building DML Hub from absolute zero — no files exist yet.
    DML Hub is a personal productivity platform by DML Labs.
    It is Android-only. It starts with a single built-in plugin: To-Do List.
    The architecture is Feature-First Clean Architecture.
    All patterns, rules, and code conventions are defined in the attached SKILLS.md files.
    You have read and internalized all 4 attached files before starting.
  </context>

  <objective>
    Scaffold the complete DML Hub MVP project — every file, every layer, in the
    correct dependency order — so the app compiles, runs on Android,
    shows the Hub Home screen with a To-Do plugin card, and the To-Do plugin
    is fully functional (create, complete, delete tasks, today/all/projects views).
  </objective>

  <style>
    Production-grade. Zero placeholders. Zero TODOs.
    Every file is complete, typed, documented, and follows the patterns
    in the attached SKILLS.md files exactly.
  </style>

  <tone>
    Precise. Systematic. Senior engineer executing a known plan.
    No improvisation. No shortcuts. No deviations from the SKILLS.md patterns.
  </tone>

  <audience>
    This code is for a solo developer (DML Labs founder) who will
    use this as their personal productivity platform.
    Production quality from day one, even for personal use.
  </audience>

  <response_format>
    Output one file at a time.
    Before each file: state the filename + one-line reason for its position in the order.
    After each file: state what to run next (if build_runner needed) or confirm ready.
    Wait for explicit "NEXT" or "CONTINUE" before generating the next file.
  </response_format>
</co_star>

---

<risen>
  <role>
    You are the Elite Principal Flutter Engineer for DML Labs.
    You are GLM-5 — the sole AI builder of this entire codebase.
    You follow every rule in SYSTEM_PROMPT.md without exception.
    You implement every pattern from the attached SKILLS.md files exactly.
  </role>

  <instructions>
    Build the DML Hub MVP by following the EXECUTION STEPS below.
    Execute steps in STRICT ORDER — never skip, never reorder.
    Before writing any file, state which SKILL pattern you are implementing.
    After writing each file, confirm the output contract
    (what this file provides to the next file in the dependency chain).
  </instructions>

  <end_goal>
    A fully functional Android app where:
    1. App launches → DML Hub Home shows To-Do plugin card with live task count
    2. Tap To-Do card → Full-screen push to To-Do plugin
    3. Today tab: shows due today + overdue + pinned tasks
    4. Tasks tab: shows all tasks with filter/sort
    5. Projects tab: shows projects with task lists
    6. FAB → AddTaskSheet: create task with title, priority, due date, project, tags
    7. Checkbox tap → animated completion (scale + strikethrough + fade)
    8. Settings icon → Hub Settings (theme toggle, biometric lock, about)
    9. Back button → returns to Hub Home (back stack preserved)
    10. App lock → biometric authentication on resume (if enabled)
  </end_goal>

  <narrowing>
    MVP SCOPE BOUNDARIES — NEVER implement these in this session:
    ❌ iOS / macOS / Windows / Linux / Web support
    ❌ Supabase sync or any network calls
    ❌ AI features or ML models
    ❌ Melos monorepo setup
    ❌ BLoC (Riverpod only)
    ❌ Golden tests or integration tests (unit tests for domain only)
    ❌ Isar (Drift only)
    ❌ Second plugin (Hub architecture is plugin-ready but only To-Do built now)
    ❌ RevenueCat / monetization
    ❌ Sentry / PostHog / analytics
    ❌ Any package NOT in the approved MVP stack from SYSTEM_PROMPT.md
  </narrowing>
</risen>

---

<execution_steps>

<!--
═══════════════════════════════════════════
CHAIN-OF-THOUGHT EXECUTION PLAN
Before starting each phase, reason through:
  → What does this phase depend on?
  → What does the next phase depend on from this phase?
  → What SKILLS.md pattern applies here?
═══════════════════════════════════════════
-->

## ━━━ PHASE 0: PROJECT SETUP ━━━━━━━━━━━━━━━━━━━━━━━━━━

<step number="0.1">
  <title>Flutter Project Init</title>
  <action>
    Create Flutter project with exact configuration:
    - Name: dml_hub
    - Package: com.dmllabs.hub
    - Platforms: android ONLY (--platforms=android)
    - Org: com.dmllabs
  </action>
  <command>
    flutter create --org com.dmllabs --platforms=android dml_hub
  </command>
  <verify>pubspec.yaml shows com.dmllabs.hub · Android only</verify>
</step>

<step number="0.2">
  <title>pubspec.yaml — Add ALL MVP Dependencies</title>
  <action>
    Replace the generated pubspec.yaml with the complete dependency set.
    Use EXACT versions from SYSTEM_PROMPT.md stack.
    Add ALL dependencies in one shot — never add packages mid-session.
  </action>
  <pubspec_dependencies>
    dependencies:
      flutter:
        sdk: flutter
      flutter_localizations:
        sdk: flutter

      # State Management
      flutter_riverpod: ^2.5.1
      riverpod_annotation: ^2.3.5

      # Navigation
      go_router: ^14.2.7

      # Database
      drift: ^2.18.0
      drift_flutter: ^0.2.1
      sqlite3_flutter_libs: ^0.5.24

      # Data Classes
      freezed_annotation: ^2.4.4
      json_annotation: ^4.9.0

      # Error Handling
      dartz: ^0.10.1

      # UI & Animation
      flutter_animate: ^4.5.0
      google_fonts: ^6.2.1

      # Notifications
      flutter_local_notifications: ^17.2.2

      # Security
      flutter_secure_storage: ^9.2.2
      local_auth: ^2.2.0

      # Logging
      talker_flutter: ^4.4.1
      talker_riverpod_logger: ^4.4.1

      # Utilities
      intl: ^0.19.0
      uuid: ^4.4.0
      get_it: ^7.7.0

    dev_dependencies:
      flutter_test:
        sdk: flutter
      build_runner: ^2.4.11
      riverpod_generator: ^2.4.3
      drift_dev: ^2.18.0
      freezed: ^2.5.2
      json_serializable: ^6.8.0
      flutter_lints: ^4.0.0
  </pubspec_dependencies>
  <verify>flutter pub get runs with zero errors</verify>
</step>

<step number="0.3">
  <title>analysis_options.yaml — Strict Linting</title>
  <action>
    Configure strict linting. Enforce all patterns from SYSTEM_PROMPT.md.
    Add rules that prevent forbidden patterns.
  </action>
  <content>
    include: package:flutter_lints/flutter.yaml
    linter:
      rules:
        - always_use_package_imports
        - avoid_dynamic_calls
        - avoid_print                    # ALWAYS use talker
        - avoid_void_async
        - cancel_subscriptions
        - close_sinks
        - directives_ordering
        - prefer_const_constructors
        - prefer_const_declarations
        - prefer_final_fields
        - prefer_final_locals
        - require_trailing_commas
        - sort_constructors_first
        - unawaited_futures
        - use_super_parameters
  </content>
  <verify>No lint errors on empty main.dart</verify>
</step>

<step number="0.4">
  <title>AndroidManifest.xml — Required Permissions</title>
  <action>
    Add ONLY the permissions required by MVP features.
    No internet permission (local-only app).
  </action>
  <permissions>
    &lt;!-- Biometric authentication --&gt;
    &lt;uses-permission android:name="android.permission.USE_BIOMETRIC" /&gt;
    &lt;uses-permission android:name="android.permission.USE_FINGERPRINT" /&gt;

    &lt;!-- Local notifications (Android 13+) --&gt;
    &lt;uses-permission android:name="android.permission.POST_NOTIFICATIONS" /&gt;
    &lt;uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" /&gt;
    &lt;uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" /&gt;

    &lt;!-- Vibration for notification --&gt;
    &lt;uses-permission android:name="android.permission.VIBRATE" /&gt;

    &lt;!-- NO INTERNET PERMISSION — local-only app --&gt;
  </permissions>
  <verify>No internet permission in manifest</verify>
</step>

## ━━━ PHASE 1: CORE LAYER ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

<!--
CoT Reasoning for Phase 1:
Core layer has zero dependencies on features.
Everything else depends on core.
Generate core completely before touching any feature.
Order within core: errors → constants → theme → utils → router → DI
-->

<step number="1.1">
  <title>lib/core/error/failures.dart + exceptions.dart</title>
  <skill_reference>core-SKILLS.md → SKILL 1 (Failures pattern)</skill_reference>
  <action>
    Generate exact failures.dart with sealed class + all typed failures.
    Generate exceptions.dart with matching typed exceptions.
    Failures: DatabaseFailure · ValidationFailure · AuthFailure ·
              NotificationFailure · UnexpectedFailure
  </action>
</step>

<step number="1.2">
  <title>lib/core/usecases/usecase.dart</title>
  <skill_reference>core-SKILLS.md → SKILL 3 (UseCase base)</skill_reference>
  <action>
    Generate UseCase&lt;Type, Params&gt; · UseCaseNoParams&lt;Type&gt; · NoParams
    These are the base classes ALL use cases will extend.
  </action>
</step>

<step number="1.3">
  <title>lib/core/constants/app_routes.dart + app_constants.dart + app_spacing.dart</title>
  <skill_reference>core-SKILLS.md → SKILL 4 (AppRoutes) + SKILL 5 (AppSpacing)</skill_reference>
  <action>
    app_routes.dart: ALL route string constants (hub + todo + future stubs commented)
    app_constants.dart: App name, version, company name constants
    app_spacing.dart: 4dp grid spacing constants, border radius, page/card padding
    NEVER hardcode route strings or spacing values outside these files.
  </action>
</step>

<step number="1.4">
  <title>lib/core/theme/ — AppColors + AppTextStyles + AppTheme</title>
  <skill_reference>core-SKILLS.md → SKILL 5 (Theme System)</skill_reference>
  <action>
    app_colors.dart: ALL color tokens (brand + surface + content + semantic + priority)
    app_text_styles.dart: NunitoSans text style presets (heading, body, caption, label)
    app_theme.dart: ThemeData dark + light with ColorScheme, CardTheme, NavigationBarTheme
    Use google_fonts NunitoSans throughout.
    Dark theme uses deep navy surface (#0A1628). Primary = DML Blue (#4A90D9).
  </action>
</step>

<step number="1.5">
  <title>lib/core/utils/logger.dart</title>
  <skill_reference>core-SKILLS.md → SKILL 6 (Logging)</skill_reference>
  <action>
    Single talker logger singleton.
    kDebugMode: full logs. Release: errors + critical only.
    Export `logger` as top-level variable for global import.
  </action>
</step>

<step number="1.6">
  <title>lib/core/extensions/ — context, string, datetime extensions</title>
  <action>
    context_extensions.dart:
      - theme, colorScheme, textTheme shortcuts
      - isDarkMode getter
      - showSnackBar helper
    datetime_extensions.dart:
      - isToday, isOverdue, isTomorrow getters
      - toFormattedDate(), toRelativeLabel() methods
    string_extensions.dart:
      - capitalize, isNullOrEmpty helpers
  </action>
</step>

<step number="1.7">
  <title>lib/core/widgets/ — AppLoadingWidget + AppErrorWidget + AppEmptyWidget + AsyncValueWidget</title>
  <skill_reference>core-SKILLS.md → SKILL 9 (Shared Widgets)</skill_reference>
  <action>
    AppLoadingWidget: centered CircularProgressIndicator with DML Blue color
    AppErrorWidget: icon + message + optional retry callback
    AppEmptyWidget: icon + title + subtitle (configurable per use case)
    AsyncValueWidget&lt;T&gt;: generic when() handler (loading/error/data)
    ALL must use const constructors. ALL themed via Material 3 tokens.
  </action>
</step>

<step number="1.8">
  <title>lib/core/router/app_router.dart</title>
  <skill_reference>core-SKILLS.md → SKILL 4 (go_router pattern)</skill_reference>
  <action>
    Full GoRouter instance with:
    - initialLocation: AppRoutes.hub
    - Hub home route: /hub → HubHomePage
    - Hub settings route: /hub/settings → HubSettingsPage
    - Todo ShellRoute: /hub/todo → TodoShell wrapping child
    - Todo sub-routes: today · tasks · projects · settings
    - redirect: /hub/todo → /hub/todo/today
    - debugLogDiagnostics: kDebugMode
    DO NOT reference Hub/Todo page classes yet — use placeholder imports
    (they will be filled in when pages are generated in Phase 2 + 3).
  </action>
</step>

<step number="1.9">
  <title>lib/core/di/injection_container.dart</title>
  <skill_reference>core-SKILLS.md → SKILL 2 (DI Pattern)</skill_reference>
  <action>
    Full initializeDependencies() function.
    Registration order: AppDatabase → DAOs → Repositories → UseCases → Services
    Include ALL use cases and services for the To-Do plugin.
    Use registerSingleton for DB/DAOs/Repos/Services.
    Use registerFactory for UseCases.
    Export getIt instance for provider access.
    NOTE: DAOs, Repositories, and Services referenced here will be created
    in Phase 2 and 3 — import paths must match those upcoming files exactly.
  </action>
</step>

## ━━━ PHASE 2: DATA LAYER ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

<!--
CoT Reasoning for Phase 2:
Data layer depends only on: core/error + core/utils.
Domain layer depends on data layer interfaces (NOT implementation).
Generate: Tables → Database → DAOs → DataSource → Repository Impl
-->

<step number="2.1">
  <title>lib/features/todo/data/database/tables/ — All 5 table files</title>
  <skill_reference>todo-SKILLS.md → SKILL 1 (Drift Schema)</skill_reference>
  <action>
    Generate in order:
    1. projects_table.dart (no FK dependencies)
    2. tags_table.dart (no FK dependencies)
    3. tasks_table.dart (FK → projects)
    4. subtasks_table.dart (FK → tasks, cascade delete)
    5. task_tags_table.dart (FK → tasks + tags, cascade delete, composite PK)

    ALL PKs are TextColumn (UUID). Enums stored as name strings.
    Add @DataClassName annotation to each table for clean generated class names.
  </action>
</step>

<step number="2.2">
  <title>lib/features/todo/data/database/daos/ — All 5 DAO files</title>
  <skill_reference>todo-SKILLS.md → SKILL 2 (DAO Patterns)</skill_reference>
  <action>
    Generate in order:
    1. project_dao.dart — watchActiveProjects, insert, update, delete
    2. tag_dao.dart — watchAllTags, insert, delete
    3. task_tag_dao.dart — insertTaskTag, deleteTaskTags, watchTagsForTask
    4. subtask_dao.dart — watchSubtasksForTask, insert, update, delete, toggleDone
    5. task_dao.dart — watchTodayTasks, watchAllTasks, watchTodayTaskCount,
                       insertTask, updateTask, completeTask, cancelTask,
                       deleteTask, togglePin

    ALL list queries return Stream&lt;&gt; (reactive, NOT Future).
    Single-item queries return Future&lt;&gt;.
    Use @DriftAccessor(tables: [...]) on each DAO.
  </action>
</step>

<step number="2.3">
  <title>lib/features/todo/data/database/app_database.dart</title>
  <skill_reference>todo-SKILLS.md → SKILL 1 (AppDatabase pattern)</skill_reference>
  <action>
    @DriftDatabase with ALL 5 tables + ALL 5 DAOs.
    schemaVersion: 1
    MigrationStrategy: onCreate createAll, beforeOpen enable FK pragma.
    _openConnection() using driftDatabase(name: 'dml_hub_db').
    Log schema open/migration via logger.
  </action>
  <post_action>
    RUN: dart run build_runner build --delete-conflicting-outputs
    This generates: app_database.g.dart + all DAO mixin files.
    VERIFY: no build errors before continuing.
  </post_action>
</step>

<step number="2.4">
  <title>lib/features/todo/domain/entities/ — All 4 entity files</title>
  <skill_reference>todo-SKILLS.md → SKILL 7 + core-SKILLS.md SKILL 7 (freezed entities)</skill_reference>
  <action>
    Generate in order (no circular dependencies):
    1. tag.dart — @freezed Tag entity (id, name, color, createdAt)
    2. project.dart — @freezed Project entity (id, name, description, color, icon, isArchived, dates)
    3. subtask.dart — @freezed Subtask entity (id, taskId, title, isDone, sortOrder, createdAt)
    4. task.dart — @freezed Task entity (all fields from SKILLS.md)
       Include: TaskPriority enum · TaskStatus enum · RecurrenceRule enum

    Entities have NO json serialization (domain layer is pure Dart).
    All enums defined in task.dart (they are domain concepts).
  </action>
  <post_action>
    RUN: dart run build_runner build --delete-conflicting-outputs
    Generates: *.freezed.dart files for all entities.
  </post_action>
</step>

<step number="2.5">
  <title>lib/features/todo/domain/repositories/task_repository.dart</title>
  <skill_reference>todo-SKILLS.md → SKILL 3 (Repository Contract)</skill_reference>
  <action>
    Abstract class TaskRepository with ALL method signatures.
    Grouped: Tasks · Projects · Tags sections.
    Every method returns Either&lt;Failure, R&gt; or Stream&lt;Either&lt;Failure, R&gt;&gt;.
    Import ONLY from: core/error + domain/entities. Never import data layer.
  </action>
</step>

<step number="2.6">
  <title>lib/features/todo/data/repositories/task_repository_impl.dart</title>
  <skill_reference>todo-SKILLS.md → SKILL 3 (Repository Implementation)</skill_reference>
  <action>
    Implements TaskRepository.
    Constructor injects: TaskDao · ProjectDao · TagDao · TaskTagDao · SubtaskDao.
    ALL methods wrapped in try/catch → DatabaseFailure or UnexpectedFailure.
    ALL stream methods use .map() + .handleError() — never throw from stream.
    Private _mapRowToTask(), _mapRowToProject(), _mapRowToTag() mappers.
    Log every mutation (create/update/delete/complete) at info level.
    Log every error at error level with stackTrace.
  </action>
</step>

## ━━━ PHASE 3: DOMAIN LAYER — USE CASES ━━━━━━━━━━━━━━━━━

<!--
CoT Reasoning for Phase 3:
Use cases depend on: domain entities + repository abstract + core/usecases.
They NEVER import data layer.
Generate all use cases before presentation layer.
-->

<step number="3.1">
  <title>lib/features/todo/domain/usecases/task/ — 7 task use cases</title>
  <skill_reference>core-SKILLS.md → SKILL 3 + todo-SKILLS.md → SKILL 4</skill_reference>
  <action>
    Generate in order:
    1. create_task_usecase.dart (+ CreateTaskParams @freezed)
       → Validate title non-empty, max 500 chars
       → Generate UUID id, set createdAt/updatedAt
       → Schedule notification if dueDate present
    2. update_task_usecase.dart (+ UpdateTaskParams @freezed)
       → Validate title non-empty
       → Update updatedAt timestamp
       → Reschedule notification if dueDate changed
    3. complete_task_usecase.dart (+ CompleteTaskParams @freezed)
       → Mark done → cancel notification → spawn recurrence if recurring
    4. delete_task_usecase.dart (+ DeleteTaskParams @freezed)
       → Cancel notification → hard delete
    5. pin_task_usecase.dart (+ PinTaskParams @freezed)
       → Toggle pin state
    6. get_today_tasks_usecase.dart
       → UseCaseNoParams → returns Stream from repository
    7. get_all_tasks_usecase.dart (+ GetAllTasksParams @freezed)
       → Accepts optional filter params → returns Stream

    ALL extend UseCase&lt;T, P&gt; or UseCaseNoParams&lt;T&gt;.
    ALL validate input before calling repository.
    Domain validation in use case — NEVER in repository.
  </action>
</step>

<step number="3.2">
  <title>lib/features/todo/domain/usecases/project/ — 4 project use cases</title>
  <action>
    1. create_project_usecase.dart — validate name, generate UUID
    2. update_project_usecase.dart — validate name, update timestamp
    3. delete_project_usecase.dart — tasks in project set to no project (via DB FK setNull)
    4. get_projects_usecase.dart — UseCaseNoParams → Stream of active projects
  </action>
</step>

<step number="3.3">
  <title>lib/features/todo/domain/usecases/tag/ — 2 tag use cases</title>
  <action>
    1. create_tag_usecase.dart — validate name max 50 chars, generate UUID
    2. get_tags_usecase.dart — UseCaseNoParams → Stream of all tags
  </action>
</step>

## ━━━ PHASE 4: SERVICES LAYER ━━━━━━━━━━━━━━━━━━━━━━━━━━━

<step number="4.1">
  <title>lib/features/hub/domain/ — BiometricService abstract + HubRepository</title>
  <skill_reference>hub-SKILLS.md → SKILL 4 (BiometricService)</skill_reference>
  <action>
    biometric_service.dart: abstract BiometricService interface
    (isAvailable, isLockEnabled, setLockEnabled, authenticate)
  </action>
</step>

<step number="4.2">
  <title>lib/features/hub/data/ — BiometricServiceImpl + NotificationServiceImpl</title>
  <skill_reference>hub-SKILLS.md → SKILL 4 + todo-SKILLS.md → SKILL 9</skill_reference>
  <action>
    biometric_service_impl.dart: implements BiometricService
    (local_auth + flutter_secure_storage)
    notification_service_impl.dart: implements NotificationService
    (flutter_local_notifications, todo channel, scheduleTaskNotification, cancel)
  </action>
</step>

## ━━━ PHASE 5: PRESENTATION LAYER — PROVIDERS ━━━━━━━━━━━

<!--
CoT Reasoning for Phase 5:
Providers are the bridge between domain and UI.
Generate ALL providers before ANY screen/widget.
Providers import: use cases (via get_it) + domain entities + core error.
NEVER import widgets from providers.
-->

<step number="5.1">
  <title>lib/features/hub/presentation/providers/hub_providers.dart</title>
  <skill_reference>hub-SKILLS.md → SKILL 6 (Hub Providers)</skill_reference>
  <action>
    installedPlugins provider: returns List&lt;PluginInfo&gt; with live quickStatLabel
    ThemeModeState notifier: persists in flutter_secure_storage
    biometricAvailable provider: checks local_auth isAvailable
    biometricLockEnabled provider: reads from secure storage
    AppLockState notifier: locked/unlocked state
    authenticateWithBiometric provider: triggers auth flow
  </action>
  <post_action>
    RUN: dart run build_runner build --delete-conflicting-outputs
  </post_action>
</step>

<step number="5.2">
  <title>lib/features/todo/presentation/providers/task_providers.dart</title>
  <skill_reference>todo-SKILLS.md → SKILL 5 (Riverpod Providers)</skill_reference>
  <action>
    taskRepository provider (reads get_it)
    todayTasks stream provider
    todayTaskCount stream provider (int — for Hub quick stat)
    allTasks stream provider (watches TaskFilterState)
    TaskFilter notifier (setProject, setPriority, setStatus, reset)
    TaskFilterState @freezed class + TaskSortBy enum
    createTask provider (action — invalidates lists on success)
    completeTask provider (action — invalidates lists + cancels notification)
    deleteTask provider (action)
    updateTask provider (action)
    pinTask provider (action)
    TaskActionError notifier (String? error state)
  </action>
</step>

<step number="5.3">
  <title>lib/features/todo/presentation/providers/project_providers.dart + tag_providers.dart</title>
  <action>
    project_providers.dart:
      activeProjects stream provider
      createProject, updateProject, deleteProject action providers
    tag_providers.dart:
      allTags stream provider
      createTag action provider
  </action>
  <post_action>
    RUN: dart run build_runner build --delete-conflicting-outputs
    VERIFY: all .g.dart files generated without errors.
  </post_action>
</step>

## ━━━ PHASE 6: PRESENTATION LAYER — HUB SCREENS ━━━━━━━━━

<step number="6.1">
  <title>lib/features/hub/domain/entities/plugin_info.dart</title>
  <skill_reference>hub-SKILLS.md → SKILL 1 (PluginInfo + BuiltInPlugins)</skill_reference>
  <action>
    PluginInfo @freezed entity.
    BuiltInPlugins abstract class with static todo() factory.
    Future plugin stubs commented out (habits, journal, notes, goals, focus).
  </action>
</step>

<step number="6.2">
  <title>lib/features/hub/presentation/widgets/ — HubAppBar + PluginCard</title>
  <skill_reference>hub-SKILLS.md → SKILL 2 + SKILL 3</skill_reference>
  <action>
    hub_app_bar.dart: "DML Hub" branding (DML=bold blue, Hub=regular), settings IconButton
    plugin_card.dart: Hero-tagged, InkWell → context.push(plugin.route),
                      icon container + name + quickStatLabel
                      DML Blue border, surfaceCard background, 12dp radius
  </action>
</step>

<step number="6.3">
  <title>lib/features/hub/presentation/screens/hub_home_page.dart</title>
  <skill_reference>hub-SKILLS.md → SKILL 2 (Hub Home Screen)</skill_reference>
  <action>
    ConsumerWidget. Reads installedPlugins provider.
    GridView 2-column. Staggered flutter_animate entrance (80ms delay per card).
    AsyncValueWidget for loading/error/data states.
    Padding: AppSpacing.pagePadding.
  </action>
</step>

<step number="6.4">
  <title>lib/features/hub/presentation/screens/biometric_lock_page.dart</title>
  <skill_reference>hub-SKILLS.md → SKILL 4 (BiometricLockPage)</skill_reference>
  <action>
    ConsumerStatefulWidget with WidgetsBindingObserver.
    Auto-authenticate on initState + app resume.
    Lock icon + DML Hub title + Unlock button.
    flutter_animate: scale + fadeIn entrance.
  </action>
</step>

<step number="6.5">
  <title>lib/features/hub/presentation/screens/hub_settings_page.dart</title>
  <skill_reference>hub-SKILLS.md → SKILL 5 (Hub Settings)</skill_reference>
  <action>
    3 sections: Appearance (theme toggle) · Security (biometric toggle) · About.
    Theme toggle: System / Light / Dark (SegmentedButton).
    Biometric toggle: SwitchListTile (only shown if biometric available).
    About: App version, DML Labs credit.
    Settings persisted via ThemeModeState provider + BiometricService.
  </action>
</step>

## ━━━ PHASE 7: PRESENTATION LAYER — TODO SCREENS ━━━━━━━━

<step number="7.1">
  <title>lib/features/todo/presentation/widgets/ — All 7 widgets</title>
  <skill_reference>todo-SKILLS.md → SKILL 8, 11 (TaskCard, TaskCheckbox, PriorityBadge)</skill_reference>
  <action>
    Generate in order:
    1. priority_badge.dart — color-coded chip, switch on priority
    2. task_checkbox.dart — AnimatedContainer + flutter_animate scale pulse
    3. task_card.dart — Dismissible wrapper + animated completion + PriorityBadge
    4. subtask_item.dart — checkbox + strikethrough title + sort order
    5. project_chip.dart — colored chip showing project name
    6. task_filter_bar.dart — horizontal scroll of filter chips (priority/status/project)
    7. add_task_sheet.dart — ModalBottomSheet:
         title field (required) · priority selector · due date picker ·
         project dropdown · tag multi-select · submit button
         Uses createTask provider on submit.
         Validates: title not empty before submit.
         Closes sheet on success.
  </action>
</step>

<step number="7.2">
  <title>lib/features/todo/presentation/screens/todo_shell.dart</title>
  <skill_reference>todo-SKILLS.md → SKILL 6 (TodoShell)</skill_reference>
  <action>
    ShellRoute wrapper widget.
    AppBar: back arrow (context.pop to Hub) + dynamic title + settings icon.
    NavigationBar: Today · Tasks · Projects (3 destinations).
    FAB: "Add Task" → showModalBottomSheet AddTaskSheet.
    _locationToIndex: maps current URI to selected tab index.
    context.go() on tab selection (not push — tabs replace, not stack).
  </action>
</step>

<step number="7.3">
  <title>lib/features/todo/presentation/screens/today/todo_today_page.dart</title>
  <skill_reference>todo-SKILLS.md → SKILL 7 (Today Screen)</skill_reference>
  <action>
    ConsumerWidget. Reads todayTasksProvider (stream).
    Separates: overdue tasks (red section header) + today tasks (blue section header).
    ListView with staggered flutter_animate fadeIn per item (50ms delay).
    RefreshIndicator: invalidates todayTasksProvider.
    Empty state: AppEmptyWidget("All clear today ✓", motivational subtitle).
  </action>
</step>

<step number="7.4">
  <title>lib/features/todo/presentation/screens/tasks/todo_all_tasks_page.dart</title>
  <action>
    ConsumerWidget. Reads allTasksProvider (filtered stream) + taskFilterProvider.
    TaskFilterBar at top (sticky).
    ListView of TaskCards.
    Empty state when no tasks match filter.
    Snackbar undo on swipe-to-dismiss (Dismissible with DismissDirection.endToStart).
  </action>
</step>

<step number="7.5">
  <title>lib/features/todo/presentation/screens/tasks/todo_task_detail_page.dart</title>
  <action>
    Full task detail: title (editable) · description · priority selector ·
    status selector · due date picker · project selector ·
    tags selector · subtask list (add/check/delete subtasks) ·
    recurrence selector · delete button.
    Uses updateTask provider. Uses Subtask providers for subtask CRUD.
    AppBar with save button + delete IconButton.
  </action>
</step>

<step number="7.6">
  <title>lib/features/todo/presentation/screens/projects/todo_projects_page.dart</title>
  <action>
    List of active projects. Each project card shows task count.
    FAB: create new project (name + color picker).
    Tap project → todo_project_detail_page.
  </action>
</step>

<step number="7.7">
  <title>lib/features/todo/presentation/screens/projects/todo_project_detail_page.dart</title>
  <action>
    Shows all tasks for selected project (filtered allTasksProvider).
    AppBar: project name + edit icon + archive icon.
    Same TaskCard list as AllTasks screen.
    Edit bottom sheet: change project name + color.
  </action>
</step>

<step number="7.8">
  <title>lib/features/todo/presentation/screens/settings/todo_settings_page.dart</title>
  <action>
    Plugin-level settings:
    - Default priority (None/Low/Medium/High)
    - Default notification time offset (15min/30min/1hr before due)
    - Show completed tasks toggle
    - Clear completed tasks (destructive action with confirmation dialog)
    Persisted in flutter_secure_storage with todo_ prefix keys.
  </action>
</step>

## ━━━ PHASE 8: UNIT TESTS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

<step number="8.1">
  <title>test/features/todo/domain/usecases/ — Unit tests for ALL use cases</title>
  <skill_reference>SYSTEM_PROMPT.md → Testing: Unit tests for domain only</skill_reference>
  <action>
    Generate test files for:
    1. create_task_usecase_test.dart
       - Should return ValidationFailure when title is empty
       - Should return ValidationFailure when title exceeds 500 chars
       - Should return Right(Task) on valid input
       - Should set createdAt and updatedAt to now
    2. complete_task_usecase_test.dart
       - Should return Right(unit) on success
       - Should spawn recurrence when task is recurring with dueDate
       - Should NOT spawn recurrence when task is not recurring
       - Should cancel notification on complete
    3. delete_task_usecase_test.dart
       - Should cancel notification before deleting
       - Should return DatabaseFailure when repository fails

    Use mockito or mocktail for repository mocks.
    ALL tests follow Arrange-Act-Assert pattern.
    Group related tests with group() blocks.
  </action>
</step>

## ━━━ PHASE 9: ENTRY POINT ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

<step number="9.1">
  <title>lib/main.dart — Final Bootstrap</title>
  <skill_reference>core-SKILLS.md → SKILL 10 (main.dart Bootstrap)</skill_reference>
  <action>
    Bootstrap order:
    1. WidgetsFlutterBinding.ensureInitialized()
    2. logger.info('DML Hub: Starting bootstrap')
    3. await initializeDependencies()
    4. await getIt&lt;NotificationService&gt;().initialize()
    5. Request notification permission (Android 13+)
    6. runApp(ProviderScope(...))

    DmlHubApp widget:
    - MaterialApp.router with appRouter
    - darkTheme: AppTheme.dark · theme: AppTheme.light
    - themeMode: ref.watch(themeModeStateProvider)
    - localizationsDelegates + supportedLocales
    - title: 'DML Hub'
    - debugShowCheckedModeBanner: false

    Wrap with Consumer to read ThemeModeState for dynamic theme switching.
    Check biometric lock on app start (if enabled → show BiometricLockPage).
  </action>
</step>

</execution_steps>

---

<final_verification_checklist>
## BEFORE MARKING MVP COMPLETE — VERIFY ALL:

### Architecture
- [ ] Every feature folder has data/ domain/ presentation/ structure
- [ ] Zero direct DAO calls from providers (ALWAYS through repository)
- [ ] Zero business logic in widgets or providers
- [ ] Every repository method returns Either&lt;Failure, R&gt;
- [ ] Every use case extends UseCase&lt;T, P&gt; or UseCaseNoParams&lt;T&gt;
- [ ] Every provider uses @riverpod annotation

### Navigation
- [ ] All route strings use AppRoutes constants (zero inline strings)
- [ ] Hub → Todo: context.push() (preserves back stack)
- [ ] Todo tabs: context.go() (replaces, no stack)
- [ ] Back in Todo: context.pop() returns to Hub Home
- [ ] /hub/todo redirects to /hub/todo/today

### Data
- [ ] Single AppDatabase with all 5 tables registered
- [ ] All PKs are UUID strings (no auto-increment int PKs)
- [ ] Foreign keys: cascade delete on subtasks + task_tags
- [ ] PRAGMA foreign_keys = ON in beforeOpen migration
- [ ] All list queries return Stream (reactive UI)

### UI
- [ ] Zero hardcoded colors (all from AppColors or colorScheme)
- [ ] Zero hardcoded spacing (all from AppSpacing)
- [ ] Zero hardcoded text styles (all from theme or AppTextStyles)
- [ ] Dark theme works correctly on fresh install
- [ ] Task completion: checkbox animate → strikethrough → fade out
- [ ] Hub Home: staggered plugin card entrance animation

### Quality
- [ ] Zero print() statements (all talker)
- [ ] Zero TODOs in codebase
- [ ] Zero dynamic types
- [ ] All public classes/methods have /// doc comments
- [ ] flutter analyze returns zero errors, zero warnings
- [ ] All unit tests pass
</final_verification_checklist>

---

<start_command>
  To begin: Generate files in STRICT PHASE ORDER starting with STEP 0.1.
  Output ONE file at a time. Wait for "NEXT" / "CONTINUE" between files.
  State the SKILLS.md pattern reference before each file.
  State the output contract after each file.
  DO NOT skip any step. DO NOT reorder steps.
  DO NOT add any package not in SYSTEM_PROMPT.md approved stack.
  BEGIN NOW WITH STEP 0.1.
</start_command>

</prompt>

---

# END OF MAIN_STARTING_PROMPT.md
# Attach with: SYSTEM_PROMPT.md + core-SKILLS.md + hub-SKILLS.md + todo-SKILLS.md
# Use: ONCE — at project start. Never reuse mid-project.
# For mid-project tasks: use SYSTEM_PROMPT.md + relevant SKILLS.md only.
