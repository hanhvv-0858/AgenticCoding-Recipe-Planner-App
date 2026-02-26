import 'package:equatable/equatable.dart';

/// User domain entity.
class User extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.createdAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, email, displayName, avatarUrl, createdAt];
}
