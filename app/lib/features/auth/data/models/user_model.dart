import 'package:recipe_planner/features/auth/domain/entities/user.dart';

/// User model for JSON serialization.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.avatarUrl,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: (json['email'] as String?) ?? '',
      displayName: json['display_name'] as String? ?? 'User',
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  User toEntity() => User(
        id: id,
        email: email,
        displayName: displayName,
        avatarUrl: avatarUrl,
        createdAt: createdAt,
      );
}
