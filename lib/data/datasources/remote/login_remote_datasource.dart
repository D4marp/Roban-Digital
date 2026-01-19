import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:robandigital/data/models/login_model.dart';
import 'package:robandigital/data/datasources/local/auth_local_datasource.dart';
import '../api/api_client.dart';


abstract class LoginRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<LoginResponseModel> getCurrentUser();
  Future<LoginResponseModel> refreshToken();
  Future<void> logout();
}

class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  final ApiClient apiClient;
  final AuthLocalDataSource authLocalDataSource;

  LoginRemoteDataSourceImpl({
    required this.apiClient,
    required this.authLocalDataSource,
  });

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      if (kDebugMode) {
        print('[LoginRemoteDataSource] POST /auth/login with:');
        print('  - email: ${request.email}');
        print('  - portal: ${request.portal}');
      }

      final response = await apiClient.post(
        '/auth/login',
        data: request.toJson(),
      );

      if (kDebugMode) {
        print('[LoginRemoteDataSource] Response status: ${response.statusCode}');
        print('[LoginRemoteDataSource] Raw response data: ${response.data}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = LoginResponseModel.fromJson(response.data);
        
        if (kDebugMode) {
          print('[LoginRemoteDataSource] Parsed LoginResponseModel:');
          print('  - success: ${result.success}');
          print('  - token: ${result.token.substring(0, 20)}...');
          print('  - refreshToken: ${result.refreshToken.substring(0, 20)}...');
          print('  - user.id: ${result.user.id}');
          print('  - user.email: ${result.user.email}');
          print('  - user.username: ${result.user.username}');
          print('  - user.role: ${result.user.role}');
        }
        
        return result;
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('[LoginRemoteDataSource] DioException: ${e.message}');
      }
      throw _handleDioException(e);
    }
  }

  @override
  Future<LoginResponseModel> getCurrentUser() async {
    try {
      if (kDebugMode) {
        print('[LoginRemoteDataSource.getCurrentUser] GET /auth/me');
      }

      final response = await apiClient.get('/auth/me');

      if (kDebugMode) {
        print('[LoginRemoteDataSource.getCurrentUser] Response status: ${response.statusCode}');
        print('[LoginRemoteDataSource.getCurrentUser] Raw response: ${response.data}');
      }

      if (response.statusCode == 200) {
        final result = LoginResponseModel.fromJson(response.data);
        
        if (kDebugMode) {
          print('[LoginRemoteDataSource.getCurrentUser] Parsed user:');
          print('  - id: ${result.user.id}');
          print('  - email: ${result.user.email}');
          print('  - username: ${result.user.username}');
          print('  - role: ${result.user.role}');
        }
        
        return result;
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('[LoginRemoteDataSource.getCurrentUser] DioException: ${e.message}');
        print('[LoginRemoteDataSource.getCurrentUser] Status code: ${e.response?.statusCode}');
      }
      throw _handleDioException(e);
    }
  }

  @override
  Future<LoginResponseModel> refreshToken() async {
    try {
      // Get refresh token from local storage
      final storedRefreshToken = authLocalDataSource.getRefreshToken();
      
      if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
        throw Exception('No refresh token available');
      }

      // Call API with refreshToken in request body
      final response = await apiClient.post(
        '/auth/refresh',
        data: {'refreshToken': storedRefreshToken},
      );

      if (response.statusCode == 200) {
        return LoginResponseModel.fromJson(response.data);
      } else {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      final response = await apiClient.post('/auth/logout');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleErrorResponse(Response response) {
    final data = response.data as Map<String, dynamic>?;
    final errorMessage = (data?['error'] as String?) ?? (data?['message'] as String?) ?? 'Unknown error occurred';
    final statusCode = response.statusCode ?? 500;

    switch (statusCode) {
      case 400:
        return BadRequestException(errorMessage);
      case 401:
        return UnauthorizedException(errorMessage);
      case 403:
        return ForbiddenException(errorMessage);
      case 404:
        return NotFoundException(errorMessage);
      case 409:
        return ConflictException(errorMessage);
      case 500:
      default:
        return ServerException(errorMessage);
    }
  }

  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return TimeoutException('Connection timeout');
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Receive timeout');
      case DioExceptionType.sendTimeout:
        return TimeoutException('Send timeout');
      case DioExceptionType.badResponse:
        return _handleErrorResponse(e.response!);
      case DioExceptionType.badCertificate:
        return NetworkException('Bad certificate');
      case DioExceptionType.connectionError:
        return NetworkException('Connection error');
      case DioExceptionType.cancel:
        return NetworkException('Request cancelled');
      case DioExceptionType.unknown:
        return NetworkException(e.message ?? 'Unknown error');
    }
  }
}

// Custom exceptions
class BadRequestException implements Exception {
  final String message;
  BadRequestException(this.message);

  @override
  String toString() => 'BadRequestException: $message';
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => 'UnauthorizedException: $message';
}

class ForbiddenException implements Exception {
  final String message;
  ForbiddenException(this.message);

  @override
  String toString() => 'ForbiddenException: $message';
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);

  @override
  String toString() => 'NotFoundException: $message';
}

class ConflictException implements Exception {
  final String message;
  ConflictException(this.message);

  @override
  String toString() => 'ConflictException: $message';
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}
