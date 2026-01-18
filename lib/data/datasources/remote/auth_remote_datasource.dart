import 'package:dio/dio.dart';
import 'package:robandigital/data/models/login_model.dart';
import '../api/api_client.dart';

/// Remote data source for auth-related API calls
abstract class AuthRemoteDataSource {
  /// Get current authenticated user info
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await apiClient.get('/auth/me');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final userData = data['data'] as Map<String, dynamic>;
        return UserModel.fromJson(userData);
      } else {
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
