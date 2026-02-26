import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/usecases/usecase.dart';
import 'package:recipe_planner/features/recipe_detail/domain/repositories/recipe_detail_repository.dart';

/// Remove a recipe from user's cookbook.
class UnsaveRecipe extends UseCase<void, UnsaveRecipeParams> {
  final RecipeDetailRepository repository;

  UnsaveRecipe(this.repository);

  @override
  Future<Either<Failure, void>> call(UnsaveRecipeParams params) {
    return repository.unsaveRecipe(params.recipeId);
  }
}

class UnsaveRecipeParams extends Equatable {
  final String recipeId;

  const UnsaveRecipeParams({required this.recipeId});

  @override
  List<Object?> get props => [recipeId];
}
