import 'package:flutter/foundation.dart';
import 'package:robandigital/core/utils/service_locator.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/auth_entity.dart';

enum HomeState { initial, loading, success, error }

class HomeProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  HomeState _state = HomeState.initial;
  String? _errorMessage;
  AuthEntity? _authEntity;
  String? _userName;
  String? _userEmail;
  String? _userRole;

  HomeProvider({AuthRepository? authRepository})
      : _authRepository = authRepository ?? getIt<AuthRepository>();

  // Getters
  HomeState get state => _state;
  String? get errorMessage => _errorMessage;
  AuthEntity? get authEntity => _authEntity;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userRole => _userRole;
  bool get isLoading => _state == HomeState.loading;

  /// Initialize and load current user data
  Future<void> initializeUserData() async {
    _state = HomeState.loading;
    _errorMessage = null;
    notifyListeners();

    // First try to get from stored data
    final storedToken = await _authRepository.getStoredToken();
    
    if (storedToken != null && storedToken.isNotEmpty) {
      // Load current user from API
      await loadCurrentUser();
    } else {
      _state = HomeState.error;
      _errorMessage = 'No authentication token found';
      notifyListeners();
    }
  }

  /// Load current user from API
  Future<void> loadCurrentUser() async {
    _state = HomeState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.getCurrentUser();

    result.fold(
      (failure) {
        _state = HomeState.error;
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
      _userName = null;
      _userEmail = null;
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
