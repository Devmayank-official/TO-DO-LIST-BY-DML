import 'package:get_it/get_it.dart';

import 'package:dml_hub/features/todo/data/repositories/task_repository_impl.dart';
import 'package:dml_hub/features/todo/domain/repositories/task_repository.dart';
import 'package:dml_hub/features/todo/domain/usecases/task/create_task_usecase.dart';
import 'package:dml_hub/features/todo/domain/usecases/task/delete_task_usecase.dart';
import 'package:dml_hub/features/todo/domain/usecases/task/get_all_tasks_usecase.dart';
import 'package:dml_hub/features/todo/domain/usecases/task/get_today_tasks_usecase.dart';
import 'package:dml_hub/features/todo/domain/usecases/task/toggle_task_completion_usecase.dart';

final GetIt getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  if (getIt.isRegistered<TaskRepository>()) {
    return;
  }

  getIt.registerLazySingleton<TaskRepository>(TaskRepositoryImpl.new);
  getIt.registerFactory(() => CreateTaskUseCase(getIt<TaskRepository>()));
  getIt.registerFactory(() => DeleteTaskUseCase(getIt<TaskRepository>()));
  getIt.registerFactory(() => GetAllTasksUseCase(getIt<TaskRepository>()));
  getIt.registerFactory(() => GetTodayTasksUseCase(getIt<TaskRepository>()));
  getIt.registerFactory(
    () => ToggleTaskCompletionUseCase(getIt<TaskRepository>()),
  );
}
