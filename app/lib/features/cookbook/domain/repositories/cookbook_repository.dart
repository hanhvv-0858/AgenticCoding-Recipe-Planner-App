import 'package:dartz/dartz.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';

/// Abstract repository for the Cookbook feature.
abstract class CookbookRepository {
  /// Get the user's saved recipes with cursor-based pagination.
  Future<Either<Failure, ({List<Recipe> recipes, String? nextCursor, bool hasMore})>>
      getSavedRecipes({String? cursor, int limit = 20});

  /// Save a recipe to the user's cookbook.
  Future<Either<Failure, void>> saveRecipe(String recipeId);

  /// Remove a recipe from the user's cookbook.
  Future<Either<Failure, void>> unsaveRecipe(String recipeId);
}
