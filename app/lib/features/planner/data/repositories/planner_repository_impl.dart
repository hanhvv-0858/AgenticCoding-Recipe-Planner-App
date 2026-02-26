import 'package:dartz/dartz.dart';
import 'package:recipe_planner/core/constants/app_constants.dart';
import 'package:recipe_planner/core/error/exceptions.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/network/network_info.dart';
import 'package:recipe_planner/features/planner/data/datasources/planner_local_datasource.dart';
import 'package:recipe_planner/features/planner/data/datasources/planner_remote_datasource.dart';
import 'package:recipe_planner/features/planner/domain/entities/meal_plan.dart';
import 'package:recipe_planner/features/planner/domain/entities/meal_slot.dart';
import 'package:recipe_planner/features/planner/domain/repositories/planner_repository.dart';

/// Implements PlannerRepository with online/offline data strategy.
///
/// Online: call remote + cache locally.
/// Offline: write to local + add to sync queue.
class PlannerRepositoryImpl implements PlannerRepository {
  final PlannerRemoteDataSource remoteDataSource;
  final PlannerLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  PlannerRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Future<Either<Failure, List<MealPlan>>> getWeekMealPlans({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final plans = await remoteDataSource.getWeekMealPlans(
          startDate: _formatDate(startDate),
          endDate: _formatDate(endDate),
        );
        // Cache for offline access
        await localDataSource.cacheMealPlans(plans);
        return Right(plans);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final cachedPlans = await localDataSource.getCachedMealPlans(
          startDate: startDate,
          endDate: endDate,
        );
        return Right(cachedPlans);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, MealPlan>> createMealPlan({
    required DateTime date,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final plan = await remoteDataSource.createMealPlan(
          date: _formatDate(date),
        );
        await localDataSource.cacheMealPlans([plan]);
        return Right(plan);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final plan = await localDataSource.saveMealPlanLocally(
          date: date,
          userId: '', // Will be resolved on sync
        );
        await localDataSource.enqueueSyncOperation(
          entityType: 'meal_plan',
          entityId: plan.id!,
          operation: 'create',
          payload: {'date': _formatDate(date)},
        );
        return Right(plan);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, MealSlot>> addSlot({
    required String planId,
    required MealType mealType,
    String? recipeId,
    String? quickNote,
    int servings = 2,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final slot = await remoteDataSource.addSlot(
          planId: planId,
          mealType: mealType,
          recipeId: recipeId,
          quickNote: quickNote,
          servings: servings,
        );
        return Right(slot);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final slot = await localDataSource.saveSlotLocally(
          planId: planId,
          mealType: mealType.name,
          recipeId: recipeId,
          quickNote: quickNote,
          servings: servings,
        );
        await localDataSource.enqueueSyncOperation(
          entityType: 'meal_slot',
          entityId: slot.id,
          operation: 'create',
          payload: {
            'plan_id': planId,
            'meal_type': mealType.name,
            if (recipeId != null) 'recipe_id': recipeId,
            if (quickNote != null) 'quick_note': quickNote,
            'servings': servings,
          },
        );
        return Right(slot);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, MealSlot>> updateSlot({
    required String planId,
    required String slotId,
    MealType? mealType,
    String? recipeId,
    String? quickNote,
    int? servings,
    int? displayOrder,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final slot = await remoteDataSource.updateSlot(
          planId: planId,
          slotId: slotId,
          mealType: mealType,
          recipeId: recipeId,
          quickNote: quickNote,
          servings: servings,
          displayOrder: displayOrder,
        );
        return Right(slot);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        await localDataSource.updateSlotLocally(
          slotId: slotId,
          mealType: mealType?.name,
          recipeId: recipeId,
          quickNote: quickNote,
          servings: servings,
          displayOrder: displayOrder,
        );
        await localDataSource.enqueueSyncOperation(
          entityType: 'meal_slot',
          entityId: slotId,
          operation: 'update',
          payload: {
            'plan_id': planId,
            'slot_id': slotId,
            if (mealType != null) 'meal_type': mealType.name,
            if (recipeId != null) 'recipe_id': recipeId,
            if (quickNote != null) 'quick_note': quickNote,
            if (servings != null) 'servings': servings,
            if (displayOrder != null) 'display_order': displayOrder,
          },
        );
        // Return a placeholder slot — data is already persisted locally
        return Right(MealSlot(
          id: slotId,
          mealType: mealType ?? MealType.breakfast,
          quickNote: quickNote,
          servings: servings ?? 2,
          displayOrder: displayOrder ?? 0,
        ));
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, void>> removeSlot({
    required String planId,
    required String slotId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.removeSlot(
          planId: planId,
          slotId: slotId,
        );
        await localDataSource.removeSlotLocally(slotId: slotId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        await localDataSource.removeSlotLocally(slotId: slotId);
        await localDataSource.enqueueSyncOperation(
          entityType: 'meal_slot',
          entityId: slotId,
          operation: 'delete',
          payload: {
            'plan_id': planId,
            'slot_id': slotId,
          },
        );
        return const Right(null);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }
}
