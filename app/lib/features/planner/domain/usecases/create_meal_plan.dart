import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/usecases/usecase.dart';
import 'package:recipe_planner/features/planner/domain/entities/meal_plan.dart';
import 'package:recipe_planner/features/planner/domain/repositories/planner_repository.dart';

/// Create a new meal plan for a specific date.
class CreateMealPlan extends UseCase<MealPlan, CreateMealPlanParams> {
  final PlannerRepository repository;

  CreateMealPlan(this.repository);

  @override
  Future<Either<Failure, MealPlan>> call(CreateMealPlanParams params) {
    return repository.createMealPlan(date: params.date);
  }
}

class CreateMealPlanParams extends Equatable {
  final DateTime date;

  const CreateMealPlanParams({required this.date});

  @override
  List<Object?> get props => [date];
}
