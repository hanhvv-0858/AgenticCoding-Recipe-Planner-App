import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:recipe_planner/core/database/app_database.dart';
import 'package:recipe_planner/core/error/exceptions.dart';
import 'package:recipe_planner/features/home/data/models/recipe_model.dart';
import 'package:recipe_planner/features/home/data/models/tag_model.dart';

/// Contract for local data operations related to the Home feature.
abstract class HomeLocalDataSource {
  /// Cache a list of recipes locally.
  Future<void> cacheRecipes(List<RecipeModel> recipes);

  /// Get cached trending recipes.
  Future<List<RecipeModel>> getCachedTrendingRecipes();

  /// Cache tags locally.
  Future<void> cacheTags(List<TagModel> tags);

  /// Get cached tags.
  Future<List<TagModel>> getCachedTags();

  /// Get a specific cached recipe by ID.
  Future<RecipeModel?> getCachedRecipe(String id);
}

/// Implementation using drift (SQLite) database.
class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final AppDatabase database;

  /// Key used to store tags in the cached_recipes table as a special entry.
  static const String _tagsKey = '__tags__';

  HomeLocalDataSourceImpl({required this.database});

  @override
  Future<void> cacheRecipes(List<RecipeModel> recipes) async {
    try {
      await database.batch((batch) {
        for (final recipe in recipes) {
          batch.insert(
            database.cachedRecipes,
            CachedRecipesCompanion.insert(
              id: recipe.id,
              data: jsonEncode(recipe.toJson()),
              cachedAt: DateTime.now().millisecondsSinceEpoch,
              isSaved: Value(recipe.isSaved),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    } on Exception catch (e) {
      throw CacheException(message: 'Failed to cache recipes: $e');
    }
  }

  @override
  Future<List<RecipeModel>> getCachedTrendingRecipes() async {
    try {
      final rows = await (database.select(database.cachedRecipes)
            ..where((t) => t.id.equals(_tagsKey).not())
            ..orderBy([
              (t) => OrderingTerm.desc(t.cachedAt),
            ])
            ..limit(20))
          .get();

      return rows.map((row) {
        final json = jsonDecode(row.data) as Map<String, dynamic>;
        return RecipeModel.fromJson(json);
      }).toList();
    } on Exception catch (e) {
      throw CacheException(message: 'Failed to get cached recipes: $e');
    }
  }

  @override
  Future<void> cacheTags(List<TagModel> tags) async {
    try {
      final tagsJson = tags.map((t) => t.toJson()).toList();
      await database.into(database.cachedRecipes).insertOnConflictUpdate(
            CachedRecipesCompanion.insert(
              id: _tagsKey,
              data: jsonEncode(tagsJson),
              cachedAt: DateTime.now().millisecondsSinceEpoch,
            ),
          );
    } on Exception catch (e) {
      throw CacheException(message: 'Failed to cache tags: $e');
    }
  }

  @override
  Future<List<TagModel>> getCachedTags() async {
    try {
      final row = await (database.select(database.cachedRecipes)
            ..where((t) => t.id.equals(_tagsKey)))
          .getSingleOrNull();

      if (row == null) return [];

      final tagsJson = jsonDecode(row.data) as List<dynamic>;
      return tagsJson
          .map((e) => TagModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on Exception catch (e) {
      throw CacheException(message: 'Failed to get cached tags: $e');
    }
  }

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
}
