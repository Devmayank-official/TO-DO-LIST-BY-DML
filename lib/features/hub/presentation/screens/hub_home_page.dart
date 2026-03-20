import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dml_hub/core/constants/app_routes.dart';
import 'package:dml_hub/core/constants/app_spacing.dart';
import 'package:dml_hub/features/hub/presentation/widgets/plugin_card.dart';
import 'package:dml_hub/features/todo/presentation/providers/task_providers.dart';

class HubHomePage extends ConsumerWidget {
  const HubHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTasks = ref.watch(todayTasksProvider);
    final quickStat = todayTasks.when(
      data: (tasks) => '${tasks.length} tasks due today',
      loading: () => 'Loading tasks…',
      error: (_, __) => 'Unable to load stats',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('DML Hub'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.hubSettings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: GridView.count(
        padding: AppSpacing.pagePadding,
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        children: [
          PluginCard(
            title: 'To-Do',
            description: 'Tasks, projects & priorities',
            quickStat: quickStat,
            onTap: () => context.push(AppRoutes.todoToday),
          ),
        ],
      ),
    );
  }
}
