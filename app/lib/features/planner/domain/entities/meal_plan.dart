import 'package:equatable/equatable.dart';
import 'package:recipe_planner/core/constants/app_constants.dart';
import 'package:recipe_planner/features/planner/domain/entities/meal_slot.dart';

/// Nutrition summary computed from meal slots.
class NutritionSummary extends Equatable {
  final int calories;
  final double proteinGrams;
  final double carbsGrams;

  const NutritionSummary({
    this.calories = 0,
    this.proteinGrams = 0,
    this.carbsGrams = 0,
  });

  @override
  List<Object?> get props => [calories, proteinGrams, carbsGrams];
}

/// MealPlan domain entity — a single day's meal plan.
class MealPlan extends Equatable {
  final String? id;
  final String userId;
  final DateTime date;
  final List<MealSlot> slots;

  const MealPlan({
    this.id,
    required this.userId,
    required this.date,
    this.slots = const [],
  });

  /// Computed property: total nutrition for the day.
  NutritionSummary get nutritionSummary {
    int totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;

    for (final slot in slots) {
      if (slot.recipe != null) {
        totalCalories += slot.recipe!.calories ?? 0;
        totalProtein += slot.recipe!.proteinGrams ?? 0;
        totalCarbs += slot.recipe!.carbsGrams ?? 0;
      }
    }

    return NutritionSummary(
      calories: totalCalories,
      proteinGrams: totalProtein,
      carbsGrams: totalCarbs,
    );
  }

  /// Get slots filtered by meal type.
  List<MealSlot> slotsByType(MealType type) =>
      slots.where((s) => s.mealType == type).toList();

  MealPlan copyWith({
    String? id,
    String? userId,
    DateTime? date,
    List<MealSlot>? slots,
  }) {
    return MealPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      slots: slots ?? this.slots,
    );
  }

  @override
  List<Object?> get props => [id];
}
