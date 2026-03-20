sealed class Failure {
  const Failure(this.message);

  final String message;
}

final class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

final class NotificationFailure extends Failure {
  const NotificationFailure(super.message);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
