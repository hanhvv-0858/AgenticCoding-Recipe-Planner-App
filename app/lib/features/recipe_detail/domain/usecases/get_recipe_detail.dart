import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/usecases/usecase.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';
import 'package:recipe_planner/features/recipe_detail/domain/repositories/recipe_detail_repository.dart';

/// Get full recipe detail by ID.
class GetRecipeDetail extends UseCase<Recipe, GetRecipeDetailParams> {
  final RecipeDetailRepository repository;

  GetRecipeDetail(this.repository);

  @override
  Future<Either<Failure, Recipe>> call(GetRecipeDetailParams params) {
    return repository.getRecipeById(params.id);
  }
}

class GetRecipeDetailParams extends Equatable {
  final String id;

  const GetRecipeDetailParams({required this.id});

  @override
  List<Object?> get props => [id];
}
