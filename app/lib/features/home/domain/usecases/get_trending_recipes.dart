import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/usecases/usecase.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';
import 'package:recipe_planner/features/home/domain/repositories/home_repository.dart';

/// Get trending recipes.
class GetTrendingRecipes extends UseCase<List<Recipe>, GetTrendingRecipesParams> {
  final HomeRepository repository;

  GetTrendingRecipes(this.repository);

  @override
  Future<Either<Failure, List<Recipe>>> call(GetTrendingRecipesParams params) {
    return repository.getTrendingRecipes(
      tag: params.tag,
      limit: params.limit,
    );
  }
}

class GetTrendingRecipesParams extends Equatable {
  final String? tag;
  final int limit;

  const GetTrendingRecipesParams({
    this.tag,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [tag, limit];
}
