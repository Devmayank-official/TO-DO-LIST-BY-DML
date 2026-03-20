import 'package:dartz/dartz.dart';

import 'package:dml_hub/core/error/failures.dart';
import 'package:dml_hub/core/usecases/usecase.dart';
import 'package:dml_hub/features/todo/domain/entities/task.dart';
import 'package:dml_hub/features/todo/domain/repositories/task_repository.dart';

class ToggleTaskCompletionUseCase extends UseCase<Task, String> {
  const ToggleTaskCompletionUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Future<Either<Failure, Task>> call(String params) {
    return _repository.toggleTaskCompletion(params);
  }
}
