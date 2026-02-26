import 'package:drift/drift.dart';
import 'package:recipe_planner/core/database/app_database.dart';
import 'package:recipe_planner/core/database/tables.dart';

part 'sync_dao.g.dart';

/// Data Access Object for sync queue operations.
@DriftAccessor(tables: [SyncQueueEntries])
class SyncDao extends DatabaseAccessor<AppDatabase> with _$SyncDaoMixin {
  SyncDao(super.db);

  /// Insert a new sync operation.
  Future<int> insertOperation({
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
  }) {
    return into(syncQueueEntries).insert(
      SyncQueueEntriesCompanion.insert(
        entityType: entityType,
        entityId: entityId,
        operation: operation,
        payload: payload,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// Get all pending operations ordered by creation time (FIFO).
  Future<List<SyncQueueEntry>> getPendingOperations() {
    return (select(syncQueueEntries)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Mark an operation as processing.
  Future<bool> markProcessing(int id) async {
    final count = await (update(syncQueueEntries)
          ..where((t) => t.id.equals(id)))
        .write(
      const SyncQueueEntriesCompanion(
        status: Value('processing'),
      ),
    );
    return count > 0;
  }

  /// Mark an operation as completed (removes it from queue).
  Future<int> markCompleted(int id) {
    return (delete(syncQueueEntries)..where((t) => t.id.equals(id))).go();
  }

  /// Mark an operation as failed and increment retry count.
  Future<bool> markFailed(int id) async {
    final entry = await (select(syncQueueEntries)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();

    if (entry == null) return false;

    final count = await (update(syncQueueEntries)
          ..where((t) => t.id.equals(id)))
        .write(
      SyncQueueEntriesCompanion(
        status: const Value('failed'),
        retryCount: Value(entry.retryCount + 1),
      ),
    );
    return count > 0;
  }

  /// Get retry count for an operation.
  Future<int> getRetryCount(int id) async {
    final entry = await (select(syncQueueEntries)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return entry?.retryCount ?? 0;
  }

  /// Reset failed operations back to pending (for retry).
  Future<int> resetFailedToPending() {
    return (update(syncQueueEntries)
          ..where((t) =>
              t.status.equals('failed') & t.retryCount.isSmallerThanValue(3)))
        .write(
      const SyncQueueEntriesCompanion(
        status: Value('pending'),
      ),
    );
  }

  /// Get count of pending operations.
  Future<int> getPendingCount() async {
    final count = countAll();
    final query = selectOnly(syncQueueEntries)
      ..where(syncQueueEntries.status.equals('pending'))
      ..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }
}
