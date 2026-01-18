import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = 'https://ptt-api.uptofive.my.id/api';
  static const String _tokenKey = 'auth_token';
  
  late Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('[ApiClient] Request: ${options.method} ${options.path}');
          print('[ApiClient] Headers: ${options.headers}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('[ApiClient] Response: ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('[ApiClient] Error: ${e.response?.statusCode} ${e.message}');
          print('[ApiClient] Error response: ${e.response?.data}');
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;

  /// Initialize API client with stored token on app startup
  Future<void> initializeAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      print('[ApiClient] Initializing token. Token exists: ${token != null}');
      if (token != null && token.isNotEmpty) {
        setAuthToken(token);
        print('[ApiClient] Token set successfully');
      } else {
        print('[ApiClient] No token found in SharedPreferences');
      }
    } catch (e) {
      print('[ApiClient] Error initializing token: $e');
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    print('[ApiClient] Authorization header set with token: ${token.substring(0, 20)}...');
  }

  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
