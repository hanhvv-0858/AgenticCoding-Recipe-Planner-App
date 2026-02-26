import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/usecases/usecase.dart';
import 'package:recipe_planner/features/grocery/domain/repositories/grocery_repository.dart';

/// Delete a single grocery item.
class DeleteGroceryItem extends UseCase<void, DeleteGroceryItemParams> {
  final GroceryRepository repository;

  DeleteGroceryItem(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteGroceryItemParams params) {
    return repository.deleteItem(id: params.id);
  }
}

class DeleteGroceryItemParams extends Equatable {
  final String id;

  const DeleteGroceryItemParams({required this.id});

  @override
  List<Object?> get props => [id];
}
