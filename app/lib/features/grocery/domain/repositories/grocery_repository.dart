import 'package:dartz/dartz.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/features/grocery/domain/entities/grocery_item.dart';

/// Abstract repository for the Grocery feature.
abstract class GroceryRepository {
  /// Fetch the grocery list for a given week.
  /// If [regenerate] is true, forces regeneration from the current meal plan.
  Future<Either<Failure, ({List<GroceryCategoryGroup> categories, GrocerySummary summary})>>
      getGroceryList({
    required String weekStart,
    bool regenerate = false,
  });

  /// Manually add a custom grocery item.
  Future<Either<Failure, GroceryItem>> addManualItem({
    required String name,
    required double quantity,
    required String unit,
    required String category,
    required String weekStart,
  });

  /// Toggle the checked/purchased status of a grocery item.
  Future<Either<Failure, GroceryItem>> toggleItemCheck({
    required String id,
    required bool isChecked,
  });

  /// Delete a single grocery item.
  Future<Either<Failure, void>> deleteItem({required String id});

  /// Clear all checked items for a specific week.
  /// Returns (cleared_count, remaining_count).
  Future<Either<Failure, ({int clearedCount, int remainingCount})>>
      clearCompleted({required String weekStart});

  /// Get the count of remaining (unchecked) items for badge display.
  Future<Either<Failure, int>> getRemainingCount({required String weekStart});
}
