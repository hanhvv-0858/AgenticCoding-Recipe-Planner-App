import 'package:dartz/dartz.dart';
import 'package:recipe_planner/core/error/exceptions.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/network/network_info.dart';
import 'package:recipe_planner/features/home/data/datasources/home_local_datasource.dart';
import 'package:recipe_planner/features/home/data/datasources/home_remote_datasource.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';
import 'package:recipe_planner/features/home/domain/entities/tag.dart';
import 'package:recipe_planner/features/home/domain/repositories/home_repository.dart';

/// Implements HomeRepository with online/offline data strategy.
///
/// Online: fetch from remote, cache locally
/// Offline: return from local cache
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ({List<Recipe> recipes, String? nextCursor})>>
      searchRecipes({
    String? query,
    String? tag,
    int? maxTime,
    int? maxCalories,
    String? ingredient,
    String? cursor,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.searchRecipes(
          query: query,
          tag: tag,
          maxTime: maxTime,
          maxCalories: maxCalories,
          ingredient: ingredient,
          cursor: cursor,
          limit: limit,
        );
        // Cache results for offline access
        await localDataSource.cacheRecipes(result.recipes);
        return Right((recipes: result.recipes, nextCursor: result.nextCursor));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        // Offline: return cached recipes (limited offline search)
        final cachedRecipes =
            await localDataSource.getCachedTrendingRecipes();
        return Right((recipes: cachedRecipes, nextCursor: null));
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> getTrendingRecipes({
    String? tag,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final recipes = await remoteDataSource.getTrendingRecipes(
          tag: tag,
          limit: limit,
        );
        await localDataSource.cacheRecipes(recipes);
        return Right(recipes);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final cachedRecipes =
            await localDataSource.getCachedTrendingRecipes();
        return Right(cachedRecipes);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<Tag>>> getTags() async {
    if (await networkInfo.isConnected) {
      try {
        final tags = await remoteDataSource.getTags();
        await localDataSource.cacheTags(tags);
        return Right(tags);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final cachedTags = await localDataSource.getCachedTags();
        return Right(cachedTags);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, Recipe?>> getNextMealSlot() async {
    // Next meal slot comes from the local meal plan data.
    // For now, return null (will be wired with PlannerBloc later).
    return const Right(null);
  }
}
