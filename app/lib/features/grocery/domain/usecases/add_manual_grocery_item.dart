import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/usecases/usecase.dart';
import 'package:recipe_planner/features/grocery/domain/entities/grocery_item.dart';
import 'package:recipe_planner/features/grocery/domain/repositories/grocery_repository.dart';

/// Manually add a custom grocery item.
class AddManualGroceryItem
    extends UseCase<GroceryItem, AddManualGroceryItemParams> {
  final GroceryRepository repository;

  AddManualGroceryItem(this.repository);

  @override
  Future<Either<Failure, GroceryItem>> call(
      AddManualGroceryItemParams params) {
    return repository.addManualItem(
      name: params.name,
      quantity: params.quantity,
      unit: params.unit,
      category: params.category,
      weekStart: params.weekStart,
    );
  }
}

class AddManualGroceryItemParams extends Equatable {
  final String name;
  final double quantity;
  final String unit;
  final String category;
  final String weekStart;

  const AddManualGroceryItemParams({
    required this.name,
    required this.quantity,
    required this.unit,
    this.category = 'Other',
    required this.weekStart,
  });

  @override
  List<Object?> get props => [name, quantity, unit, category, weekStart];
}
