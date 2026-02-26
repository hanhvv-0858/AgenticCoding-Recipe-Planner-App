import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/usecases/usecase.dart';
import 'package:recipe_planner/features/cookbook/domain/repositories/cookbook_repository.dart';

/// Save a recipe to the user's cookbook.
class CookbookSaveRecipe extends UseCase<void, CookbookSaveRecipeParams> {
  final CookbookRepository repository;

  CookbookSaveRecipe(this.repository);

  @override
  Future<Either<Failure, void>> call(CookbookSaveRecipeParams params) {
    return repository.saveRecipe(params.recipeId);
  }
}

class CookbookSaveRecipeParams extends Equatable {
  final String recipeId;

  const CookbookSaveRecipeParams({required this.recipeId});

  @override
  List<Object?> get props => [recipeId];
}
