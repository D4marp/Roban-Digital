import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

class BadRequestFailure extends Failure {
  const BadRequestFailure({required String message}) : super(message: message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({required String message}) : super(message: message);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure({required String message}) : super(message: message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required String message}) : super(message: message);
}

class ConflictFailure extends Failure {
  const ConflictFailure({required String message}) : super(message: message);
}

class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message: message);
}

class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message: message);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({required String message}) : super(message: message);
}

class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message: message);
}

class UnknownFailure extends Failure {
  const UnknownFailure({required String message}) : super(message: message);
}
