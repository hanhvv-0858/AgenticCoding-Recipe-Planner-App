import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/usecases/usecase.dart';
import 'package:recipe_planner/features/grocery/domain/repositories/grocery_repository.dart';

/// Clear all checked grocery items for a specific week.
class ClearCompletedItems
    extends UseCase<({int clearedCount, int remainingCount}),
        ClearCompletedItemsParams> {
  final GroceryRepository repository;

  ClearCompletedItems(this.repository);

  @override
  Future<Either<Failure, ({int clearedCount, int remainingCount})>> call(
      ClearCompletedItemsParams params) {
    return repository.clearCompleted(weekStart: params.weekStart);
  }
}

class ClearCompletedItemsParams extends Equatable {
  final String weekStart;

  const ClearCompletedItemsParams({required this.weekStart});

  @override
  List<Object?> get props => [weekStart];
}
