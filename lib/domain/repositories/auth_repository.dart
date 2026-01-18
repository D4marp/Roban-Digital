import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
    String portal = 'MOBILE',
  });

  Future<Either<Failure, AuthEntity>> getCurrentUser();

  Future<Either<Failure, AuthEntity>> refreshToken();

  Future<void> logout();

  Future<String?> getStoredToken();

  bool isLoggedIn();
}
