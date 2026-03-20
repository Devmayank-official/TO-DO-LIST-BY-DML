import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dml_hub/features/todo/domain/entities/task.dart';
import 'package:dml_hub/features/todo/presentation/providers/task_filter_providers.dart';

class TaskFilterBar extends ConsumerWidget {
  const TaskFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(taskFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: filter.priority == null,
            onSelected: (_) => ref.read(taskFilterProvider.notifier).reset(),
          ),
          const SizedBox(width: 8),
          ...TaskPriority.values.map(
            (priority) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(priority.name),
                selected: filter.priority == priority,
                onSelected: (_) => ref.read(taskFilterProvider.notifier).setPriority(priority),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
