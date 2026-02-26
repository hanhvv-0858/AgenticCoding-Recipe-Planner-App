import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/usecases/usecase.dart';
import 'package:recipe_planner/features/cookbook/domain/repositories/cookbook_repository.dart';

/// Remove a recipe from the user's cookbook.
class CookbookUnsaveRecipe extends UseCase<void, CookbookUnsaveRecipeParams> {
  final CookbookRepository repository;

  CookbookUnsaveRecipe(this.repository);

  @override
  Future<Either<Failure, void>> call(CookbookUnsaveRecipeParams params) {
    return repository.unsaveRecipe(params.recipeId);
  }
}

class CookbookUnsaveRecipeParams extends Equatable {
  final String recipeId;

  const CookbookUnsaveRecipeParams({required this.recipeId});

  @override
  List<Object?> get props => [recipeId];
}
