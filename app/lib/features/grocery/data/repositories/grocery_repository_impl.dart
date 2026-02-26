import 'package:dartz/dartz.dart';
import 'package:recipe_planner/core/error/exceptions.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/network/network_info.dart';
import 'package:recipe_planner/features/grocery/data/datasources/grocery_local_datasource.dart';
import 'package:recipe_planner/features/grocery/data/datasources/grocery_remote_datasource.dart';
import 'package:recipe_planner/features/grocery/data/models/grocery_item_model.dart';
import 'package:recipe_planner/features/grocery/domain/entities/grocery_item.dart';
import 'package:recipe_planner/features/grocery/domain/repositories/grocery_repository.dart';

/// Implements GroceryRepository with online/offline data strategy.
///
/// Online: call remote + cache locally.
/// Offline: write to local + add to sync queue.
class GroceryRepositoryImpl implements GroceryRepository {
  final GroceryRemoteDataSource remoteDataSource;
  final GroceryLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  GroceryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  DateTime _parseWeekStart(String weekStart) => DateTime.parse(weekStart);

  @override
  Future<
          Either<Failure,
              ({List<GroceryCategoryGroup> categories, GrocerySummary summary})>>
      getGroceryList({
    required String weekStart,
    bool regenerate = false,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getGroceryList(
          weekStart: weekStart,
          regenerate: regenerate,
        );

        // Flatten items for caching
        final allItems = <GroceryItemModel>[];
        for (final category in result.categories) {
          for (final item in category.items) {
            if (item is GroceryItemModel) {
              allItems.add(item);
            }
          }
        }
        await localDataSource.cacheGroceryList(
            allItems, _parseWeekStart(weekStart));

        return Right((
          categories: result.categories as List<GroceryCategoryGroup>,
          summary: result.summary as GrocerySummary,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final items = await localDataSource.getCachedGroceryItems(
          weekStartDate: _parseWeekStart(weekStart),
        );

        // Group items by category
        final categoryMap = <String, List<GroceryItem>>{};
        for (final item in items) {
          categoryMap.putIfAbsent(item.category, () => []).add(item);
        }

        final categories = categoryMap.entries
            .map((e) => GroceryCategoryGroup(
                  name: e.key,
                  emoji: _getCategoryEmoji(e.key),
                  items: e.value,
                ))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        final totalItems = items.length;
        final checkedItems = items.where((i) => i.isChecked).length;

        return Right((
          categories: categories,
          summary: GrocerySummary(
            totalItems: totalItems,
            checkedItems: checkedItems,
            remainingItems: totalItems - checkedItems,
          ),
        ));
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, GroceryItem>> addManualItem({
    required String name,
    required double quantity,
    required String unit,
    required String category,
    required String weekStart,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final item = await remoteDataSource.addManualItem(
          name: name,
          quantity: quantity,
          unit: unit,
          category: category,
          weekStart: weekStart,
        );
        return Right(item);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final item = await localDataSource.addManualItemLocally(
          name: name,
          quantity: quantity,
          unit: unit,
          category: category,
          weekStartDate: _parseWeekStart(weekStart),
        );
        await localDataSource.enqueueSyncOperation(
          entityType: 'grocery_item',
          entityId: item.id,
          operation: 'create',
          payload: {
            'name': name,
            'quantity': quantity,
            'unit': unit,
            'category': category,
            'week_start': weekStart,
          },
        );
        return Right(item);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, GroceryItem>> toggleItemCheck({
    required String id,
    required bool isChecked,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final item = await remoteDataSource.toggleItemCheck(
          id: id,
          isChecked: isChecked,
        );
        // Update local cache
        await localDataSource.toggleItemCheckLocally(
          id: id,
          isChecked: isChecked,
        );
        return Right(item);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        await localDataSource.toggleItemCheckLocally(
          id: id,
          isChecked: isChecked,
        );
        await localDataSource.enqueueSyncOperation(
          entityType: 'grocery_item',
          entityId: id,
          operation: 'update',
          payload: {'is_checked': isChecked},
        );
        // Return a placeholder — actual data gets synced later
        return Right(GroceryItem(
          id: id,
          name: '',
          quantity: 0,
          unit: '',
          isChecked: isChecked,
        ));
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, void>> deleteItem({required String id}) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteItem(id: id);
        await localDataSource.deleteItemLocally(id: id);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        await localDataSource.deleteItemLocally(id: id);
        await localDataSource.enqueueSyncOperation(
          entityType: 'grocery_item',
          entityId: id,
          operation: 'delete',
          payload: {},
        );
        return const Right(null);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, ({int clearedCount, int remainingCount})>>
      clearCompleted({required String weekStart}) async {
    if (await networkInfo.isConnected) {
      try {
        final result =
            await remoteDataSource.clearCompleted(weekStart: weekStart);
        // Also clear locally
        await localDataSource.clearCompletedLocally(
          weekStartDate: _parseWeekStart(weekStart),
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final result = await localDataSource.clearCompletedLocally(
          weekStartDate: _parseWeekStart(weekStart),
        );
        await localDataSource.enqueueSyncOperation(
          entityType: 'grocery_item',
          entityId: 'clear_$weekStart',
          operation: 'delete',
          payload: {'week_start': weekStart, 'clear_checked': true},
        );
        return Right(result);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, int>> getRemainingCount({
    required String weekStart,
  }) async {
    try {
      final count = await localDataSource.getRemainingCount(
        weekStartDate: _parseWeekStart(weekStart),
      );
      return Right(count);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  static String _getCategoryEmoji(String category) {
    const emojiMap = {
      'Vegetables': '🥦',
      'Fruits': '🍎',
      'Meat/Fish': '🥩',
      'Dairy': '🧀',
      'Spices': '🥫',
      'Grains': '🌾',
      'Canned': '🥫',
      'Frozen': '🧊',
      'Beverages': '🥤',
      'Other': '📦',
    };
    return emojiMap[category] ?? '📦';
  }
}
