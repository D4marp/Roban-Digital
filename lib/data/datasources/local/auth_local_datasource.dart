import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userRoleKey = 'user_role';
  static const String _userUsernameKey = 'user_username';

  final SharedPreferences _prefs;

  AuthLocalDataSource({required SharedPreferences prefs}) : _prefs = prefs;

  // Save token after login
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  // Get saved token
  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  // Save user data
  Future<void> saveUserData({
    required int id,
    required String email,
    required String role,
    String? username,
  }) async {
    await _prefs.setInt(_userIdKey, id);
    await _prefs.setString(_userEmailKey, email);
    await _prefs.setString(_userRoleKey, role);
    if (username != null) {
      await _prefs.setString(_userUsernameKey, username);
    }
  }

  // Get user ID
  int? getUserId() {
    return _prefs.getInt(_userIdKey);
  }

  // Get user email
  String? getUserEmail() {
    return _prefs.getString(_userEmailKey);
  }

  // Get user role
  String? getUserRole() {
    return _prefs.getString(_userRoleKey);
  }

  // Get user username
  String? getUsername() {
    return _prefs.getString(_userUsernameKey);
  }

  // Get all user data
  Map<String, dynamic> getUserData() {
    return {
      'id': getUserId(),
      'email': getUserEmail(),
      'role': getUserRole(),
      'username': getUsername(),
    };
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return getToken() != null;
  }

  // Clear all auth data (logout)
  Future<void> clearAll() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_userEmailKey);
    await _prefs.remove(_userRoleKey);
    await _prefs.remove(_userUsernameKey);
  }
}
