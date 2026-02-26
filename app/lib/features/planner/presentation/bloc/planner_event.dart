part of 'planner_bloc.dart';

/// Planner feature events.
sealed class PlannerEvent extends Equatable {
  const PlannerEvent();

  @override
  List<Object?> get props => [];
}

/// Load meal plans for the current week.
class LoadWeek extends PlannerEvent {
  final DateTime startDate;

  const LoadWeek({required this.startDate});

  @override
  List<Object?> get props => [startDate];
}

/// Select a specific day in the calendar strip.
class SelectDay extends PlannerEvent {
  final DateTime date;

  const SelectDay({required this.date});

  @override
  List<Object?> get props => [date];
}

/// Add a recipe to a meal slot.
class AddRecipeToSlot extends PlannerEvent {
  final String planId;
  final MealType mealType;
  final String recipeId;
  final int servings;

  const AddRecipeToSlot({
    required this.planId,
    required this.mealType,
    required this.recipeId,
    this.servings = 2,
  });

  @override
  List<Object?> get props => [planId, mealType, recipeId, servings];
}

/// Add a quick note to a meal slot.
class AddQuickNote extends PlannerEvent {
  final String planId;
  final MealType mealType;
  final String note;

  const AddQuickNote({
    required this.planId,
    required this.mealType,
    required this.note,
  });

  @override
  List<Object?> get props => [planId, mealType, note];
}

/// Remove a meal slot.
class RemoveSlot extends PlannerEvent {
  final String planId;
  final String slotId;

  const RemoveSlot({
    required this.planId,
    required this.slotId,
  });

  @override
  List<Object?> get props => [planId, slotId];
}

/// Move a slot to a different meal type (reorder).
class MoveSlot extends PlannerEvent {
  final String planId;
  final String slotId;
  final MealType toMealType;

  const MoveSlot({
    required this.planId,
    required this.slotId,
    required this.toMealType,
  });

  @override
  List<Object?> get props => [planId, slotId, toMealType];
}

/// Create a meal plan for the selected date (if none exists).
class CreatePlan extends PlannerEvent {
  final DateTime date;

  const CreatePlan({required this.date});

  @override
  List<Object?> get props => [date];
}
