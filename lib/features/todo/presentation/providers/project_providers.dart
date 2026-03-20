import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dml_hub/core/di/injection_container.dart';
import 'package:dml_hub/features/todo/domain/entities/project.dart';
import 'package:dml_hub/features/todo/domain/usecases/project/create_project_usecase.dart';
import 'package:dml_hub/features/todo/domain/usecases/project/get_projects_usecase.dart';
import 'package:dml_hub/features/todo/presentation/providers/task_providers.dart';

final projectsProvider = FutureProvider<List<Project>>((ref) async {
  ref.watch(tasksRefreshTriggerProvider);
  final result = await getIt<GetProjectsUseCase>().call();
  return result.fold((failure) => throw Exception(failure.message), (projects) => projects);
});

final projectActionsProvider = Provider<ProjectActions>((ref) {
  return ProjectActions(ref);
});

class ProjectActions {
  const ProjectActions(this._ref);

  final Ref _ref;

  Future<void> createProject(CreateProjectParams params) async {
    await getIt<CreateProjectUseCase>().call(params);
    _ref.read(tasksRefreshTriggerProvider.notifier).state++;
  }
}
