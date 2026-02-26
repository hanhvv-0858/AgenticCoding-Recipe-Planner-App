import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/usecases/usecase.dart';
import 'package:recipe_planner/features/grocery/domain/repositories/grocery_repository.dart';

/// Get the count of remaining (unchecked) grocery items for badge display.
class GetRemainingItemCount
    extends UseCase<int, GetRemainingItemCountParams> {
  final GroceryRepository repository;

  GetRemainingItemCount(this.repository);

  @override
  Future<Either<Failure, int>> call(GetRemainingItemCountParams params) {
    return repository.getRemainingCount(weekStart: params.weekStart);
  }
}

class GetRemainingItemCountParams extends Equatable {
  final String weekStart;

  const GetRemainingItemCountParams({required this.weekStart});

  @override
  List<Object?> get props => [weekStart];
}
