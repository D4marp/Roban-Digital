import 'package:equatable/equatable.dart';

class LoginRequestModel extends Equatable {
  final String email;
  final String password;
  final String portal;

  const LoginRequestModel({
    required this.email,
    required this.password,
    this.portal = 'MOBILE',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'portal': portal,
    };
  }

  @override
  List<Object?> get props => [email, password, portal];
}

class UserModel extends Equatable {
  final int id;
  final String email;
  final String username;
  final String role;
  final int unitId;
  final String createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    required this.unitId,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      role: json['role'] as String? ?? '',
      unitId: json['unitId'] as int? ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'role': role,
      'unitId': unitId,
      'createdAt': createdAt,
    };
  }

  @override
  List<Object?> get props => [id, email, username, role, unitId, createdAt];
}

class LoginResponseModel extends Equatable {
  final bool success;
  final String token;
  final String refreshToken;
  final UserModel user;

  const LoginResponseModel({
    required this.success,
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle nested data structure if API wraps response
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;
    
    // Debug: log what we're parsing
    print('[LoginResponseModel.fromJson] Parsing data keys: ${data.keys.toList()}');
    print('[LoginResponseModel.fromJson] Full data: $data');
    
    // Handle two different response formats:
    // 1. /auth/login returns: {success, token, refreshToken, user: {...}}
    // 2. /auth/me returns: {id, email, username, role, unitId, createdAt} (user fields directly)
    
    Map<String, dynamic> userData;
    if (data['user'] is Map) {
      // Format 1: user is nested object
      userData = data['user'] as Map<String, dynamic>;
      print('[LoginResponseModel.fromJson] User data from nested object: $userData');
    } else if (data.containsKey('id') && data.containsKey('email')) {
      // Format 2: user data is at root level (from /auth/me)
      userData = data;
      print('[LoginResponseModel.fromJson] User data from root level: $userData');
    } else {
      // Fallback: empty user
      userData = {};
      print('[LoginResponseModel.fromJson] No user data found, using empty map');
    }
    
    final user = UserModel.fromJson(userData);
    print('[LoginResponseModel.fromJson] Parsed user: id=${user.id}, email=${user.email}, username=${user.username}');
    
    return LoginResponseModel(
      success: data['success'] as bool? ?? true,
      token: data['token'] as String? ?? '',
      refreshToken: data['refreshToken'] as String? ?? '',
      user: user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'token': token,
      'refreshToken': refreshToken,
      'user': user.toJson(),
    };
  }

  @override
  List<Object?> get props => [success, token, refreshToken, user];
}
