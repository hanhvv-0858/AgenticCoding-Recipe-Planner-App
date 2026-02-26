import 'package:recipe_planner/core/constants/api_constants.dart';
import 'package:recipe_planner/core/error/exceptions.dart';
import 'package:recipe_planner/core/network/api_client.dart';
import 'package:recipe_planner/features/home/data/models/recipe_model.dart';
import 'package:recipe_planner/features/home/data/models/tag_model.dart';

/// Contract for remote data operations related to the Home feature.
abstract class HomeRemoteDataSource {
  /// Search recipes with optional filters and pagination.
  Future<({List<RecipeModel> recipes, String? nextCursor})> searchRecipes({
    String? query,
    String? tag,
    int? maxTime,
    int? maxCalories,
    String? ingredient,
    String? cursor,
    int limit = 20,
  });

  /// Fetch trending recipes.
  Future<List<RecipeModel>> getTrendingRecipes({
    String? tag,
    int limit = 20,
  });

  /// Fetch all tags.
  Future<List<TagModel>> getTags();
}

/// Implementation using Dio API client.
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient apiClient;

  HomeRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<({List<RecipeModel> recipes, String? nextCursor})> searchRecipes({
    String? query,
    String? tag,
    int? maxTime,
    int? maxCalories,
    String? ingredient,
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
      };
      if (query != null && query.isNotEmpty) queryParams['q'] = query;
      if (tag != null && tag.isNotEmpty) queryParams['tag'] = tag;
      if (maxTime != null) queryParams['max_time'] = maxTime;
      if (maxCalories != null) queryParams['max_calories'] = maxCalories;
      if (ingredient != null && ingredient.isNotEmpty) {
        queryParams['ingredient'] = ingredient;
      }
      if (cursor != null && cursor.isNotEmpty) queryParams['cursor'] = cursor;

      final response = await apiClient.get(
        ApiConstants.recipes,
        queryParameters: queryParams,
      );

      final data = response.data as Map<String, dynamic>;
      final recipesJson = (data['recipes'] as List<dynamic>?) ?? [];
      final recipes = recipesJson
          .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final nextCursor = data['next_cursor'] as String?;

      return (recipes: recipes, nextCursor: nextCursor);
    } on Exception catch (e) {
      throw ServerException(message: 'Failed to search recipes: $e');
    }
  }

  @override
  Future<List<RecipeModel>> getTrendingRecipes({
    String? tag,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
      };
      if (tag != null && tag.isNotEmpty) queryParams['tag'] = tag;

      final response = await apiClient.get(
        ApiConstants.recipeTrending,
        queryParameters: queryParams,
      );

      final recipesJson = response.data as List<dynamic>;
      return recipesJson
          .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on Exception catch (e) {
      throw ServerException(message: 'Failed to get trending recipes: $e');
    }
  }

  @override
  Future<List<TagModel>> getTags() async {
    try {
      final response = await apiClient.get(ApiConstants.tags);

      final tagsJson = response.data as List<dynamic>;
      return tagsJson
          .map((e) => TagModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on Exception catch (e) {
      throw ServerException(message: 'Failed to get tags: $e');
    }
  }
}
