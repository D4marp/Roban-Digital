import 'package:flutter/material.dart';
import 'package:robandigital/core/utils/service_locator.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/entities/auth_entity.dart';


enum LoginState { initial, loading, success, error }

class LoginProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;

  LoginState _state = LoginState.initial;
  String? _errorMessage;
  AuthEntity? _authEntity;

  LoginProvider({LoginUseCase? loginUseCase})
      : _loginUseCase = loginUseCase ?? getIt<LoginUseCase>();

  // Getters
  LoginState get state => _state;
  String? get errorMessage => _errorMessage;
  AuthEntity? get authEntity => _authEntity;
  bool get isLoading => _state == LoginState.loading;

  Future<void> login({
    required String email,
    required String password,
    String portal = 'MOBILE',
  }) async {
    _state = LoginState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _loginUseCase(
      email: email,
      password: password,
      portal: portal,
    );

    result.fold(
      (failure) {
        _state = LoginState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (authEntity) {
        _state = LoginState.success;
        _authEntity = authEntity;
        notifyListeners();
      },
    );
  }

  void reset() {
    _state = LoginState.initial;
    _errorMessage = null;
    _authEntity = null;
    notifyListeners();
  }
}
