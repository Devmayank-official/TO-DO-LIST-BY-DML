import 'package:dartz/dartz.dart';

import 'package:dml_hub/core/error/failures.dart';
import 'package:dml_hub/core/usecases/usecase.dart';
import 'package:dml_hub/features/todo/domain/entities/project.dart';
import 'package:dml_hub/features/todo/domain/repositories/task_repository.dart';

class GetProjectsUseCase extends UseCaseNoParams<List<Project>> {
  const GetProjectsUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Future<Either<Failure, List<Project>>> call() {
    return _repository.getProjects();
  }
}
