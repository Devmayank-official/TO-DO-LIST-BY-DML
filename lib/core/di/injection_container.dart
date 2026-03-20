import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';

import 'package:dml_hub/features/todo/data/repositories/task_repository_impl.dart';
import 'package:dml_hub/features/todo/domain/repositories/task_repository.dart';
import 'package:dml_hub/features/todo/domain/usecases/task/create_task_usecase.dart';
import 'package:dml_hub/features/todo/domain/usecases/task/delete_task_usecase.dart';
import 'package:dml_hub/features/todo/domain/usecases/task/get_all_tasks_usecase.dart';
import 'package:dml_hub/features/todo/domain/usecases/task/get_today_tasks_usecase.dart';
import 'package:dml_hub/features/hub/data/services/biometric_service_impl.dart';
import 'package:dml_hub/features/hub/domain/services/biometric_service.dart';
import 'package:dml_hub/features/todo/domain/usecases/project/create_project_usecase.dart';
import 'package:dml_hub/features/todo/domain/usecases/project/get_projects_usecase.dart';
import 'package:dml_hub/features/todo/domain/usecases/task/toggle_task_completion_usecase.dart';

final GetIt getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  if (getIt.isRegistered<TaskRepository>()) {
    return;
  }

  getIt.registerLazySingleton<FlutterSecureStorage>(FlutterSecureStorage.new);
  getIt.registerLazySingleton<LocalAuthentication>(LocalAuthentication.new);
  getIt.registerLazySingleton<BiometricService>(
    () => BiometricServiceImpl(
      localAuthentication: getIt<LocalAuthentication>(),
      secureStorage: getIt<FlutterSecureStorage>(),
    ),
  );
  getIt.registerLazySingleton<TaskRepository>(TaskRepositoryImpl.new);
  getIt.registerFactory(() => CreateTaskUseCase(getIt<TaskRepository>()));
  getIt.registerFactory(() => DeleteTaskUseCase(getIt<TaskRepository>()));
  getIt.registerFactory(() => GetAllTasksUseCase(getIt<TaskRepository>()));
  getIt.registerFactory(() => GetTodayTasksUseCase(getIt<TaskRepository>()));
  getIt.registerFactory(
    () => ToggleTaskCompletionUseCase(getIt<TaskRepository>()),
  );
  getIt.registerFactory(() => GetProjectsUseCase(getIt<TaskRepository>()));
  getIt.registerFactory(() => CreateProjectUseCase(getIt<TaskRepository>()));
}

