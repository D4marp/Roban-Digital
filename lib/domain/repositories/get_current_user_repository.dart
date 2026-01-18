import 'package:dartz/dartz.dart';
import 'package:robandigital/core/errors/failures.dart';
import 'package:robandigital/domain/entities/auth_entity.dart';

abstract class GetCurrentUserRepository {
  Future<Either<Failure, UserEntity>> getCurrentUser();
}
