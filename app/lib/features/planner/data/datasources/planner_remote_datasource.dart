import 'package:recipe_planner/core/constants/api_constants.dart';
import 'package:recipe_planner/core/constants/app_constants.dart';
import 'package:recipe_planner/core/error/exceptions.dart';
import 'package:recipe_planner/core/network/api_client.dart';
import 'package:recipe_planner/features/planner/data/models/meal_plan_model.dart';

/// Contract for remote data operations related to the Planner feature.
abstract class PlannerRemoteDataSource {
  /// Fetch meal plans for a date range.
  Future<List<MealPlanModel>> getWeekMealPlans({
    required String startDate,
    required String endDate,
  });

  /// Create a meal plan for a specific date.
  Future<MealPlanModel> createMealPlan({required String date});

  /// Add a meal slot to a plan.
  Future<MealSlotModel> addSlot({
    required String planId,
    required MealType mealType,
    String? recipeId,
    String? quickNote,
    int servings = 2,
  });

  /// Update an existing meal slot.
  Future<MealSlotModel> updateSlot({
    required String planId,
    required String slotId,
    MealType? mealType,
    String? recipeId,
    String? quickNote,
    int? servings,
    int? displayOrder,
  });

  /// Remove a meal slot.
  Future<void> removeSlot({
    required String planId,
    required String slotId,
  });
}

/// Implementation using Dio API client.
class PlannerRemoteDataSourceImpl implements PlannerRemoteDataSource {
  final ApiClient apiClient;

  PlannerRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<MealPlanModel>> getWeekMealPlans({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await apiClient.get(
        ApiConstants.mealPlans,
        queryParameters: {
          'start_date': startDate,
          'end_date': endDate,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final plansJson = data['data'] as List<dynamic>;
      return plansJson
          .map((e) => MealPlanModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on Exception catch (e) {
      throw ServerException(message: 'Failed to fetch meal plans: $e');
    }
  }

  @override
  Future<MealPlanModel> createMealPlan({required String date}) async {
    try {
      final response = await apiClient.post(
        ApiConstants.mealPlans,
        data: {'date': date},
      );

      return MealPlanModel.fromJson(
          response.data as Map<String, dynamic>);
    } on Exception catch (e) {
      throw ServerException(message: 'Failed to create meal plan: $e');
    }
  }

  @override
  Future<MealSlotModel> addSlot({
    required String planId,
    required MealType mealType,
    String? recipeId,
    String? quickNote,
    int servings = 2,
  }) async {
    try {
      final body = <String, dynamic>{
        'meal_type': mealType.name,
        'servings': servings,
      };
      if (recipeId != null) body['recipe_id'] = recipeId;
      if (quickNote != null) body['quick_note'] = quickNote;

      final response = await apiClient.post(
        '${ApiConstants.mealPlans}/$planId/slots',
        data: body,
      );

      return MealSlotModel.fromJson(
          response.data as Map<String, dynamic>);
    } on Exception catch (e) {
      throw ServerException(message: 'Failed to add meal slot: $e');
    }
  }

  @override
  Future<MealSlotModel> updateSlot({
    required String planId,
    required String slotId,
    MealType? mealType,
    String? recipeId,
    String? quickNote,
    int? servings,
    int? displayOrder,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (mealType != null) body['meal_type'] = mealType.name;
      if (recipeId != null) body['recipe_id'] = recipeId;
      if (quickNote != null) body['quick_note'] = quickNote;
      if (servings != null) body['servings'] = servings;
      if (displayOrder != null) body['display_order'] = displayOrder;

      final response = await apiClient.put(
        '${ApiConstants.mealPlans}/$planId/slots?slotId=$slotId',
        data: body,
      );

      return MealSlotModel.fromJson(
          response.data as Map<String, dynamic>);
    } on Exception catch (e) {
      throw ServerException(message: 'Failed to update meal slot: $e');
    }
  }

  @override
  Future<void> removeSlot({
    required String planId,
    required String slotId,
  }) async {
    try {
      await apiClient.delete(
        '${ApiConstants.mealPlans}/$planId/slots?slotId=$slotId',
      );
    } on Exception catch (e) {
      throw ServerException(message: 'Failed to remove meal slot: $e');
    }
  }
}
