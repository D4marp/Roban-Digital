import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

typedef OnUnauthorizedCallback = Future<void> Function();

class ApiClient {
  static const String baseUrl = 'https://ptt-api.uptofive.my.id/api';
  static const String _tokenKey = 'auth_token';
  
  late Dio _dio;
  String? _cachedToken;
  String? _cachedRefreshToken;
  static const String _refreshTokenKey = 'refresh_token';
  bool _isRefreshing = false;
  OnUnauthorizedCallback? _onUnauthorized;
  
  // Global token refresh mechanism
  Timer? _tokenRefreshTimer;
  static const Duration _refreshInterval = Duration(minutes: 5);
  static const Duration _bufferTime = Duration(minutes: 2);

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
              !options.path.contains('/auth/refresh') &&
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
        onError: (DioException e, handler) async {
          // Handle 401 Unauthorized - try to refresh token
          if (e.response?.statusCode == 401 && 
              !e.requestOptions.path.contains('/auth/login') &&
              !e.requestOptions.path.contains('/auth/refresh')) {
            
            if (kDebugMode) {
              print('[ApiClient] 401 Unauthorized - attempting token refresh...');
              print('[ApiClient] Error: ${e.response?.data}');
            }

            // Prevent multiple refresh attempts
            if (!_isRefreshing) {
              _isRefreshing = true;
              
              try {
                // Attempt to refresh the token
                final refreshed = await _refreshAccessToken();
                
                if (refreshed) {
                  if (kDebugMode) {
                    print('[ApiClient] Token refreshed successfully, retrying request...');
                  }
                  _isRefreshing = false;
                  // Retry the failed request with new token
                  return handler.resolve(await _retry(e.requestOptions));
                } else {
                  // Refresh failed - logout user
                  if (kDebugMode) {
                    print('[ApiClient] Token refresh failed, logging out...');
                  }
                  _isRefreshing = false;
                  await _handleUnauthorized();
                  return handler.next(e);
                }
              } catch (refreshError) {
                _isRefreshing = false;
                if (kDebugMode) {
                  print('[ApiClient] Token refresh error: $refreshError');
                }
                await _handleUnauthorized();
                return handler.next(e);
              }
            }
          }
          
          // Handle 403 Forbidden
          if (e.response?.statusCode == 403) {
            if (kDebugMode) {
              print('[ApiClient] 403 Forbidden - access denied');
            }
          }
          
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
      
      // Start global token refresh mechanism
      _startTokenRefreshTimer();
    }
  }

  /// Refresh access token using refresh token
  Future<bool> _refreshAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);
      
      if (refreshToken == null || refreshToken.isEmpty) {
        if (kDebugMode) {
          print('[ApiClient._refreshAccessToken] No refresh token available');
        }
        return false;
      }

      if (kDebugMode) {
        print('[ApiClient._refreshAccessToken] Attempting to refresh with refresh token...');
      }

      // Create a new dio instance to avoid interceptor loop
      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final response = await dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newToken = response.data['token'] as String?;
        final newRefreshToken = response.data['refreshToken'] as String?;
        
        if (newToken != null && newToken.isNotEmpty) {
          // Update cached token
          _cachedToken = newToken;
          
          // Update local storage
          await prefs.setString(_tokenKey, newToken);
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await prefs.setString(_refreshTokenKey, newRefreshToken);
          }
          
          // Update dio header
          _dio.options.headers['Authorization'] = 'Bearer $newToken';
          
          if (kDebugMode) {
            print('[ApiClient._refreshAccessToken] Token refreshed successfully');
          }
          return true;
        }
      }
      
      if (kDebugMode) {
        print('[ApiClient._refreshAccessToken] Refresh failed: status ${response.statusCode}');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('[ApiClient._refreshAccessToken] Error: $e');
      }
      return false;
    }
  }

  /// Retry failed request with new token
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
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

  void setAuthToken(String token, [String? refreshToken]) {
    _cachedToken = token;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      _cachedRefreshToken = refreshToken;
    }
    _dio.options.headers['Authorization'] = 'Bearer $token';
    
    // Start/restart token refresh timer when new token is set
    _startTokenRefreshTimer();
  }

  void removeAuthToken() {
    _cachedToken = null;
    _cachedRefreshToken = null;
    _dio.options.headers.remove('Authorization');
    _stopTokenRefreshTimer();
  }

  /// Start global token refresh timer
  void _startTokenRefreshTimer() {
    // Cancel existing timer
    _tokenRefreshTimer?.cancel();
    
    if (kDebugMode) {
      print('[ApiClient] Starting global token refresh timer (interval: $_refreshInterval)');
    }
    
    // Refresh token every 5 minutes
    _tokenRefreshTimer = Timer.periodic(_refreshInterval, (_) async {
      if (kDebugMode) {
        print('[ApiClient] Global token refresh triggered');
      }
      await _proactiveTokenRefresh();
    });
    
    // Also do first refresh after buffer time
    Future.delayed(_bufferTime, () async {
      if (_cachedRefreshToken != null && _cachedRefreshToken!.isNotEmpty) {
        await _proactiveTokenRefresh();
      }
    });
  }

  /// Stop token refresh timer
  void _stopTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
    if (kDebugMode) {
      print('[ApiClient] Stopped token refresh timer');
    }
  }

  /// Proactive token refresh (doesn't wait for 401)
  Future<void> _proactiveTokenRefresh() async {
    if (_isRefreshing) {
      if (kDebugMode) {
        print('[ApiClient._proactiveTokenRefresh] Already refreshing, skipping...');
      }
      return;
    }

    try {
      _isRefreshing = true;
      
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = _cachedRefreshToken ?? prefs.getString(_refreshTokenKey);
      
      if (refreshToken == null || refreshToken.isEmpty) {
        if (kDebugMode) {
          print('[ApiClient._proactiveTokenRefresh] No refresh token available');
        }
        _isRefreshing = false;
        return;
      }

      if (kDebugMode) {
        print('[ApiClient._proactiveTokenRefresh] Proactively refreshing access token...');
      }

      // Create a new dio instance to avoid interceptor loop
      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final response = await dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newToken = response.data['token'] as String?;
        final newRefreshToken = response.data['refreshToken'] as String?;
        
        if (newToken != null && newToken.isNotEmpty) {
          // Update all cached tokens
          _cachedToken = newToken;
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            _cachedRefreshToken = newRefreshToken;
          }

          // Update local storage
          await prefs.setString(_tokenKey, newToken);
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await prefs.setString(_refreshTokenKey, newRefreshToken);
          }

          // Update dio header
          _dio.options.headers['Authorization'] = 'Bearer $newToken';

          if (kDebugMode) {
            print('[ApiClient._proactiveTokenRefresh] ✓ Token refreshed successfully (proactive)');
          }
          _isRefreshing = false;
          return;
        }
      }

      if (kDebugMode) {
        print('[ApiClient._proactiveTokenRefresh] Refresh failed: status ${response.statusCode}');
      }
      _isRefreshing = false;
    } catch (e) {
      if (kDebugMode) {
        print('[ApiClient._proactiveTokenRefresh] Error: $e');
      }
      _isRefreshing = false;
    }
  }

  /// Set callback for when user becomes unauthorized
  void setOnUnauthorizedCallback(OnUnauthorizedCallback callback) {
    _onUnauthorized = callback;
  }

  /// Handle unauthorized error - clear tokens and notify
  Future<void> _handleUnauthorized() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      removeAuthToken();
      
      if (kDebugMode) {
        print('[ApiClient] Tokens cleared, calling onUnauthorized callback');
      }
      
      // Call the callback if set
      if (_onUnauthorized != null) {
        await _onUnauthorized!();
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ApiClient._handleUnauthorized] Error: $e');
      }
    }
  }
}
