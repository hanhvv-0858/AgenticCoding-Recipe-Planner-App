import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/usecases/usecase.dart';
import 'package:recipe_planner/features/grocery/domain/entities/grocery_item.dart';
import 'package:recipe_planner/features/grocery/domain/repositories/grocery_repository.dart';

/// Get the grocery list for a specific week.
class GetGroceryList
    extends UseCase<
        ({List<GroceryCategoryGroup> categories, GrocerySummary summary}),
        GetGroceryListParams> {
  final GroceryRepository repository;

  GetGroceryList(this.repository);

  @override
  Future<
          Either<Failure,
              ({List<GroceryCategoryGroup> categories, GrocerySummary summary})>>
      call(GetGroceryListParams params) {
    return repository.getGroceryList(
      weekStart: params.weekStart,
      regenerate: params.regenerate,
    );
  }
}

class GetGroceryListParams extends Equatable {
  final String weekStart;
  final bool regenerate;

  const GetGroceryListParams({
    required this.weekStart,
    this.regenerate = false,
  });

  @override
  List<Object?> get props => [weekStart, regenerate];
}
