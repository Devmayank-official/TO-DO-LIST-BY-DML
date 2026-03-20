import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import 'package:dml_hub/core/error/failures.dart';
import 'package:dml_hub/features/todo/domain/entities/task.dart';
import 'package:dml_hub/features/todo/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl() : _uuid = const Uuid();

  final Uuid _uuid;
  final List<Task> _tasks = <Task>[
    Task(
      id: 'seed-1',
      title: 'Review today priorities',
      createdAt: DateTime(2026, 3, 20, 8),
      updatedAt: DateTime(2026, 3, 20, 8),
      dueDate: DateTime(2026, 3, 20, 12),
      priority: TaskPriority.high,
      isPinned: true,
    ),
    Task(
      id: 'seed-2',
      title: 'Draft DML Hub MVP structure',
      createdAt: DateTime(2026, 3, 20, 9),
      updatedAt: DateTime(2026, 3, 20, 9),
      dueDate: DateTime(2026, 3, 20, 18),
      priority: TaskPriority.medium,
      projectName: 'DML Hub',
    ),
  ];

  @override
  Future<Either<Failure, Task>> createTask(Task task) async {
    final createdTask = task.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _tasks.insert(0, createdTask);
    return Right(createdTask);
  }

  @override
  Future<Either<Failure, Unit>> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, List<Task>>> getAllTasks() async {
    return Right(List<Task>.unmodifiable(_tasks));
  }

  @override
  Future<Either<Failure, List<Task>>> getTodayTasks() async {
    final tasks = _tasks.where((task) => task.isPinned || task.isDueToday || task.isOverdue).toList();
    return Right(List<Task>.unmodifiable(tasks));
  }

  @override
  Future<Either<Failure, Task>> toggleTaskCompletion(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index < 0) {
      return const Left(DatabaseFailure('Task was not found.'));
    }

    final updatedTask = _tasks[index].copyWith(
      isCompleted: !_tasks[index].isCompleted,
      updatedAt: DateTime.now(),
    );
    _tasks[index] = updatedTask;
    return Right(updatedTask);
  }
}
