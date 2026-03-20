import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dml_hub/core/constants/app_routes.dart';
import 'package:dml_hub/features/hub/presentation/screens/hub_home_page.dart';
import 'package:dml_hub/features/hub/presentation/screens/hub_settings_page.dart';
import 'package:dml_hub/features/todo/presentation/screens/projects/todo_projects_page.dart';
import 'package:dml_hub/features/todo/presentation/screens/settings/todo_settings_page.dart';
import 'package:dml_hub/features/todo/presentation/screens/tasks/todo_all_tasks_page.dart';
import 'package:dml_hub/features/todo/presentation/screens/today/todo_today_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.hub,
    routes: [
      GoRoute(
        path: AppRoutes.hub,
        builder: (context, state) => const HubHomePage(),
        routes: [
          GoRoute(
            path: 'settings',
            builder: (context, state) => const HubSettingsPage(),
          ),
          GoRoute(
            path: 'todo',
            redirect: (context, state) => AppRoutes.todoToday,
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
  );
});
