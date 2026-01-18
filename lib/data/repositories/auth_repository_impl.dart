import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/login_remote_datasource.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/api/api_client.dart';
import '../models/login_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LoginRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final ApiClient apiClient;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.apiClient,
  });

  @override
  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
    String portal = 'MOBILE',
  }) async {
    try {
      final request = LoginRequestModel(
        email: email,
        password: password,
        portal: portal,
      );

      final response = await remoteDataSource.login(request);

      // Save token to local storage
      await localDataSource.saveToken(response.token);

      // Set token to API client for subsequent requests
      apiClient.setAuthToken(response.token);

      // Save user data to local storage
      await localDataSource.saveUserData(
        id: response.user.id,
        email: response.user.email,
        role: response.user.role,
      );

      return Right(
        AuthEntity(
          success: response.success,
          token: response.token,
          user: _mapUserModelToEntity(response.user),
        ),
      );
    } on BadRequestException catch (e) {
      return Left(BadRequestFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ForbiddenException catch (e) {
      return Left(ForbiddenFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ConflictException catch (e) {
      return Left(ConflictFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(
        UnknownFailure(
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final response = await remoteDataSource.getCurrentUser();

      // Update user data in local storage
      await localDataSource.saveUserData(
        id: response.user.id,
        email: response.user.email,
        role: response.user.role,
      );

      return Right(
        AuthEntity(
          success: response.success,
          token: response.token,
          user: _mapUserModelToEntity(response.user),
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        UnknownFailure(
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> refreshToken() async {
    try {
      final response = await remoteDataSource.refreshToken();

      // Save new token
      await localDataSource.saveToken(response.token);
      apiClient.setAuthToken(response.token);

      return Right(
        AuthEntity(
          success: response.success,
          token: response.token,
          user: _mapUserModelToEntity(response.user),
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        UnknownFailure(
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearAll();
    apiClient.removeAuthToken();
  }

  @override
  Future<String?> getStoredToken() async {
    return localDataSource.getToken();
  }

  @override
  bool isLoggedIn() {
    return localDataSource.isLoggedIn();
  }

  UserEntity _mapUserModelToEntity(UserModel model) {
    return UserEntity(
      id: model.id,
      email: model.email,
      username: model.username,
      role: model.role,
      unitId: model.unitId,
      createdAt: model.createdAt,
    );
  }
}

