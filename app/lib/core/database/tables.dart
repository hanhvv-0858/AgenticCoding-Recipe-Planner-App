import 'package:drift/drift.dart';

// ============================================================
// Table Definitions
// ============================================================

/// Cached recipes for offline access.
class CachedRecipes extends Table {
  TextColumn get id => text()();
  TextColumn get data => text()(); // Full recipe JSON
  IntColumn get cachedAt => integer()();
  BoolColumn get isSaved => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local meal plans for offline editing.
class LocalMealPlans extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local meal slots for offline editing.
class LocalMealSlots extends Table {
  TextColumn get id => text()();
  TextColumn get mealPlanId => text()();
  TextColumn get mealType => text()();
  TextColumn get recipeId => text().nullable()();
  TextColumn get recipeData => text().nullable()(); // JSON for offline display
  TextColumn get quickNote => text().nullable()();
  IntColumn get servings => integer().withDefault(const Constant(2))();
  IntColumn get displayOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local grocery items for offline management.
class LocalGroceryItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
  TextColumn get category => text().withDefault(const Constant('Other'))();
  TextColumn get sourceRecipes => text().withDefault(const Constant('[]'))(); // JSON array
  BoolColumn get isChecked => boolean().withDefault(const Constant(false))();
  BoolColumn get isManual => boolean().withDefault(const Constant(false))();
  DateTimeColumn get weekStartDate => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local cookbook entries.
class LocalCookbooks extends Table {
  TextColumn get recipeId => text()();
  IntColumn get savedAt => integer()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {recipeId};
}

/// Sync queue for offline operations.
class SyncQueueEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()(); // 'meal_plan', 'meal_slot', 'grocery_item', 'cookbook'
  TextColumn get entityId => text()();
  TextColumn get operation => text()(); // 'create', 'update', 'delete'
  TextColumn get payload => text()(); // JSON serialized data
  IntColumn get createdAt => integer()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // 'pending', 'processing', 'failed'
}
