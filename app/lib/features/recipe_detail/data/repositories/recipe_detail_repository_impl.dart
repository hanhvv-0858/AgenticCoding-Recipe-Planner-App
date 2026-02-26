import 'package:dartz/dartz.dart';
import 'package:recipe_planner/core/error/exceptions.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/network/network_info.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';
import 'package:recipe_planner/features/recipe_detail/data/datasources/recipe_detail_local_datasource.dart';
import 'package:recipe_planner/features/recipe_detail/data/datasources/recipe_detail_remote_datasource.dart';
import 'package:recipe_planner/features/recipe_detail/domain/repositories/recipe_detail_repository.dart';

/// Implements RecipeDetailRepository with online/offline strategy.
class RecipeDetailRepositoryImpl implements RecipeDetailRepository {
  final RecipeDetailRemoteDataSource remoteDataSource;
  final RecipeDetailLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  RecipeDetailRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Recipe>> getRecipeById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final recipe = await remoteDataSource.getRecipeById(id);
        await localDataSource.cacheRecipe(recipe);
        return Right(recipe);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final cached = await localDataSource.getCachedRecipe(id);
        if (cached != null) {
          return Right(cached);
        }
        return const Left(CacheFailure(message: 'Recipe not cached'));
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, void>> saveRecipe(String recipeId) async {
    try {
      await remoteDataSource.saveRecipe(recipeId);
      await localDataSource.updateSavedStatus(recipeId, isSaved: true);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException {
      // API succeeded but local cache update failed — not critical
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> unsaveRecipe(String recipeId) async {
    try {
      await remoteDataSource.unsaveRecipe(recipeId);
      await localDataSource.updateSavedStatus(recipeId, isSaved: false);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException {
      return const Right(null);
    }
  }
}
