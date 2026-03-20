import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dml_hub/core/constants/app_routes.dart';
import 'package:dml_hub/core/widgets/app_empty_widget.dart';
import 'package:dml_hub/core/widgets/app_error_widget.dart';
import 'package:dml_hub/core/widgets/app_loading_widget.dart';
import 'package:dml_hub/features/todo/presentation/providers/task_providers.dart';
import 'package:dml_hub/features/todo/presentation/widgets/add_task_sheet.dart';
import 'package:dml_hub/features/todo/presentation/widgets/task_card.dart';

class TodoTodayPage extends ConsumerWidget {
  const TodoTodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(todayTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.todoTasks),
            icon: const Icon(Icons.list_alt_outlined),
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.todoProjects),
            icon: const Icon(Icons.folder_outlined),
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.todoSettings),
            icon: const Icon(Icons.tune_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (context) => const AddTaskSheet(),
        ),
        child: const Icon(Icons.add),
      ),
      body: tasks.when(
        loading: AppLoadingWidget.new,
        error: (error, _) => AppErrorWidget(message: error.toString()),
        data: (items) {
          if (items.isEmpty) {
            return const AppEmptyWidget(message: 'Nothing urgent right now.');
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => TaskCard(task: items[index]),
          );
        },
      ),
    );
  }
}
