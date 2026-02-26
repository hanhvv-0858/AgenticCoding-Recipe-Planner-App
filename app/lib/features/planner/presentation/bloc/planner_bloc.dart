import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_planner/core/constants/app_constants.dart';
import 'package:recipe_planner/features/planner/domain/entities/meal_plan.dart';
import 'package:recipe_planner/features/planner/domain/usecases/add_meal_slot.dart';
import 'package:recipe_planner/features/planner/domain/usecases/create_meal_plan.dart';
import 'package:recipe_planner/features/planner/domain/usecases/get_week_meal_plans.dart';
import 'package:recipe_planner/features/planner/domain/usecases/remove_meal_slot.dart';
import 'package:recipe_planner/features/planner/domain/usecases/update_meal_slot.dart';

part 'planner_event.dart';
part 'planner_state.dart';

/// BLoC for the Planner feature — weekly meal planning.
class PlannerBloc extends Bloc<PlannerEvent, PlannerState> {
  final GetWeekMealPlans getWeekMealPlans;
  final CreateMealPlan createMealPlan;
  final AddMealSlot addMealSlot;
  final UpdateMealSlot updateMealSlot;
  final RemoveMealSlot removeMealSlot;

  PlannerBloc({
    required this.getWeekMealPlans,
    required this.createMealPlan,
    required this.addMealSlot,
    required this.updateMealSlot,
    required this.removeMealSlot,
  }) : super(const PlannerInitial()) {
    on<LoadWeek>(_onLoadWeek);
    on<SelectDay>(_onSelectDay);
    on<AddRecipeToSlot>(_onAddRecipeToSlot);
    on<AddQuickNote>(_onAddQuickNote);
    on<RemoveSlot>(_onRemoveSlot);
    on<MoveSlot>(_onMoveSlot);
    on<CreatePlan>(_onCreatePlan);
  }

  /// Get the Monday of the week containing [date].
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday; // 1=Mon, 7=Sun
    return DateTime(date.year, date.month, date.day - (weekday - 1));
  }

  /// Get the Sunday of the week containing [date].
  DateTime _getWeekEnd(DateTime date) {
    final weekStart = _getWeekStart(date);
    return weekStart.add(const Duration(days: 6));
  }

  Future<void> _onLoadWeek(
    LoadWeek event,
    Emitter<PlannerState> emit,
  ) async {
    emit(const PlannerLoading());

    final weekStart = _getWeekStart(event.startDate);
    final weekEnd = _getWeekEnd(event.startDate);

    final result = await getWeekMealPlans(
      GetWeekMealPlansParams(startDate: weekStart, endDate: weekEnd),
    );

    result.fold(
      (failure) {
        // Show empty planner if user is not authenticated (401)
        if (failure.message.contains('401')) {
          emit(PlannerLoaded(
            weekPlans: const [],
            selectedDate: weekStart,
            weekStart: weekStart,
          ));
        } else {
          emit(PlannerError(message: failure.message));
        }
      },
      (plans) {
        final today = DateTime.now();
        // Default to today if in the loaded week, otherwise to week start
        final selectedDate =
            (today.isAfter(weekStart) || _isSameDay(today, weekStart)) &&
                    (today.isBefore(weekEnd) || _isSameDay(today, weekEnd))
                ? DateTime(today.year, today.month, today.day)
                : weekStart;

        final selectedDayPlan = _findPlanForDate(plans, selectedDate);

        emit(PlannerLoaded(
          weekPlans: plans,
          selectedDate: selectedDate,
          selectedDayPlan: selectedDayPlan,
          nutritionSummary:
              selectedDayPlan?.nutritionSummary ?? const NutritionSummary(),
          weekStart: weekStart,
        ));
      },
    );
  }

  void _onSelectDay(
    SelectDay event,
    Emitter<PlannerState> emit,
  ) {
    if (state is PlannerLoaded) {
      final currentState = state as PlannerLoaded;
      final selectedPlan =
          _findPlanForDate(currentState.weekPlans, event.date);

      emit(currentState.copyWith(
        selectedDate: event.date,
        selectedDayPlan: () => selectedPlan,
        nutritionSummary:
            selectedPlan?.nutritionSummary ?? const NutritionSummary(),
      ));
    }
  }

  Future<void> _onAddRecipeToSlot(
    AddRecipeToSlot event,
    Emitter<PlannerState> emit,
  ) async {
    if (state is! PlannerLoaded) return;
    final currentState = state as PlannerLoaded;

    final result = await addMealSlot(AddMealSlotParams(
      planId: event.planId,
      mealType: event.mealType,
      recipeId: event.recipeId,
      servings: event.servings,
    ));

    result.fold(
      (failure) {
        if (!failure.message.contains('401')) {
          emit(PlannerError(message: failure.message));
        }
      },
      (slot) {
        // Reload the week to get fresh data
        add(LoadWeek(startDate: currentState.weekStart));
      },
    );
  }

  Future<void> _onAddQuickNote(
    AddQuickNote event,
    Emitter<PlannerState> emit,
  ) async {
    if (state is! PlannerLoaded) return;
    final currentState = state as PlannerLoaded;

    final result = await addMealSlot(AddMealSlotParams(
      planId: event.planId,
      mealType: event.mealType,
      quickNote: event.note,
    ));

    result.fold(
      (failure) {
        if (!failure.message.contains('401')) {
          emit(PlannerError(message: failure.message));
        }
      },
      (slot) {
        add(LoadWeek(startDate: currentState.weekStart));
      },
    );
  }

  Future<void> _onRemoveSlot(
    RemoveSlot event,
    Emitter<PlannerState> emit,
  ) async {
    if (state is! PlannerLoaded) return;
    final currentState = state as PlannerLoaded;

    final result = await removeMealSlot(RemoveMealSlotParams(
      planId: event.planId,
      slotId: event.slotId,
    ));

    result.fold(
      (failure) {
        if (!failure.message.contains('401')) {
          emit(PlannerError(message: failure.message));
        }
      },
      (_) {
        add(LoadWeek(startDate: currentState.weekStart));
      },
    );
  }

  Future<void> _onMoveSlot(
    MoveSlot event,
    Emitter<PlannerState> emit,
  ) async {
    if (state is! PlannerLoaded) return;
    final currentState = state as PlannerLoaded;

    final result = await updateMealSlot(UpdateMealSlotParams(
      planId: event.planId,
      slotId: event.slotId,
      mealType: event.toMealType,
    ));

    result.fold(
      (failure) {
        if (!failure.message.contains('401')) {
          emit(PlannerError(message: failure.message));
        }
      },
      (_) {
        add(LoadWeek(startDate: currentState.weekStart));
      },
    );
  }

  Future<void> _onCreatePlan(
    CreatePlan event,
    Emitter<PlannerState> emit,
  ) async {
    if (state is! PlannerLoaded) return;
    final currentState = state as PlannerLoaded;

    final result = await createMealPlan(
      CreateMealPlanParams(date: event.date),
    );

    result.fold(
      (failure) {
        // Stay on loaded state if not authenticated (401)
        if (failure.message.contains('401')) {
          return;
        }
        emit(PlannerError(message: failure.message));
      },
      (_) {
        add(LoadWeek(startDate: currentState.weekStart));
      },
    );
  }

  MealPlan? _findPlanForDate(List<MealPlan> plans, DateTime date) {
    try {
      return plans.firstWhere((p) => _isSameDay(p.date, date));
    } catch (_) {
      return null;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
