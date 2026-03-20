import 'package:dartz/dartz.dart';

import 'package:dml_hub/core/error/failures.dart';
import 'package:dml_hub/core/usecases/usecase.dart';
import 'package:dml_hub/features/todo/domain/entities/task.dart';
import 'package:dml_hub/features/todo/domain/repositories/task_repository.dart';

class GetTodayTasksUseCase extends UseCaseNoParams<List<Task>> {
  const GetTodayTasksUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Future<Either<Failure, List<Task>>> call() {
    return _repository.getTodayTasks();
  }
}
