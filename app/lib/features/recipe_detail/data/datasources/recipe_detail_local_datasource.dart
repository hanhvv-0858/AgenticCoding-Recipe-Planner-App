import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:recipe_planner/core/database/app_database.dart';
import 'package:recipe_planner/core/error/exceptions.dart';
import 'package:recipe_planner/features/home/data/models/recipe_model.dart';

/// Contract for local data operations for Recipe Detail.
abstract class RecipeDetailLocalDataSource {
  Future<RecipeModel?> getCachedRecipe(String id);
  Future<void> cacheRecipe(RecipeModel recipe);
  Future<void> updateSavedStatus(String recipeId, {required bool isSaved});
}

/// Implementation using drift (SQLite) database.
class RecipeDetailLocalDataSourceImpl implements RecipeDetailLocalDataSource {
  final AppDatabase database;

  RecipeDetailLocalDataSourceImpl({required this.database});

  @override
  Future<RecipeModel?> getCachedRecipe(String id) async {
    try {
      final row = await (database.select(database.cachedRecipes)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      if (row == null) return null;

      final json = jsonDecode(row.data) as Map<String, dynamic>;
      return RecipeModel.fromJson(json);
    } on Exception catch (e) {
      throw CacheException(message: 'Failed to get cached recipe: $e');
    }
  }

  @override
  Future<void> cacheRecipe(RecipeModel recipe) async {
    try {
      await database.into(database.cachedRecipes).insertOnConflictUpdate(
            CachedRecipesCompanion.insert(
              id: recipe.id,
              data: jsonEncode(recipe.toJson()),
              cachedAt: DateTime.now().millisecondsSinceEpoch,
              isSaved: Value(recipe.isSaved),
            ),
          );
    } on Exception catch (e) {
      throw CacheException(message: 'Failed to cache recipe: $e');
    }
  }

  @override
  Future<void> updateSavedStatus(
    String recipeId, {
    required bool isSaved,
  }) async {
    try {
      await (database.update(database.cachedRecipes)
            ..where((t) => t.id.equals(recipeId)))
          .write(CachedRecipesCompanion(isSaved: Value(isSaved)));
    } on Exception catch (e) {
      throw CacheException(message: 'Failed to update saved status: $e');
    }
  }
}
