import 'package:dartz/dartz.dart';

import 'package:dml_hub/core/error/failures.dart';
import 'package:dml_hub/features/todo/domain/entities/project.dart';
import 'package:dml_hub/features/todo/domain/entities/task.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<Task>>> getAllTasks();
  Future<Either<Failure, List<Task>>> getTodayTasks();
  Future<Either<Failure, Task>> createTask(Task task);
  Future<Either<Failure, List<Project>>> getProjects();
  Future<Either<Failure, Project>> createProject(Project project);
  Future<Either<Failure, Task>> toggleTaskCompletion(String taskId);
  Future<Either<Failure, Unit>> deleteTask(String taskId);
}
