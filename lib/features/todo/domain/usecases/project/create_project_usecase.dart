import 'package:dartz/dartz.dart';

import 'package:dml_hub/core/error/failures.dart';
import 'package:dml_hub/core/usecases/usecase.dart';
import 'package:dml_hub/features/todo/domain/entities/project.dart';
import 'package:dml_hub/features/todo/domain/repositories/task_repository.dart';

class CreateProjectParams {
  const CreateProjectParams({required this.name, this.description});

  final String name;
  final String? description;
}

class CreateProjectUseCase extends UseCase<Project, CreateProjectParams> {
  const CreateProjectUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Future<Either<Failure, Project>> call(CreateProjectParams params) async {
    if (params.name.trim().isEmpty) {
      return const Left(ValidationFailure('Project name cannot be empty.'));
    }

    final now = DateTime.now();
    return _repository.createProject(
      Project(
        id: '',
        name: params.name.trim(),
        description: params.description,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
}
