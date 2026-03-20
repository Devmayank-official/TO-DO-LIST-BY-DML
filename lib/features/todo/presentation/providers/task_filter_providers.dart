import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dml_hub/features/todo/domain/entities/task.dart';
import 'package:dml_hub/features/todo/presentation/providers/task_providers.dart';

class TaskFilterState {
  const TaskFilterState({this.priority});

  final TaskPriority? priority;

  TaskFilterState copyWith({TaskPriority? priority, bool clearPriority = false}) {
    return TaskFilterState(
      priority: clearPriority ? null : (priority ?? this.priority),
    );
  }
}

class TaskFilterNotifier extends StateNotifier<TaskFilterState> {
  TaskFilterNotifier() : super(const TaskFilterState());

  void setPriority(TaskPriority? priority) {
    state = state.copyWith(priority: priority, clearPriority: priority == null);
  }

  void reset() {
    state = const TaskFilterState();
  }
}

final taskFilterProvider = StateNotifierProvider<TaskFilterNotifier, TaskFilterState>((ref) {
  return TaskFilterNotifier();
});

final filteredAllTasksProvider = FutureProvider<List<Task>>((ref) async {
  final filter = ref.watch(taskFilterProvider);
  final tasks = await ref.watch(allTasksProvider.future);

  if (filter.priority == null) {
    return tasks;
  }

  return tasks.where((task) => task.priority == filter.priority).toList();
});
