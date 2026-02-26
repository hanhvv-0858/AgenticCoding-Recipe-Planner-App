import 'package:recipe_planner/core/constants/api_constants.dart';
import 'package:recipe_planner/core/error/exceptions.dart';
import 'package:recipe_planner/core/network/api_client.dart';
import 'package:recipe_planner/features/home/data/models/recipe_model.dart';

/// Contract for remote data operations for Recipe Detail.
abstract class RecipeDetailRemoteDataSource {
  Future<RecipeModel> getRecipeById(String id);
  Future<void> saveRecipe(String recipeId);
  Future<void> unsaveRecipe(String recipeId);
}

/// Implementation using Dio API client.
class RecipeDetailRemoteDataSourceImpl implements RecipeDetailRemoteDataSource {
  final ApiClient apiClient;

  RecipeDetailRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<RecipeModel> getRecipeById(String id) async {
    try {
      final response = await apiClient.get('${ApiConstants.recipeDetail}/$id');
      final data = response.data as Map<String, dynamic>;
      return RecipeModel.fromJson(data);
    } on Exception catch (e) {
      throw ServerException(message: 'Failed to get recipe detail: $e');
    }
  }

  @override
  Future<void> saveRecipe(String recipeId) async {
    try {
      await apiClient.post('${ApiConstants.cookbook}/$recipeId');
    } on Exception catch (e) {
      throw ServerException(message: 'Failed to save recipe: $e');
    }
  }

  @override
  Future<void> unsaveRecipe(String recipeId) async {
    try {
      await apiClient.delete('${ApiConstants.cookbook}/$recipeId');
    } on Exception catch (e) {
      throw ServerException(message: 'Failed to unsave recipe: $e');
    }
  }
}
