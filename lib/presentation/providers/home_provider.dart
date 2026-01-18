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
      final username = _authLocalDataSource.getUsername() ?? '';
      final email = _authLocalDataSource.getUserEmail() ?? '';
      final role = _authLocalDataSource.getUserRole();

      _userName = username.isNotEmpty ? username : 'User';
      _userEmail = email.isNotEmpty ? email : 'user@example.com';
      _userRole = role;

      // Mark as success if we have at least email
      if (email.isNotEmpty) {
        _state = HomeState.success;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading local data: $e';
    }
  }

  /// Initialize and load current user data from API
  Future<void> initializeUserData() async {
    // Data already loaded from local storage in constructor
    // This just refreshes from API if available
    
    final storedToken = await _authRepository.getStoredToken();
    
    if (storedToken != null && storedToken.isNotEmpty) {
      // Try to load current user from API
      _state = HomeState.loading;
      notifyListeners();
      
      await loadCurrentUser();
    }
  }

  /// Load current user from API
  Future<void> loadCurrentUser() async {
    final result = await _authRepository.getCurrentUser();

    result.fold(
      (failure) {
        // Keep local data even if API fails
        _state = HomeState.success;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (authEntity) {
        _authEntity = authEntity;
        _userName = authEntity.user.username;
        _userEmail = authEntity.user.email;
        _userRole = authEntity.user.role;
        _state = HomeState.success;
        notifyListeners();
      },
    );
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

