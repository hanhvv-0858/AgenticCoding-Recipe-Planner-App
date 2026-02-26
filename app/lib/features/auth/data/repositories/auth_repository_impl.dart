import 'package:dartz/dartz.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/network/api_client.dart';
import 'package:recipe_planner/core/sync/sync_dao.dart';
import 'package:recipe_planner/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:recipe_planner/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:recipe_planner/features/auth/domain/entities/user.dart';
import 'package:recipe_planner/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final SyncDao syncDao;
  final ApiClient apiClient;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.syncDao,
    required this.apiClient,
  });

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final user = await remoteDataSource.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      await localDataSource.cacheUser(user);
      await localDataSource.setGuestMode(false);

      // Migrate any local guest data to the server
      await _migrateGuestData();

      return Right(user.toEntity());
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('already') || msg.contains('duplicate')) {
        return const Left(ServerFailure(
            message: 'An account with this email already exists'));
      }
      return Left(ServerFailure(message: 'Registration failed: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(
        email: email,
        password: password,
      );
      await localDataSource.cacheUser(user);
      await localDataSource.setGuestMode(false);

      // Migrate any local guest data to the server
      await _migrateGuestData();

      return Right(user.toEntity());
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Invalid') || msg.contains('invalid')) {
        return const Left(ServerFailure(message: 'Invalid email or password'));
      }
      return Left(ServerFailure(message: 'Login failed: $msg'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      if (user != null) {
        await localDataSource.cacheUser(user);
        return Right(user.toEntity());
      }

      // Try cached user
      final cached = await localDataSource.getCachedUser();
      if (cached != null) {
        return Right(cached.toEntity());
      }

      return const Left(ServerFailure(message: 'Not authenticated'));
    } catch (e) {
      // Try cached user as fallback
      final cached = await localDataSource.getCachedUser();
      if (cached != null) {
        return Right(cached.toEntity());
      }
      return Left(ServerFailure(message: 'Failed to get user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearCachedUser();
      await localDataSource.setGuestMode(true);
      return const Right(null);
    } catch (e) {
      // Still clear local cache even if remote fails
      await localDataSource.clearCachedUser();
      await localDataSource.setGuestMode(true);
      return const Right(null);
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      return await remoteDataSource.isAuthenticated();
    } catch (_) {
      return false;
    }
  }

  /// Migrate guest data to the server by processing pending sync queue.
  ///
  /// This runs after register/login to batch upload any local data
  /// created during guest mode (meal plans, cookbook entries, grocery items).
  Future<void> _migrateGuestData() async {
    try {
      final pendingOps = await syncDao.getPendingOperations();
      if (pendingOps.isEmpty) return;

      for (final op in pendingOps) {
        try {
          await syncDao.markProcessing(op.id);

          // Route to appropriate API endpoint based on entity type
          switch (op.operation) {
            case 'create':
              await apiClient.post(
                '/${op.entityType}',
                data: op.payload,
              );
              break;
            case 'update':
              await apiClient.put(
                '/${op.entityType}/${op.entityId}',
                data: op.payload,
              );
              break;
            case 'delete':
              await apiClient.delete(
                '/${op.entityType}/${op.entityId}',
              );
              break;
          }

          await syncDao.markCompleted(op.id);
        } catch (_) {
          // Mark as failed — SyncBloc will retry later
          await syncDao.markFailed(op.id);
        }
      }
    } catch (_) {
      // Migration is best-effort; SyncBloc will handle remaining items
    }
  }
}
