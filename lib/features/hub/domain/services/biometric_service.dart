import 'package:dartz/dartz.dart';

import 'package:dml_hub/core/error/failures.dart';

abstract class BiometricService {
  Future<bool> isAvailable();
  Future<bool> isLockEnabled();
  Future<Either<Failure, Unit>> setLockEnabled(bool enabled);
  Future<Either<Failure, Unit>> authenticate();
}
