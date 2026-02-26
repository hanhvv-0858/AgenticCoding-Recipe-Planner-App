import 'package:dartz/dartz.dart';
import 'package:recipe_planner/core/error/exceptions.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/network/network_info.dart';
import 'package:recipe_planner/features/cookbook/data/datasources/cookbook_local_datasource.dart';
import 'package:recipe_planner/features/cookbook/data/datasources/cookbook_remote_datasource.dart';
import 'package:recipe_planner/features/cookbook/domain/repositories/cookbook_repository.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';

/// Implementation of CookbookRepository with online/offline support.
class CookbookRepositoryImpl implements CookbookRepository {
  final CookbookRemoteDataSource remoteDataSource;
  final CookbookLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  CookbookRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ({List<Recipe> recipes, String? nextCursor, bool hasMore})>>
      getSavedRecipes({String? cursor, int limit = 20}) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getSavedRecipes(
          cursor: cursor,
          limit: limit,
        );

        // Cache saved recipe IDs locally
        for (final recipe in result.recipes) {
          await localDataSource.cacheAsSaved(recipe.id);
        }

        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final recipes = await localDataSource.getCachedSavedRecipes();
        return Right((
          recipes: recipes,
          nextCursor: null,
          hasMore: false,
        ));
      } catch (e) {
        return Left(CacheFailure(message: 'Failed to load cached recipes: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> saveRecipe(String recipeId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.saveRecipe(recipeId);
        await localDataSource.cacheAsSaved(recipeId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        await localDataSource.cacheAsSaved(recipeId);
        await localDataSource.enqueueSyncOperation(
          recipeId: recipeId,
          operation: 'create',
        );
        return const Right(null);
      } catch (e) {
        return Left(CacheFailure(message: 'Failed to save recipe locally: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> unsaveRecipe(String recipeId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.unsaveRecipe(recipeId);
        await localDataSource.removeFromSaved(recipeId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        await localDataSource.removeFromSaved(recipeId);
        await localDataSource.enqueueSyncOperation(
          recipeId: recipeId,
          operation: 'delete',
        );
        return const Right(null);
      } catch (e) {
        return Left(CacheFailure(message: 'Failed to unsave recipe locally: $e'));
      }
    }
  }
}
