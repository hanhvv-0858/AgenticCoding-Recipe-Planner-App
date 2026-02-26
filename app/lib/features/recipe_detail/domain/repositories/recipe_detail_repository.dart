import 'package:dartz/dartz.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';

/// RecipeDetailRepository abstract class for Clean Architecture.
abstract class RecipeDetailRepository {
  /// Get full recipe detail by ID.
  Future<Either<Failure, Recipe>> getRecipeById(String id);

  /// Save recipe to user's cookbook.
  Future<Either<Failure, void>> saveRecipe(String recipeId);

  /// Remove recipe from user's cookbook.
  Future<Either<Failure, void>> unsaveRecipe(String recipeId);
}
