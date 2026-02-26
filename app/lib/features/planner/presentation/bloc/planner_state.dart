part of 'planner_bloc.dart';

/// Planner feature states.
sealed class PlannerState extends Equatable {
  const PlannerState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded.
class PlannerInitial extends PlannerState {
  const PlannerInitial();
}

/// Loading state while fetching data.
class PlannerLoading extends PlannerState {
  const PlannerLoading();
}

/// Successfully loaded planner data.
class PlannerLoaded extends PlannerState {
  final List<MealPlan> weekPlans;
  final DateTime selectedDate;
  final MealPlan? selectedDayPlan;
  final NutritionSummary nutritionSummary;
  final DateTime weekStart;

  const PlannerLoaded({
    required this.weekPlans,
    required this.selectedDate,
    this.selectedDayPlan,
    this.nutritionSummary = const NutritionSummary(),
    required this.weekStart,
  });

  PlannerLoaded copyWith({
    List<MealPlan>? weekPlans,
    DateTime? selectedDate,
    MealPlan? Function()? selectedDayPlan,
    NutritionSummary? nutritionSummary,
    DateTime? weekStart,
  }) {
    return PlannerLoaded(
      weekPlans: weekPlans ?? this.weekPlans,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedDayPlan:
          selectedDayPlan != null ? selectedDayPlan() : this.selectedDayPlan,
      nutritionSummary: nutritionSummary ?? this.nutritionSummary,
      weekStart: weekStart ?? this.weekStart,
    );
  }

  @override
  List<Object?> get props =>
      [weekPlans, selectedDate, selectedDayPlan, nutritionSummary, weekStart];
}

/// Error state.
class PlannerError extends PlannerState {
  final String message;

  const PlannerError({required this.message});

  @override
  List<Object?> get props => [message];
}
