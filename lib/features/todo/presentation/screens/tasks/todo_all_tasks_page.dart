import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dml_hub/core/widgets/app_empty_widget.dart';
import 'package:dml_hub/core/widgets/app_error_widget.dart';
import 'package:dml_hub/core/widgets/app_loading_widget.dart';
import 'package:dml_hub/features/todo/presentation/providers/task_providers.dart';
import 'package:dml_hub/features/todo/presentation/widgets/task_card.dart';

class TodoAllTasksPage extends ConsumerWidget {
  const TodoAllTasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(allTasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('All Tasks')),
      body: tasks.when(
        loading: AppLoadingWidget.new,
        error: (error, _) => AppErrorWidget(message: error.toString()),
        data: (items) {
          if (items.isEmpty) {
            return const AppEmptyWidget(message: 'Add your first task to get started.');
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
