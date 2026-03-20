import 'package:dartz/dartz.dart';
import 'package:dml_hub/core/error/failures.dart';
import 'package:dml_hub/features/todo/domain/entities/task.dart';
import 'package:dml_hub/features/todo/domain/repositories/task_repository.dart';
import 'package:dml_hub/features/todo/domain/usecases/task/create_task_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTaskRepository implements TaskRepository {
  Task? latestCreatedTask;

  @override
  Future<Either<Failure, Task>> createTask(Task task) async {
    latestCreatedTask = task;
    return Right(task.copyWith(id: 'created-id'));
  }

  @override
  Future<Either<Failure, Unit>> deleteTask(String taskId) async {
    return const Right(unit);
  }

  @override
  Future<Either<Failure, List<Task>>> getAllTasks() async {
    return const Right(<Task>[]);
  }

  @override
  Future<Either<Failure, List<Task>>> getTodayTasks() async {
    return const Right(<Task>[]);
  }

  @override
  Future<Either<Failure, Task>> toggleTaskCompletion(String taskId) async {
    return Left(DatabaseFailure('Not implemented in fake.'));
  }
}

void main() {
  group('CreateTaskUseCase', () {
    test('returns validation failure when title is empty', () async {
      final useCase = CreateTaskUseCase(_FakeTaskRepository());

      final result = await useCase(const CreateTaskParams(title: '   '));

      expect(result.isLeft(), isTrue);
    });

    test('creates a task when title is valid', () async {
      final repository = _FakeTaskRepository();
      final useCase = CreateTaskUseCase(repository);

      final result = await useCase(const CreateTaskParams(title: 'Ship MVP'));

      expect(result.isRight(), isTrue);
      expect(repository.latestCreatedTask?.title, 'Ship MVP');
    });
  });
}
