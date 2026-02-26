import 'package:dartz/dartz.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/usecases/usecase.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';
import 'package:recipe_planner/features/home/domain/repositories/home_repository.dart';

/// Get the next upcoming meal slot recipe.
class GetNextMealSlot extends UseCase<Recipe?, NoParams> {
  final HomeRepository repository;

  GetNextMealSlot(this.repository);

  @override
  Future<Either<Failure, Recipe?>> call(NoParams params) {
    return repository.getNextMealSlot();
  }
}
