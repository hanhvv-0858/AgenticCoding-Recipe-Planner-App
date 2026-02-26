import 'package:equatable/equatable.dart';
import 'package:recipe_planner/core/constants/app_constants.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';

/// MealSlot domain entity — a single meal within a day's plan.
class MealSlot extends Equatable {
  final String id;
  final MealType mealType;
  final Recipe? recipe;
  final String? quickNote;
  final int servings;
  final int displayOrder;

  const MealSlot({
    required this.id,
    required this.mealType,
    this.recipe,
    this.quickNote,
    this.servings = 2,
    this.displayOrder = 0,
  });

  /// Whether this slot has a recipe assigned.
  bool get hasRecipe => recipe != null;

  /// Whether this slot has a quick note.
  bool get hasQuickNote =>
      quickNote != null && quickNote!.trim().isNotEmpty;

  MealSlot copyWith({
    String? id,
    MealType? mealType,
    Recipe? recipe,
    String? quickNote,
    int? servings,
    int? displayOrder,
  }) {
    return MealSlot(
      id: id ?? this.id,
      mealType: mealType ?? this.mealType,
      recipe: recipe ?? this.recipe,
      quickNote: quickNote ?? this.quickNote,
      servings: servings ?? this.servings,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  @override
  List<Object?> get props => [id];
}
