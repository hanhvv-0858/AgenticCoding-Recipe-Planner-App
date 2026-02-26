import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/usecases/usecase.dart';
import 'package:recipe_planner/features/planner/domain/repositories/planner_repository.dart';

/// Remove a meal slot from a meal plan.
class RemoveMealSlot extends UseCase<void, RemoveMealSlotParams> {
  final PlannerRepository repository;

  RemoveMealSlot(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveMealSlotParams params) {
    return repository.removeSlot(
      planId: params.planId,
      slotId: params.slotId,
    );
  }
}

class RemoveMealSlotParams extends Equatable {
  final String planId;
  final String slotId;

  const RemoveMealSlotParams({
    required this.planId,
    required this.slotId,
  });

  @override
  List<Object?> get props => [planId, slotId];
}
