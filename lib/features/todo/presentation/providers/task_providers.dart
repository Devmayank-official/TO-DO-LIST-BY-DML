import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dml_hub/core/di/injection_container.dart';
import 'package:dml_hub/features/todo/domain/entities/task.dart';
import 'package:dml_hub/features/todo/domain/usecases/task/create_task_usecase.dart';
import 'package:dml_hub/features/todo/domain/usecases/task/delete_task_usecase.dart';
import 'package:dml_hub/features/todo/domain/usecases/task/get_all_tasks_usecase.dart';
import 'package:dml_hub/features/todo/domain/usecases/task/get_today_tasks_usecase.dart';
import 'package:dml_hub/features/todo/domain/usecases/task/toggle_task_completion_usecase.dart';

final tasksRefreshTriggerProvider = StateProvider<int>((ref) => 0);

final allTasksProvider = FutureProvider<List<Task>>((ref) async {
  ref.watch(tasksRefreshTriggerProvider);
  final result = await getIt<GetAllTasksUseCase>().call();
  return result.fold((failure) => throw Exception(failure.message), (tasks) => tasks);
});

final todayTasksProvider = FutureProvider<List<Task>>((ref) async {
  ref.watch(tasksRefreshTriggerProvider);
  final result = await getIt<GetTodayTasksUseCase>().call();
  return result.fold((failure) => throw Exception(failure.message), (tasks) => tasks);
});

final taskActionsProvider = Provider<TaskActions>((ref) {
  return TaskActions(ref);
});

class TaskActions {
  const TaskActions(this._ref);

  final Ref _ref;

  Future<void> createTask(CreateTaskParams params) async {
    await getIt<CreateTaskUseCase>().call(params);
    _bump();
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    await getIt<ToggleTaskCompletionUseCase>().call(taskId);
    _bump();
  }

  Future<void> deleteTask(String taskId) async {
    await getIt<DeleteTaskUseCase>().call(taskId);
    _bump();
  }

  void _bump() {
    _ref.read(tasksRefreshTriggerProvider.notifier).state++;
  }
}
