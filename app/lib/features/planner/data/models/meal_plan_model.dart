import 'package:recipe_planner/core/constants/app_constants.dart';
import 'package:recipe_planner/features/home/data/models/recipe_model.dart';
import 'package:recipe_planner/features/planner/domain/entities/meal_plan.dart';
import 'package:recipe_planner/features/planner/domain/entities/meal_slot.dart';

/// MealSlot model with JSON serialization.
class MealSlotModel extends MealSlot {
  const MealSlotModel({
    required super.id,
    required super.mealType,
    super.recipe,
    super.quickNote,
    super.servings,
    super.displayOrder,
  });

  factory MealSlotModel.fromJson(Map<String, dynamic> json) {
    return MealSlotModel(
      id: json['id'] as String,
      mealType: _parseMealType(json['meal_type'] as String),
      recipe: json['recipe'] != null
          ? RecipeModel.fromJson(json['recipe'] as Map<String, dynamic>)
          : null,
      quickNote: json['quick_note'] as String?,
      servings: json['servings'] as int? ?? 2,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meal_type': mealType.name,
      'recipe': recipe != null
          ? (recipe is RecipeModel
              ? (recipe as RecipeModel).toJson()
              : {
                  'id': recipe!.id,
                  'title': recipe!.title,
                  'cover_image_url': recipe!.coverImageUrl,
                  'cooking_time_minutes': recipe!.cookingTimeMinutes,
                  'calories': recipe!.calories,
                })
          : null,
      'quick_note': quickNote,
      'servings': servings,
      'display_order': displayOrder,
    };
  }

  static MealType _parseMealType(String value) {
    switch (value) {
      case 'breakfast':
        return MealType.breakfast;
      case 'lunch':
        return MealType.lunch;
      case 'dinner':
        return MealType.dinner;
      case 'snack':
        return MealType.snack;
      default:
        return MealType.breakfast;
    }
  }
}

/// MealPlan model with JSON serialization.
class MealPlanModel extends MealPlan {
  const MealPlanModel({
    super.id,
    required super.userId,
    required super.date,
    super.slots,
  });

  factory MealPlanModel.fromJson(Map<String, dynamic> json,
      {String userId = ''}) {
    return MealPlanModel(
      id: json['id'] as String?,
      userId: userId,
      date: DateTime.parse(json['date'] as String),
      slots: (json['slots'] as List<dynamic>?)
              ?.map(
                  (e) => MealSlotModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'slots': slots
          .map((s) => s is MealSlotModel
              ? s.toJson()
              : MealSlotModel(
                  id: s.id,
                  mealType: s.mealType,
                  recipe: s.recipe,
                  quickNote: s.quickNote,
                  servings: s.servings,
                  displayOrder: s.displayOrder,
                ).toJson())
          .toList(),
    };
  }

  /// Format date as YYYY-MM-DD string.
  String get dateString =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
