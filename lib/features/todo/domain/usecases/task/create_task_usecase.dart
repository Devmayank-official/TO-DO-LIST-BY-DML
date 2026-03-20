import 'package:dartz/dartz.dart';

import 'package:dml_hub/core/error/failures.dart';
import 'package:dml_hub/core/usecases/usecase.dart';
import 'package:dml_hub/features/todo/domain/entities/task.dart';
import 'package:dml_hub/features/todo/domain/repositories/task_repository.dart';

class CreateTaskParams {
  const CreateTaskParams({
    required this.title,
    this.priority = TaskPriority.none,
    this.dueDate,
    this.projectName,
  });

  final String title;
  final TaskPriority priority;
  final DateTime? dueDate;
  final String? projectName;
}

class CreateTaskUseCase extends UseCase<Task, CreateTaskParams> {
  const CreateTaskUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Future<Either<Failure, Task>> call(CreateTaskParams params) async {
    if (params.title.trim().isEmpty) {
      return const Left(ValidationFailure('Task title cannot be empty.'));
    }

    final now = DateTime.now();
    return _repository.createTask(
      Task(
        id: '',
        title: params.title.trim(),
        createdAt: now,
        updatedAt: now,
        priority: params.priority,
        dueDate: params.dueDate,
        projectName: params.projectName,
      ),
    );
  }
}
