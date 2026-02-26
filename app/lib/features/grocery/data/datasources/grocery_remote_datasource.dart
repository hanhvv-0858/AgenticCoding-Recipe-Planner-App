import 'package:recipe_planner/core/constants/api_constants.dart';
import 'package:recipe_planner/core/error/exceptions.dart';
import 'package:recipe_planner/core/network/api_client.dart';
import 'package:recipe_planner/features/grocery/data/models/grocery_item_model.dart';

/// Contract for remote data operations related to the Grocery feature.
abstract class GroceryRemoteDataSource {
  /// Fetch the grocery list for a week, optionally regenerating.
  Future<
      ({
        List<GroceryCategoryGroupModel> categories,
        GrocerySummaryModel summary,
      })> getGroceryList({
    required String weekStart,
    bool regenerate = false,
  });

  /// Manually add a grocery item.
  Future<GroceryItemModel> addManualItem({
    required String name,
    required double quantity,
    required String unit,
    required String category,
    required String weekStart,
  });

  /// Toggle is_checked on a grocery item.
  Future<GroceryItemModel> toggleItemCheck({
    required String id,
    required bool isChecked,
  });

  /// Delete a grocery item.
  Future<void> deleteItem({required String id});

  /// Clear all checked items for a week.
  Future<({int clearedCount, int remainingCount})> clearCompleted({
    required String weekStart,
  });
}

/// Implementation using Dio API client.
class GroceryRemoteDataSourceImpl implements GroceryRemoteDataSource {
  final ApiClient apiClient;

  GroceryRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<
      ({
        List<GroceryCategoryGroupModel> categories,
        GrocerySummaryModel summary,
      })> getGroceryList({
    required String weekStart,
    bool regenerate = false,
  }) async {
    try {
      final response = await apiClient.get(
        ApiConstants.grocery,
        queryParameters: {
          'week_start': weekStart,
          if (regenerate) 'regenerate': 'true',
        },
      );

      final data = response.data as Map<String, dynamic>;
      final categoriesJson = data['categories'] as List<dynamic>? ?? [];
      final summaryJson =
          data['summary'] as Map<String, dynamic>? ?? {};

      return (
        categories: categoriesJson
            .map((e) =>
                GroceryCategoryGroupModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        summary: GrocerySummaryModel.fromJson(summaryJson),
      );
    } on Exception catch (e) {
      throw ServerException(message: 'Failed to fetch grocery list: $e');
    }
  }

  @override
  Future<GroceryItemModel> addManualItem({
    required String name,
    required double quantity,
    required String unit,
    required String category,
    required String weekStart,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.grocery,
        data: {
          'name': name,
          'quantity': quantity,
          'unit': unit,
          'category': category,
          'week_start': weekStart,
        },
      );

      return GroceryItemModel.fromJson(
          response.data as Map<String, dynamic>);
    } on Exception catch (e) {
      throw ServerException(message: 'Failed to add grocery item: $e');
    }
  }

  @override
  Future<GroceryItemModel> toggleItemCheck({
    required String id,
    required bool isChecked,
  }) async {
    try {
      final response = await apiClient.patch(
        '${ApiConstants.grocery}/$id',
        data: {'is_checked': isChecked},
      );

      return GroceryItemModel.fromJson(
          response.data as Map<String, dynamic>);
    } on Exception catch (e) {
      throw ServerException(message: 'Failed to toggle grocery item: $e');
    }
  }

  @override
  Future<void> deleteItem({required String id}) async {
    try {
      await apiClient.delete('${ApiConstants.grocery}/$id');
    } on Exception catch (e) {
      throw ServerException(message: 'Failed to delete grocery item: $e');
    }
  }

  @override
  Future<({int clearedCount, int remainingCount})> clearCompleted({
    required String weekStart,
  }) async {
    try {
      final response = await apiClient.delete(
        ApiConstants.groceryClear,
        queryParameters: {'week_start': weekStart},
      );

      final data = response.data as Map<String, dynamic>;
      return (
        clearedCount: data['cleared_count'] as int? ?? 0,
        remainingCount: data['remaining_count'] as int? ?? 0,
      );
    } on Exception catch (e) {
      throw ServerException(message: 'Failed to clear completed items: $e');
    }
  }
}
