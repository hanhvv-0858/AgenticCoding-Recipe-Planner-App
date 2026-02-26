import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_planner/core/network/network_info.dart';
import 'package:recipe_planner/core/sync/sync_dao.dart';

// ============================================================
// Events
// ============================================================

abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

class SyncStarted extends SyncEvent {
  const SyncStarted();
}

class SyncConnectivityChanged extends SyncEvent {
  final bool isConnected;

  const SyncConnectivityChanged({required this.isConnected});

  @override
  List<Object?> get props => [isConnected];
}

class SyncProcessQueue extends SyncEvent {
  const SyncProcessQueue();
}

// ============================================================
// States
// ============================================================

abstract class SyncState extends Equatable {
  const SyncState();

  @override
  List<Object?> get props => [];
}

class SyncIdle extends SyncState {
  const SyncIdle();
}

class SyncSyncing extends SyncState {
  final int totalOperations;
  final int completedOperations;

  const SyncSyncing({
    required this.totalOperations,
    required this.completedOperations,
  });

  @override
  List<Object?> get props => [totalOperations, completedOperations];
}

class SyncCompleted extends SyncState {
  final int syncedCount;

  const SyncCompleted({required this.syncedCount});

  @override
  List<Object?> get props => [syncedCount];
}

class SyncError extends SyncState {
  final String message;

  const SyncError({required this.message});

  @override
  List<Object?> get props => [message];
}

class SyncOffline extends SyncState {
  final int pendingOperations;

  const SyncOffline({required this.pendingOperations});

  @override
  List<Object?> get props => [pendingOperations];
}

// ============================================================
// Bloc
// ============================================================

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final NetworkInfo networkInfo;
  final SyncDao syncDao;
  StreamSubscription<bool>? _connectivitySubscription;

  static const int _maxRetries = 3;

  SyncBloc({
    required this.networkInfo,
    required this.syncDao,
  }) : super(const SyncIdle()) {
    on<SyncStarted>(_onStarted);
    on<SyncConnectivityChanged>(_onConnectivityChanged);
    on<SyncProcessQueue>(_onProcessQueue);
  }

  Future<void> _onStarted(
    SyncStarted event,
    Emitter<SyncState> emit,
  ) async {
    // Listen to connectivity changes
    _connectivitySubscription?.cancel();
    _connectivitySubscription = networkInfo.onConnectivityChanged.listen(
      (isConnected) {
        add(SyncConnectivityChanged(isConnected: isConnected));
      },
    );

    // Check initial state
    final isConnected = await networkInfo.isConnected;
    if (isConnected) {
      add(const SyncProcessQueue());
    } else {
      final pendingCount = await syncDao.getPendingCount();
      emit(SyncOffline(pendingOperations: pendingCount));
    }
  }

  Future<void> _onConnectivityChanged(
    SyncConnectivityChanged event,
    Emitter<SyncState> emit,
  ) async {
    if (event.isConnected) {
      // Reconnected — process sync queue
      await syncDao.resetFailedToPending();
      add(const SyncProcessQueue());
    } else {
      final pendingCount = await syncDao.getPendingCount();
      emit(SyncOffline(pendingOperations: pendingCount));
    }
  }

  Future<void> _onProcessQueue(
    SyncProcessQueue event,
    Emitter<SyncState> emit,
  ) async {
    final operations = await syncDao.getPendingOperations();

    if (operations.isEmpty) {
      emit(const SyncIdle());
      return;
    }

    emit(SyncSyncing(
      totalOperations: operations.length,
      completedOperations: 0,
    ));

    int completed = 0;

    for (final op in operations) {
      try {
        await syncDao.markProcessing(op.id);

        // Process based on entity type and operation
        await _processOperation(op);

        await syncDao.markCompleted(op.id);
        completed++;

        emit(SyncSyncing(
          totalOperations: operations.length,
          completedOperations: completed,
        ));
      } catch (e) {
        final retryCount = await syncDao.getRetryCount(op.id);
        await syncDao.markFailed(op.id);

        if (retryCount >= _maxRetries) {
          // Max retries reached, skip this operation
          continue;
        }

        // Exponential backoff: 1s, 4s, 16s
        final delay = Duration(
          seconds: 1 << (retryCount * 2),
        );
        await Future<void>.delayed(delay);
      }
    }

    if (completed == operations.length) {
      emit(SyncCompleted(syncedCount: completed));
    } else {
      emit(SyncError(
        message: 'Synced $completed of ${operations.length} operations',
      ));
    }
  }

  Future<void> _processOperation(dynamic op) async {
    // TODO: Implement actual API calls based on entityType and operation
    // This will be wired up when each feature implements its sync logic
    // For now, this is a placeholder
    switch (op.entityType) {
      case 'meal_plan':
      case 'meal_slot':
      case 'grocery_item':
      case 'cookbook':
        // Each feature will register its sync handler
        break;
      default:
        throw Exception('Unknown entity type: ${op.entityType}');
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
