import 'package:dartz/dartz.dart';

import 'package:dml_hub/core/error/failures.dart';
import 'package:dml_hub/core/usecases/usecase.dart';
import 'package:dml_hub/features/todo/domain/repositories/task_repository.dart';

class DeleteTaskUseCase extends UseCase<Unit, String> {
  const DeleteTaskUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String params) {
    return _repository.deleteTask(params);
  }
}
