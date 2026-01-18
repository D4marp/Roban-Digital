import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase({required this.repository});

  Future<Either<Failure, AuthEntity>> call({
    required String email,
    required String password,
    String portal = 'MOBILE',
  }) async {
    return await repository.login(
      email: email,
      password: password,
      portal: portal,
    );
  }
}
