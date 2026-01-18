import 'package:flutter/foundation.dart';
import 'package:robandigital/domain/repositories/auth_repository.dart';


class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;
  
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this.authRepository);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
}
