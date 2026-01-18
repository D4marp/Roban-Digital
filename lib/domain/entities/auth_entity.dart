import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String email;
  final String username;
  final String role;
  final int unitId;
  final String createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    required this.unitId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, username, role, unitId, createdAt];
}

class AuthEntity extends Equatable {
  final bool success;
  final String token;
  final UserEntity user;

  const AuthEntity({
    required this.success,
    required this.token,
    required this.user,
  });

  @override
  List<Object?> get props => [success, token, user];
}
