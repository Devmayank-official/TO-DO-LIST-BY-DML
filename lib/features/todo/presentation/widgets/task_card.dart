import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dml_hub/core/theme/app_colors.dart';
import 'package:dml_hub/features/todo/domain/entities/task.dart';
import 'package:dml_hub/features/todo/presentation/providers/task_providers.dart';

class TaskCard extends ConsumerWidget {
  const TaskCard({required this.task, super.key});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => ref.read(taskActionsProvider).toggleTaskCompletion(task.id),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(_subtitle),
        trailing: IconButton(
          onPressed: () => ref.read(taskActionsProvider).deleteTask(task.id),
          icon: const Icon(Icons.delete_outline, color: AppColors.error),
        ),
      ),
    );
  }

  String get _subtitle {
    final labels = <String>[];
    if (task.projectName != null) {
      labels.add(task.projectName!);
    }
    labels.add(task.priority.name);
    if (task.dueDate != null) {
      labels.add('${task.dueDate!.year}-${task.dueDate!.month.toString().padLeft(2, '0')}-${task.dueDate!.day.toString().padLeft(2, '0')}');
    }
    if (task.isPinned) {
      labels.add('Pinned');
    }
    if (task.isOverdue) {
      labels.add('Overdue');
    }
    return labels.join(' • ');
  }
}
