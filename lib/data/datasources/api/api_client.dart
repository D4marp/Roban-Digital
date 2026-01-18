import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = 'https://ptt-api.uptofive.my.id/api';
  static const String _tokenKey = 'auth_token';
  
  late Dio _dio;
  String? _cachedToken;

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
        onRequest: (options, handler) async {
          // Ensure token is in headers for authenticated requests
          if (!options.path.contains('/auth/login') && 
              !options.headers.containsKey('Authorization')) {
            // Try to load token from cache or SharedPreferences
            if (_cachedToken == null || _cachedToken!.isEmpty) {
              await _loadTokenFromPrefs();
            }
            if (_cachedToken != null && _cachedToken!.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $_cachedToken';
            }
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  Future<void> _loadTokenFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedToken = prefs.getString(_tokenKey);
    } catch (e) {
      // Silently fail
    }
  }

  Dio get dio => _dio;

  /// Initialize API client with stored token on app startup
  Future<void> initializeAuthToken() async {
    await _loadTokenFromPrefs();
    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $_cachedToken';
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
    _cachedToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void removeAuthToken() {
    _cachedToken = null;
    _dio.options.headers.remove('Authorization');
  }
}
