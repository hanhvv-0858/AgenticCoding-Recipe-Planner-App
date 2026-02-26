import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:recipe_planner/core/database/app_database.dart';
import 'package:recipe_planner/core/error/exceptions.dart';
import 'package:recipe_planner/features/grocery/data/models/grocery_item_model.dart';
import 'package:uuid/uuid.dart';

/// Contract for local data operations related to the Grocery feature.
abstract class GroceryLocalDataSource {
  /// Cache the grocery list locally.
  Future<void> cacheGroceryList(
      List<GroceryItemModel> items, DateTime weekStartDate);

  /// Get cached grocery items for a week.
  Future<List<GroceryItemModel>> getCachedGroceryItems({
    required DateTime weekStartDate,
  });

  /// Toggle is_checked on a local grocery item.
  Future<void> toggleItemCheckLocally({
    required String id,
    required bool isChecked,
  });

  /// Add a manual grocery item locally (for offline).
  Future<GroceryItemModel> addManualItemLocally({
    required String name,
    required double quantity,
    required String unit,
    required String category,
    required DateTime weekStartDate,
  });

  /// Delete a grocery item locally.
  Future<void> deleteItemLocally({required String id});

  /// Clear all checked items locally for a week.
  Future<({int clearedCount, int remainingCount})> clearCompletedLocally({
    required DateTime weekStartDate,
  });

  /// Get remaining (unchecked) item count.
  Future<int> getRemainingCount({required DateTime weekStartDate});

  /// Enqueue a sync operation.
  Future<void> enqueueSyncOperation({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
  });
}

/// Implementation using drift (SQLite) database.
class GroceryLocalDataSourceImpl implements GroceryLocalDataSource {
  final AppDatabase database;

  GroceryLocalDataSourceImpl({required this.database});

  @override
  Future<void> cacheGroceryList(
      List<GroceryItemModel> items, DateTime weekStartDate) async {
    try {
      await database.batch((batch) {
        // Clear existing for the week first
        // Then insert new items
        for (final item in items) {
          batch.insert(
            database.localGroceryItems,
            LocalGroceryItemsCompanion.insert(
              id: item.id,
              name: item.name,
              quantity: item.quantity,
              unit: item.unit,
              category: Value(item.category),
              sourceRecipes: Value(jsonEncode(item.sourceRecipes)),
              isChecked: Value(item.isChecked),
              isManual: Value(item.isManual),
              weekStartDate: weekStartDate,
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    } on Exception catch (e) {
      throw CacheException(message: 'Failed to cache grocery list: $e');
    }
  }

  @override
  Future<List<GroceryItemModel>> getCachedGroceryItems({
    required DateTime weekStartDate,
  }) async {
    try {
      final query = database.select(database.localGroceryItems)
        ..where((t) => t.weekStartDate.equals(weekStartDate))
        ..orderBy([
          (t) => OrderingTerm.asc(t.category),
          (t) => OrderingTerm.asc(t.name),
        ]);

      final rows = await query.get();

      return rows
          .map((row) => GroceryItemModel(
                id: row.id,
                name: row.name,
                quantity: row.quantity,
                unit: row.unit,
                category: row.category,
                sourceRecipes: _parseSourceRecipes(row.sourceRecipes),
                isChecked: row.isChecked,
                isManual: row.isManual,
              ))
          .toList();
    } on Exception catch (e) {
      throw CacheException(message: 'Failed to get cached grocery items: $e');
    }
  }

  @override
  Future<void> toggleItemCheckLocally({
    required String id,
    required bool isChecked,
  }) async {
    try {
      await (database.update(database.localGroceryItems)
            ..where((t) => t.id.equals(id)))
          .write(LocalGroceryItemsCompanion(
        isChecked: Value(isChecked),
        isSynced: const Value(false),
      ));
    } on Exception catch (e) {
      throw CacheException(
          message: 'Failed to toggle grocery item locally: $e');
    }
  }

  @override
  Future<GroceryItemModel> addManualItemLocally({
    required String name,
    required double quantity,
    required String unit,
    required String category,
    required DateTime weekStartDate,
  }) async {
    try {
      final id = const Uuid().v4();

      await database.into(database.localGroceryItems).insert(
            LocalGroceryItemsCompanion.insert(
              id: id,
              name: name,
              quantity: quantity,
              unit: unit,
              category: Value(category),
              sourceRecipes: const Value('[]'),
              isChecked: const Value(false),
              isManual: const Value(true),
              weekStartDate: weekStartDate,
              isSynced: const Value(false),
            ),
          );

      return GroceryItemModel(
        id: id,
        name: name,
        quantity: quantity,
        unit: unit,
        category: category,
        sourceRecipes: const [],
        isChecked: false,
        isManual: true,
      );
    } on Exception catch (e) {
      throw CacheException(
          message: 'Failed to add manual grocery item locally: $e');
    }
  }

  @override
  Future<void> deleteItemLocally({required String id}) async {
    try {
      await (database.delete(database.localGroceryItems)
            ..where((t) => t.id.equals(id)))
          .go();
    } on Exception catch (e) {
      throw CacheException(
          message: 'Failed to delete grocery item locally: $e');
    }
  }

  @override
  Future<({int clearedCount, int remainingCount})> clearCompletedLocally({
    required DateTime weekStartDate,
  }) async {
    try {
      // Count checked items
      final checkedQuery = database.select(database.localGroceryItems)
        ..where((t) =>
            t.weekStartDate.equals(weekStartDate) & t.isChecked.equals(true));
      final checkedItems = await checkedQuery.get();
      final clearedCount = checkedItems.length;

      // Delete checked items
      await (database.delete(database.localGroceryItems)
            ..where((t) =>
                t.weekStartDate.equals(weekStartDate) &
                t.isChecked.equals(true)))
          .go();

      // Count remaining
      final remainingQuery = database.select(database.localGroceryItems)
        ..where((t) => t.weekStartDate.equals(weekStartDate));
      final remainingItems = await remainingQuery.get();

      return (
        clearedCount: clearedCount,
        remainingCount: remainingItems.length,
      );
    } on Exception catch (e) {
      throw CacheException(
          message: 'Failed to clear completed items locally: $e');
    }
  }

  @override
  Future<int> getRemainingCount({required DateTime weekStartDate}) async {
    try {
      final query = database.select(database.localGroceryItems)
        ..where((t) =>
            t.weekStartDate.equals(weekStartDate) &
            t.isChecked.equals(false));
      final items = await query.get();
      return items.length;
    } on Exception catch (e) {
      throw CacheException(
          message: 'Failed to get remaining count: $e');
    }
  }

  @override
  Future<void> enqueueSyncOperation({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    try {
      await database.into(database.syncQueueEntries).insert(
            SyncQueueEntriesCompanion.insert(
              entityType: entityType,
              entityId: entityId,
              operation: operation,
              payload: jsonEncode(payload),
              createdAt: DateTime.now().millisecondsSinceEpoch,
            ),
          );
    } on Exception catch (e) {
      throw CacheException(
          message: 'Failed to enqueue sync operation: $e');
    }
  }

  List<String> _parseSourceRecipes(String json) {
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((e) => e as String).toList();
    } catch (_) {
      return [];
    }
  }
}
