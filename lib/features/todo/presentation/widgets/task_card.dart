import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dml_hub/features/todo/domain/entities/task.dart';
import 'package:dml_hub/features/todo/presentation/providers/task_providers.dart';
import 'package:dml_hub/features/todo/presentation/widgets/priority_badge.dart';
import 'package:dml_hub/features/todo/presentation/widgets/project_chip.dart';
import 'package:dml_hub/features/todo/presentation/widgets/task_checkbox.dart';

class TaskCard extends ConsumerWidget {
  const TaskCard({required this.task, super.key});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: TaskCheckbox(
          value: task.isCompleted,
          onChanged: (_) => ref.read(taskActionsProvider).toggleTaskCompletion(task.id),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ).animate(target: task.isCompleted ? 1 : 0).fade(end: 0.55),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                PriorityBadge(priority: task.priority),
                if (task.projectName != null) ProjectChip(projectName: task.projectName!),
                if (task.isPinned) const Chip(label: Text('Pinned')),
                if (task.isOverdue) const Chip(label: Text('Overdue')),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: () => ref.read(taskActionsProvider).deleteTask(task.id),
          icon: const Icon(Icons.delete_outline),
        ),
      ),
    );
  }
}
