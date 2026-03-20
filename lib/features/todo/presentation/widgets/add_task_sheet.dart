import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dml_hub/features/todo/domain/usecases/task/create_task_usecase.dart';
import 'package:dml_hub/features/todo/presentation/providers/task_providers.dart';

class AddTaskSheet extends ConsumerWidget {
  const AddTaskSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add Task', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Task title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                await ref.read(taskActionsProvider).createTask(
                      CreateTaskParams(title: controller.text),
                    );
                if (!context.mounted) {
                  return;
                }
                context.pop();
              },
              child: const Text('Create task'),
            ),
          ),
        ],
      ),
    );
  }
}
