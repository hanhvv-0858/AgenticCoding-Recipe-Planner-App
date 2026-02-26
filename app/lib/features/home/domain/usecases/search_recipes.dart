import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/usecases/usecase.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';
import 'package:recipe_planner/features/home/domain/repositories/home_repository.dart';

/// Search recipes with filters and pagination.
class SearchRecipes
    extends UseCase<({List<Recipe> recipes, String? nextCursor}), SearchRecipesParams> {
  final HomeRepository repository;

  SearchRecipes(this.repository);

  @override
  Future<Either<Failure, ({List<Recipe> recipes, String? nextCursor})>> call(
    SearchRecipesParams params,
  ) {
    return repository.searchRecipes(
      query: params.query,
      tag: params.tag,
      maxTime: params.maxTime,
      maxCalories: params.maxCalories,
      ingredient: params.ingredient,
      cursor: params.cursor,
      limit: params.limit,
    );
  }
}

class SearchRecipesParams extends Equatable {
  final String? query;
  final String? tag;
  final int? maxTime;
  final int? maxCalories;
  final String? ingredient;
  final String? cursor;
  final int limit;

  const SearchRecipesParams({
    this.query,
    this.tag,
    this.maxTime,
    this.maxCalories,
    this.ingredient,
    this.cursor,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, tag, maxTime, maxCalories, ingredient, cursor, limit];
}
