import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/usecases/usecase.dart';
import 'package:recipe_planner/features/recipe_detail/domain/repositories/recipe_detail_repository.dart';

/// Save a recipe to user's cookbook.
class SaveRecipe extends UseCase<void, SaveRecipeParams> {
  final RecipeDetailRepository repository;

  SaveRecipe(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveRecipeParams params) {
    return repository.saveRecipe(params.recipeId);
  }
}

class SaveRecipeParams extends Equatable {
  final String recipeId;

  const SaveRecipeParams({required this.recipeId});

  @override
  List<Object?> get props => [recipeId];
}
