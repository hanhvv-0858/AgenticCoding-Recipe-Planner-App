import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/usecases/usecase.dart';
import 'package:recipe_planner/features/cookbook/domain/repositories/cookbook_repository.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';

/// Get saved recipes from the user's cookbook.
class GetSavedRecipes
    extends UseCase<({List<Recipe> recipes, String? nextCursor, bool hasMore}), GetSavedRecipesParams> {
  final CookbookRepository repository;

  GetSavedRecipes(this.repository);

  @override
  Future<Either<Failure, ({List<Recipe> recipes, String? nextCursor, bool hasMore})>> call(
      GetSavedRecipesParams params) {
    return repository.getSavedRecipes(cursor: params.cursor, limit: params.limit);
  }
}

class GetSavedRecipesParams extends Equatable {
  final String? cursor;
  final int limit;

  const GetSavedRecipesParams({this.cursor, this.limit = 20});

  @override
  List<Object?> get props => [cursor, limit];
}
