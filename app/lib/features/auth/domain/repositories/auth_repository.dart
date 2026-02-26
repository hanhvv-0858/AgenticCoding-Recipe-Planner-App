import 'package:dartz/dartz.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/features/auth/domain/entities/user.dart';

/// Abstract repository for the Auth feature.
abstract class AuthRepository {
  /// Register a new user account.
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String displayName,
  });

  /// Login with email and password.
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Get the current authenticated user.
  Future<Either<Failure, User>> getCurrentUser();

  /// Sign out the current user.
  Future<Either<Failure, void>> logout();

  /// Check if user is currently authenticated.
  Future<bool> isAuthenticated();
}
