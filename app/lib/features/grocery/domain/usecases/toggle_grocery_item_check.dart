import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/usecases/usecase.dart';
import 'package:recipe_planner/features/grocery/domain/entities/grocery_item.dart';
import 'package:recipe_planner/features/grocery/domain/repositories/grocery_repository.dart';

/// Toggle the checked/purchased status of a grocery item.
class ToggleGroceryItemCheck
    extends UseCase<GroceryItem, ToggleGroceryItemCheckParams> {
  final GroceryRepository repository;

  ToggleGroceryItemCheck(this.repository);

  @override
  Future<Either<Failure, GroceryItem>> call(
      ToggleGroceryItemCheckParams params) {
    return repository.toggleItemCheck(
      id: params.id,
      isChecked: params.isChecked,
    );
  }
}

class ToggleGroceryItemCheckParams extends Equatable {
  final String id;
  final bool isChecked;

  const ToggleGroceryItemCheckParams({
    required this.id,
    required this.isChecked,
  });

  @override
  List<Object?> get props => [id, isChecked];
}
