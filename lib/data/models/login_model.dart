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
  final UserModel user;

  const LoginResponseModel({
    required this.success,
    required this.token,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle nested data structure if API wraps response
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;
    
    return LoginResponseModel(
      success: data['success'] as bool? ?? true,
      token: data['token'] as String? ?? '',
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'token': token,
      'user': user.toJson(),
    };
  }

  @override
  List<Object?> get props => [success, token, user];
}
