import 'package:dartz/dartz.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/usecases/usecase.dart';
import 'package:recipe_planner/features/auth/domain/entities/user.dart';
import 'package:recipe_planner/features/auth/domain/repositories/auth_repository.dart';

/// Get the current authenticated user.
class GetCurrentUser extends UseCase<User, NoParams> {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) {
    return repository.getCurrentUser();
  }
}
