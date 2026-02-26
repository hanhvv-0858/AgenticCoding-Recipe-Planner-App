import 'package:dartz/dartz.dart';
import 'package:recipe_planner/core/constants/app_constants.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/features/planner/domain/entities/meal_plan.dart';
import 'package:recipe_planner/features/planner/domain/entities/meal_slot.dart';

/// PlannerRepository abstract class for Clean Architecture.
abstract class PlannerRepository {
  /// Get meal plans for a week (start to end date range).
  Future<Either<Failure, List<MealPlan>>> getWeekMealPlans({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Create a meal plan for a specific date.
  Future<Either<Failure, MealPlan>> createMealPlan({
    required DateTime date,
  });

  /// Add a meal slot to a plan (recipe or quick note).
  Future<Either<Failure, MealSlot>> addSlot({
    required String planId,
    required MealType mealType,
    String? recipeId,
    String? quickNote,
    int servings = 2,
  });

  /// Update an existing meal slot.
  Future<Either<Failure, MealSlot>> updateSlot({
    required String planId,
    required String slotId,
    MealType? mealType,
    String? recipeId,
    String? quickNote,
    int? servings,
    int? displayOrder,
  });

  /// Remove a meal slot from a plan.
  Future<Either<Failure, void>> removeSlot({
    required String planId,
    required String slotId,
  });
}
