import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:recipe_planner/core/constants/app_constants.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/usecases/usecase.dart';
import 'package:recipe_planner/features/planner/domain/entities/meal_slot.dart';
import 'package:recipe_planner/features/planner/domain/repositories/planner_repository.dart';

/// Add a meal slot to an existing meal plan.
class AddMealSlot extends UseCase<MealSlot, AddMealSlotParams> {
  final PlannerRepository repository;

  AddMealSlot(this.repository);

  @override
  Future<Either<Failure, MealSlot>> call(AddMealSlotParams params) {
    return repository.addSlot(
      planId: params.planId,
      mealType: params.mealType,
      recipeId: params.recipeId,
      quickNote: params.quickNote,
      servings: params.servings,
    );
  }
}

class AddMealSlotParams extends Equatable {
  final String planId;
  final MealType mealType;
  final String? recipeId;
  final String? quickNote;
  final int servings;

  const AddMealSlotParams({
    required this.planId,
    required this.mealType,
    this.recipeId,
    this.quickNote,
    this.servings = 2,
  });

  @override
  List<Object?> get props => [planId, mealType, recipeId, quickNote, servings];
}
