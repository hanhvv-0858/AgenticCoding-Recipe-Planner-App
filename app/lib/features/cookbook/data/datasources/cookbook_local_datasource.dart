import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:recipe_planner/core/database/app_database.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';

/// Abstract data source for cookbook local (offline) operations.
abstract class CookbookLocalDataSource {
  /// Cache a recipe as saved in the local cookbook.
  Future<void> cacheAsSaved(String recipeId);

  /// Remove a recipe from the local cookbook.
  Future<void> removeFromSaved(String recipeId);

  /// Get all locally saved recipe ids.
  Future<List<String>> getSavedRecipeIds();

  /// Check if a recipe is saved locally.
  Future<bool> isRecipeSaved(String recipeId);

  /// Get saved recipes from cache (for offline use).
  Future<List<Recipe>> getCachedSavedRecipes();

  /// Enqueue a sync operation for save/unsave.
  Future<void> enqueueSyncOperation({
    required String recipeId,
    required String operation,
  });
}

/// Implementation using drift database.
class CookbookLocalDataSourceImpl implements CookbookLocalDataSource {
  final AppDatabase database;

  CookbookLocalDataSourceImpl({required this.database});

  @override
  Future<void> cacheAsSaved(String recipeId) async {
    await database.into(database.localCookbooks).insertOnConflictUpdate(
          LocalCookbooksCompanion.insert(
            recipeId: recipeId,
            savedAt: DateTime.now().millisecondsSinceEpoch,
            isSynced: const Value(true),
          ),
        );

    // Also update the cached recipe's isSaved flag
    await (database.update(database.cachedRecipes)
          ..where((r) => r.id.equals(recipeId)))
        .write(const CachedRecipesCompanion(isSaved: Value(true)));
  }

  @override
  Future<void> removeFromSaved(String recipeId) async {
    await (database.delete(database.localCookbooks)
          ..where((c) => c.recipeId.equals(recipeId)))
        .go();

    // Update cached recipe
    await (database.update(database.cachedRecipes)
          ..where((r) => r.id.equals(recipeId)))
        .write(const CachedRecipesCompanion(isSaved: Value(false)));
  }

  @override
  Future<List<String>> getSavedRecipeIds() async {
    final rows = await database.select(database.localCookbooks).get();
    return rows.map((r) => r.recipeId).toList();
  }

  @override
  Future<bool> isRecipeSaved(String recipeId) async {
    final row = await (database.select(database.localCookbooks)
          ..where((c) => c.recipeId.equals(recipeId)))
        .getSingleOrNull();
    return row != null;
  }

  @override
  Future<List<Recipe>> getCachedSavedRecipes() async {
    final savedIds = await getSavedRecipeIds();
    if (savedIds.isEmpty) return [];

    final rows = await (database.select(database.cachedRecipes)
          ..where((r) => r.id.isIn(savedIds)))
        .get();

    return rows.map((row) {
      final data = jsonDecode(row.data) as Map<String, dynamic>;
      return Recipe(
        id: row.id,
        title: data['title'] as String? ?? 'Unknown',
        coverImageUrl: data['cover_image_url'] as String?,
        cookingTimeMinutes: data['cooking_time_minutes'] as int? ?? 0,
        calories: data['calories'] as int?,
        rating: (data['rating'] as num?)?.toDouble(),
        isSaved: true,
      );
    }).toList();
  }

  @override
  Future<void> enqueueSyncOperation({
    required String recipeId,
    required String operation,
  }) async {
    await database.into(database.syncQueueEntries).insert(
          SyncQueueEntriesCompanion.insert(
            entityType: 'cookbook',
            entityId: recipeId,
            operation: operation,
            payload: jsonEncode({'recipe_id': recipeId}),
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }
}
