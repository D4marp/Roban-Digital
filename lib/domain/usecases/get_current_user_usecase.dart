import 'package:dartz/dartz.dart';
import 'package:robandigital/core/errors/failures.dart';
import 'package:robandigital/domain/entities/auth_entity.dart';
import 'package:robandigital/domain/repositories/get_current_user_repository.dart';

class GetCurrentUserUsecase {
  final GetCurrentUserRepository repository;

  GetCurrentUserUsecase({required this.repository});

  Future<Either<Failure, UserEntity>> call() {
    return repository.getCurrentUser();
  }
}
