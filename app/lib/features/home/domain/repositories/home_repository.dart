import 'package:dartz/dartz.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';
import 'package:recipe_planner/features/home/domain/entities/tag.dart';

/// HomeRepository abstract class for Clean Architecture.
abstract class HomeRepository {
  /// Search recipes with filters and pagination.
  Future<Either<Failure, ({List<Recipe> recipes, String? nextCursor})>>
      searchRecipes({
    String? query,
    String? tag,
    int? maxTime,
    int? maxCalories,
    String? ingredient,
    String? cursor,
    int limit = 20,
  });

  /// Get trending recipes, optionally filtered by tag.
  Future<Either<Failure, List<Recipe>>> getTrendingRecipes({
    String? tag,
    int limit = 20,
  });

  /// Get all available tags.
  Future<Either<Failure, List<Tag>>> getTags();

  /// Get the next upcoming meal slot (for "Next Meal" card).
  Future<Either<Failure, Recipe?>> getNextMealSlot();
}
