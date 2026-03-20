import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import 'package:dml_hub/core/error/failures.dart';
import 'package:dml_hub/core/usecases/usecase.dart';
import 'package:dml_hub/features/todo/domain/entities/tag.dart';

class CreateTagParams {
  const CreateTagParams({required this.name});

  final String name;
}

class CreateTagUseCase extends UseCase<Tag, CreateTagParams> {
  const CreateTagUseCase();

  @override
  Future<Either<Failure, Tag>> call(CreateTagParams params) async {
    if (params.name.trim().isEmpty || params.name.trim().length > 50) {
      return const Left(ValidationFailure('Tag name must be between 1 and 50 characters.'));
    }

    return Right(
      Tag(
        id: const Uuid().v4(),
        name: params.name.trim(),
        createdAt: DateTime.now(),
      ),
    );
  }
}
