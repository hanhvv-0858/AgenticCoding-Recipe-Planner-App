import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:recipe_planner/core/constants/app_constants.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/usecases/usecase.dart';
import 'package:recipe_planner/features/planner/domain/entities/meal_slot.dart';
import 'package:recipe_planner/features/planner/domain/repositories/planner_repository.dart';

/// Update an existing meal slot.
class UpdateMealSlot extends UseCase<MealSlot, UpdateMealSlotParams> {
  final PlannerRepository repository;

  UpdateMealSlot(this.repository);

  @override
  Future<Either<Failure, MealSlot>> call(UpdateMealSlotParams params) {
    return repository.updateSlot(
      planId: params.planId,
      slotId: params.slotId,
      mealType: params.mealType,
      recipeId: params.recipeId,
      quickNote: params.quickNote,
      servings: params.servings,
      displayOrder: params.displayOrder,
    );
  }
}

class UpdateMealSlotParams extends Equatable {
  final String planId;
  final String slotId;
  final MealType? mealType;
  final String? recipeId;
  final String? quickNote;
  final int? servings;
  final int? displayOrder;

  const UpdateMealSlotParams({
    required this.planId,
    required this.slotId,
    this.mealType,
    this.recipeId,
    this.quickNote,
    this.servings,
    this.displayOrder,
  });

  @override
  List<Object?> get props =>
      [planId, slotId, mealType, recipeId, quickNote, servings, displayOrder];
}
