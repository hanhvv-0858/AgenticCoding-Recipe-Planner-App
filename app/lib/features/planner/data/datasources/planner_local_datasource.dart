import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:recipe_planner/core/database/app_database.dart';
import 'package:recipe_planner/core/error/exceptions.dart';
import 'package:recipe_planner/features/planner/data/models/meal_plan_model.dart';
import 'package:uuid/uuid.dart';

/// Contract for local data operations related to the Planner feature.
abstract class PlannerLocalDataSource {
  /// Cache meal plans locally.
  Future<void> cacheMealPlans(List<MealPlanModel> plans);

  /// Get cached meal plans for a date range.
  Future<List<MealPlanModel>> getCachedMealPlans({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Save a meal plan locally (for offline creation).
  Future<MealPlanModel> saveMealPlanLocally({
    required DateTime date,
    required String userId,
  });

  /// Save a meal slot locally.
  Future<MealSlotModel> saveSlotLocally({
    required String planId,
    required String mealType,
    String? recipeId,
    String? recipeData,
    String? quickNote,
    int servings = 2,
  });

  /// Update a meal slot locally.
  Future<void> updateSlotLocally({
    required String slotId,
    String? mealType,
    String? recipeId,
    String? recipeData,
    String? quickNote,
    int? servings,
    int? displayOrder,
  });

  /// Remove a meal slot locally.
  Future<void> removeSlotLocally({required String slotId});

  /// Enqueue a sync operation.
  Future<void> enqueueSyncOperation({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
  });
}

/// Implementation using drift (SQLite) database.
class PlannerLocalDataSourceImpl implements PlannerLocalDataSource {
  final AppDatabase database;

  PlannerLocalDataSourceImpl({required this.database});

  @override
  Future<void> cacheMealPlans(List<MealPlanModel> plans) async {
    try {
      await database.batch((batch) {
        for (final plan in plans) {
          if (plan.id == null) continue;
          batch.insert(
            database.localMealPlans,
            LocalMealPlansCompanion.insert(
              id: plan.id!,
              userId: plan.userId,
              date: plan.date,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              updatedAt: DateTime.now().millisecondsSinceEpoch,
            ),
            mode: InsertMode.insertOrReplace,
          );

          // Cache slots
          for (final slot in plan.slots) {
            final slotModel =
                slot is MealSlotModel ? slot : MealSlotModel(
                  id: slot.id,
                  mealType: slot.mealType,
                  recipe: slot.recipe,
                  quickNote: slot.quickNote,
                  servings: slot.servings,
                  displayOrder: slot.displayOrder,
                );
            batch.insert(
              database.localMealSlots,
              LocalMealSlotsCompanion.insert(
                id: slotModel.id,
                mealPlanId: plan.id!,
                mealType: slotModel.mealType.name,
                recipeId: Value(slot.recipe?.id),
                recipeData: Value(
                    slot.recipe != null ? jsonEncode(slotModel.toJson()['recipe']) : null),
                quickNote: Value(slot.quickNote),
                servings: Value(slot.servings),
                displayOrder: Value(slot.displayOrder),
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
        }
      });
    } on Exception catch (e) {
      throw CacheException(message: 'Failed to cache meal plans: $e');
    }
  }

  @override
  Future<List<MealPlanModel>> getCachedMealPlans({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final planRows = await (database.select(database.localMealPlans)
            ..where((t) =>
                t.date.isBiggerOrEqualValue(startDate) &
                t.date.isSmallerOrEqualValue(endDate))
            ..orderBy([(t) => OrderingTerm.asc(t.date)]))
          .get();

      final plans = <MealPlanModel>[];
      for (final planRow in planRows) {
        final slotRows = await (database.select(database.localMealSlots)
              ..where((t) => t.mealPlanId.equals(planRow.id))
              ..orderBy([(t) => OrderingTerm.asc(t.displayOrder)]))
            .get();

        final slots = slotRows.map((slotRow) {
          Map<String, dynamic>? recipeJson;
          if (slotRow.recipeData != null) {
            recipeJson = jsonDecode(slotRow.recipeData!) as Map<String, dynamic>;
          }

          return MealSlotModel.fromJson({
            'id': slotRow.id,
            'meal_type': slotRow.mealType,
            'recipe': recipeJson,
            'quick_note': slotRow.quickNote,
            'servings': slotRow.servings,
            'display_order': slotRow.displayOrder,
          });
        }).toList();

        plans.add(MealPlanModel(
          id: planRow.id,
          userId: planRow.userId,
          date: planRow.date,
          slots: slots,
        ));
      }

      return plans;
    } on Exception catch (e) {
      throw CacheException(message: 'Failed to get cached meal plans: $e');
    }
  }

  @override
  Future<MealPlanModel> saveMealPlanLocally({
    required DateTime date,
    required String userId,
  }) async {
    try {
      final id = const Uuid().v4();
      await database.into(database.localMealPlans).insert(
            LocalMealPlansCompanion.insert(
              id: id,
              userId: userId,
              date: date,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              updatedAt: DateTime.now().millisecondsSinceEpoch,
              isSynced: const Value(false),
            ),
          );

      return MealPlanModel(
        id: id,
        userId: userId,
        date: date,
        slots: const [],
      );
    } on Exception catch (e) {
      throw CacheException(message: 'Failed to save meal plan locally: $e');
    }
  }

  @override
  Future<MealSlotModel> saveSlotLocally({
    required String planId,
    required String mealType,
    String? recipeId,
    String? recipeData,
    String? quickNote,
    int servings = 2,
  }) async {
    try {
      final id = const Uuid().v4();

      // Get next display_order
      final existing = await (database.select(database.localMealSlots)
            ..where((t) => t.mealPlanId.equals(planId))
            ..orderBy([(t) => OrderingTerm.desc(t.displayOrder)])
            ..limit(1))
          .get();
      final nextOrder =
          existing.isNotEmpty ? existing.first.displayOrder + 1 : 0;

      await database.into(database.localMealSlots).insert(
            LocalMealSlotsCompanion.insert(
              id: id,
              mealPlanId: planId,
              mealType: mealType,
              recipeId: Value(recipeId),
              recipeData: Value(recipeData),
              quickNote: Value(quickNote),
              servings: Value(servings),
              displayOrder: Value(nextOrder),
              isSynced: const Value(false),
            ),
          );

      Map<String, dynamic>? recipe;
      if (recipeData != null) {
        recipe = jsonDecode(recipeData) as Map<String, dynamic>;
      }

      return MealSlotModel.fromJson({
        'id': id,
        'meal_type': mealType,
        'recipe': recipe,
        'quick_note': quickNote,
        'servings': servings,
        'display_order': nextOrder,
      });
    } on Exception catch (e) {
      throw CacheException(message: 'Failed to save slot locally: $e');
    }
  }

  @override
  Future<void> updateSlotLocally({
    required String slotId,
    String? mealType,
    String? recipeId,
    String? recipeData,
    String? quickNote,
    int? servings,
    int? displayOrder,
  }) async {
    try {
      final companion = LocalMealSlotsCompanion(
        mealType: mealType != null ? Value(mealType) : const Value.absent(),
        recipeId: recipeId != null ? Value(recipeId) : const Value.absent(),
        recipeData:
            recipeData != null ? Value(recipeData) : const Value.absent(),
        quickNote: quickNote != null ? Value(quickNote) : const Value.absent(),
        servings: servings != null ? Value(servings) : const Value.absent(),
        displayOrder:
            displayOrder != null ? Value(displayOrder) : const Value.absent(),
        isSynced: const Value(false),
      );

      await (database.update(database.localMealSlots)
            ..where((t) => t.id.equals(slotId)))
          .write(companion);
    } on Exception catch (e) {
      throw CacheException(message: 'Failed to update slot locally: $e');
    }
  }

  @override
  Future<void> removeSlotLocally({required String slotId}) async {
    try {
      await (database.delete(database.localMealSlots)
            ..where((t) => t.id.equals(slotId)))
          .go();
    } on Exception catch (e) {
      throw CacheException(message: 'Failed to remove slot locally: $e');
    }
  }

  @override
  Future<void> enqueueSyncOperation({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    try {
      await database.into(database.syncQueueEntries).insert(
            SyncQueueEntriesCompanion.insert(
              entityType: entityType,
              entityId: entityId,
              operation: operation,
              payload: jsonEncode(payload),
              createdAt: DateTime.now().millisecondsSinceEpoch,
            ),
          );
    } on Exception catch (e) {
      throw CacheException(message: 'Failed to enqueue sync operation: $e');
    }
  }
}
