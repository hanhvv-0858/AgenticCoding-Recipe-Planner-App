import 'package:recipe_planner/core/constants/api_constants.dart';
import 'package:recipe_planner/core/error/exceptions.dart';
import 'package:recipe_planner/core/network/api_client.dart';
import 'package:recipe_planner/features/home/data/models/recipe_model.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';

/// Abstract data source for cookbook remote operations.
abstract class CookbookRemoteDataSource {
  /// Fetch saved recipes with pagination.
  Future<({List<Recipe> recipes, String? nextCursor, bool hasMore})>
      getSavedRecipes({String? cursor, int limit = 20});

  /// Save a recipe to the cookbook.
  Future<void> saveRecipe(String recipeId);

  /// Unsave a recipe from the cookbook.
  Future<void> unsaveRecipe(String recipeId);
}

/// Implementation using ApiClient (Dio).
class CookbookRemoteDataSourceImpl implements CookbookRemoteDataSource {
  final ApiClient apiClient;

  CookbookRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<({List<Recipe> recipes, String? nextCursor, bool hasMore})>
      getSavedRecipes({String? cursor, int limit = 20}) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit};
      if (cursor != null) queryParams['cursor'] = cursor;

      final response = await apiClient.get(
        ApiConstants.cookbook,
        queryParameters: queryParams,
      );
      final data = response.data as Map<String, dynamic>;

      final recipesJson = (data['data'] as List?) ?? [];
      final recipes = recipesJson.map((json) {
        // Response includes saved_at at top level; build recipe from it
        final recipeMap = Map<String, dynamic>.from(json as Map);
        // Ensure isSaved is true for cookbook items
        recipeMap['is_saved'] = true;
        return RecipeModel.fromJson(recipeMap);
      }).toList();

      final pagination =
          data['pagination'] as Map<String, dynamic>? ?? {};

      return (
        recipes: recipes,
        nextCursor: pagination['next_cursor'] as String?,
        hasMore: pagination['has_more'] as bool? ?? false,
      );
    } catch (e) {
      throw ServerException(message: 'Failed to fetch saved recipes: $e');
    }
  }

  @override
  Future<void> saveRecipe(String recipeId) async {
    try {
      await apiClient.post('${ApiConstants.cookbook}/$recipeId');
    } catch (e) {
      throw ServerException(message: 'Failed to save recipe: $e');
    }
  }

  @override
  Future<void> unsaveRecipe(String recipeId) async {
    try {
      await apiClient.delete('${ApiConstants.cookbook}/$recipeId');
    } catch (e) {
      throw ServerException(message: 'Failed to unsave recipe: $e');
    }
  }
}
