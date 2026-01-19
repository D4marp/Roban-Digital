import 'package:flutter/foundation.dart';
import 'package:robandigital/data/datasources/local/auth_local_datasource.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/auth_entity.dart';

enum HomeState { initial, loading, success, error }

class HomeProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final AuthLocalDataSource _authLocalDataSource;

  HomeState _state = HomeState.initial;
  String? _errorMessage;
  AuthEntity? _authEntity;
  String _userName = '';
  String _userEmail = '';
  String? _userRole;

  HomeProvider({
    required AuthRepository authRepository,
    required AuthLocalDataSource authLocalDataSource,
  })  : _authRepository = authRepository,
        _authLocalDataSource = authLocalDataSource {
    // Load data from local storage immediately
    _loadFromLocalStorage();
  }

  // Getters
  HomeState get state => _state;
  String? get errorMessage => _errorMessage;
  AuthEntity? get authEntity => _authEntity;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String? get userRole => _userRole;
  bool get isLoading => _state == HomeState.loading;

  /// Load user data from local storage
  void _loadFromLocalStorage() {
    try {
      final username = _authLocalDataSource.getUsername();
      final email = _authLocalDataSource.getUserEmail();
      final role = _authLocalDataSource.getUserRole();

      // Set the actual values from storage, keep empty if not available
      _userName = username ?? '';
      _userEmail = email ?? '';
      _userRole = role;

      if (kDebugMode) {
        print('[HomeProvider] Loaded from local storage:');
        print('  - username: "${_userName.isEmpty ? "(empty)" : _userName}"');
        print('  - email: "${_userEmail.isEmpty ? "(empty)" : _userEmail}"');
        print('  - role: ${_userRole ?? "(null)"}');
      }

      // Mark as success if we have at least email
      if (email != null && email.isNotEmpty) {
        _state = HomeState.success;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading local data: $e';
      if (kDebugMode) {
        print('[HomeProvider] Error: $_errorMessage');
      }
      notifyListeners();
    }
  }

  /// Initialize and load current user data from API
  Future<void> initializeUserData() async {
    // Data already loaded from local storage in constructor
    // This fetches real-time data from server
    
    final storedToken = await _authRepository.getStoredToken();
    
    if (storedToken != null && storedToken.isNotEmpty) {
      if (kDebugMode) {
        print('[HomeProvider] Token found, fetching fresh user data from server...');
      }
      // Fetch current user data from API (real-time)
      await loadCurrentUser();
    } else {
      if (kDebugMode) {
        print('[HomeProvider] No token found, using local data only');
      }
    }
  }

  /// Load current user from API
  Future<void> loadCurrentUser() async {
    try {
      if (_state != HomeState.loading) {
        _state = HomeState.loading;
        notifyListeners();
      }

      final result = await _authRepository.getCurrentUser();

      result.fold(
        (failure) {
          if (kDebugMode) {
            print('[HomeProvider] API call failed: ${failure.message}');
          }
          // Keep local data even if API fails
          _state = HomeState.success;
          _errorMessage = failure.message;
          notifyListeners();
        },
        (authEntity) {
          if (kDebugMode) {
            print('[HomeProvider] Updated from server: username=${authEntity.user.username}, email=${authEntity.user.email}');
          }
          _authEntity = authEntity;
          _userName = authEntity.user.username;
          _userEmail = authEntity.user.email;
          _userRole = authEntity.user.role;
          _state = HomeState.success;
          _errorMessage = null; // Clear any previous error
          notifyListeners();
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('[HomeProvider] Exception loading current user: $e');
      }
      _state = HomeState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Logout user
  Future<bool> logout() async {
    try {
      _state = HomeState.loading;
      notifyListeners();

      await _authRepository.logout();

      _state = HomeState.initial;
      _authEntity = null;
      _userName = '';
      _userEmail = '';
      _userRole = null;
      _errorMessage = null;
      notifyListeners();

      return true;
    } catch (e) {
      _state = HomeState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}

