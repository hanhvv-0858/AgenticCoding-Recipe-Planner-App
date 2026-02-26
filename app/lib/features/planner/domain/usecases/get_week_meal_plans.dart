import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/usecases/usecase.dart';
import 'package:recipe_planner/features/planner/domain/entities/meal_plan.dart';
import 'package:recipe_planner/features/planner/domain/repositories/planner_repository.dart';

/// Get meal plans for a week's date range.
class GetWeekMealPlans
    extends UseCase<List<MealPlan>, GetWeekMealPlansParams> {
  final PlannerRepository repository;

  GetWeekMealPlans(this.repository);

  @override
  Future<Either<Failure, List<MealPlan>>> call(
    GetWeekMealPlansParams params,
  ) {
    return repository.getWeekMealPlans(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetWeekMealPlansParams extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const GetWeekMealPlansParams({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}
