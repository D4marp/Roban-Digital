import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
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

      if (kDebugMode) {
        print('[AuthRepository.login] Response received:');
        print('  - success: ${response.success}');
        print('  - token: ${response.token.isNotEmpty ? "✓ present" : "✗ empty"}');
        print('  - refreshToken: ${response.refreshToken.isNotEmpty ? "✓ present" : "✗ empty"}');
        print('  - user.id: ${response.user.id}');
        print('  - user.email: ${response.user.email}');
        print('  - user.username: ${response.user.username}');
        print('  - user.role: ${response.user.role}');
      }

      // Save tokens to local storage
      await localDataSource.saveTokens(
        token: response.token,
        refreshToken: response.refreshToken,
      );

      // Set both tokens to API client for subsequent requests & auto-refresh
      apiClient.setAuthToken(response.token, response.refreshToken);

      // Save user data to local storage
      if (kDebugMode) {
        print('[AuthRepository.login] Saving user data to local storage...');
      }
      
      // Ensure username has a value - use email prefix if username is empty
      String usernameToSave = response.user.username;
      if (usernameToSave.isEmpty && response.user.email.isNotEmpty) {
        usernameToSave = response.user.email.split('@').first;
        if (kDebugMode) {
          print('[AuthRepository.login] Username was empty, using email prefix: $usernameToSave');
        }
      }
      
      await localDataSource.saveUserData(
        id: response.user.id,
        email: response.user.email,
        role: response.user.role,
        unitId: response.user.unitId,
        username: usernameToSave,
      );
      
      if (kDebugMode) {
        print('[AuthRepository.login] User data saved successfully');
        print('[AuthRepository.login] Final saved data:');
        print('  - id: ${response.user.id}');
        print('  - email: ${response.user.email}');
        print('  - username: $usernameToSave');
        print('  - role: ${response.user.role}');
      }

      return Right(
        AuthEntity(
          success: response.success,
          token: response.token,
          user: _mapUserModelToEntity(response.user),
        ),
      );
    } on BadRequestException catch (e) {
      if (kDebugMode) {
        print('[AuthRepository.login] BadRequestException: ${e.message}');
      }
      return Left(BadRequestFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      if (kDebugMode) {
        print('[AuthRepository.login] UnauthorizedException: ${e.message}');
      }
      return Left(UnauthorizedFailure(message: e.message));
    } on ForbiddenException catch (e) {
      if (kDebugMode) {
        print('[AuthRepository.login] ForbiddenException: ${e.message}');
      }
      return Left(ForbiddenFailure(message: e.message));
    } on NotFoundException catch (e) {
      if (kDebugMode) {
        print('[AuthRepository.login] NotFoundException: ${e.message}');
      }
      return Left(NotFoundFailure(message: e.message));
    } on ConflictException catch (e) {
      if (kDebugMode) {
        print('[AuthRepository.login] ConflictException: ${e.message}');
      }
      return Left(ConflictFailure(message: e.message));
    } on ServerException catch (e) {
      if (kDebugMode) {
        print('[AuthRepository.login] ServerException: ${e.message}');
      }
      return Left(ServerFailure(message: e.message));
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('[AuthRepository.login] TimeoutException: ${e.message}');
      }
      return Left(TimeoutFailure(message: e.message));
    } on NetworkException catch (e) {
      if (kDebugMode) {
        print('[AuthRepository.login] NetworkException: ${e.message}');
      }
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      if (kDebugMode) {
        print('[AuthRepository.login] Unknown Exception: $e');
      }
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
      if (kDebugMode) {
        print('[AuthRepository.getCurrentUser] Fetching current user from /auth/me...');
      }

      final response = await remoteDataSource.getCurrentUser();

      if (kDebugMode) {
        print('[AuthRepository.getCurrentUser] Response received:');
        print('  - user.id: ${response.user.id}');
        print('  - user.email: ${response.user.email}');
        print('  - user.username: ${response.user.username}');
        print('  - user.role: ${response.user.role}');
      }

      // Update user data in local storage
      await localDataSource.saveUserData(
        id: response.user.id,
        email: response.user.email,
        role: response.user.role,
        unitId: response.user.unitId,
        username: response.user.username,
      );

      if (kDebugMode) {
        print('[AuthRepository.getCurrentUser] User data updated in local storage');
      }

      return Right(
        AuthEntity(
          success: response.success,
          token: response.token,
          user: _mapUserModelToEntity(response.user),
        ),
      );
    } on ServerException catch (e) {
      if (kDebugMode) {
        print('[AuthRepository.getCurrentUser] ServerException: ${e.message}');
      }
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      if (kDebugMode) {
        print('[AuthRepository.getCurrentUser] Exception: $e');
      }
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

      // Save new tokens to local storage
      await localDataSource.saveTokens(
        token: response.token,
        refreshToken: response.refreshToken,
      );
      
      // Update both tokens in API client (will restart auto-refresh timer)
      apiClient.setAuthToken(response.token, response.refreshToken);

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

