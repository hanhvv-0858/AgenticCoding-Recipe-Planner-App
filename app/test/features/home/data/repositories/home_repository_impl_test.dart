import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_planner/core/error/exceptions.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/network/network_info.dart';
import 'package:recipe_planner/features/home/data/datasources/home_local_datasource.dart';
import 'package:recipe_planner/features/home/data/datasources/home_remote_datasource.dart';
import 'package:recipe_planner/features/home/data/models/recipe_model.dart';
import 'package:recipe_planner/features/home/data/models/tag_model.dart';
import 'package:recipe_planner/features/home/data/repositories/home_repository_impl.dart';

class MockRemoteDataSource extends Mock implements HomeRemoteDataSource {}

class MockLocalDataSource extends Mock implements HomeLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late HomeRepositoryImpl repository;
  late MockRemoteDataSource mockRemote;
  late MockLocalDataSource mockLocal;
  late MockNetworkInfo mockNetworkInfo;

  final tRecipeModels = [
    const RecipeModel(
      id: 'r1',
      title: 'Test Recipe',
      cookingTimeMinutes: 20,
    ),
  ];

  final tTagModels = [
    const TagModel(
      id: 't1',
      name: '#Healthy',
      slug: 'healthy',
    ),
  ];

  setUp(() {
    mockRemote = MockRemoteDataSource();
    mockLocal = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = HomeRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
      networkInfo: mockNetworkInfo,
    );
  });

  group('getTrendingRecipes', () {
    test('returns remote data and caches when online', () async {
      when(() => mockNetworkInfo.isConnected)
          .thenAnswer((_) async => true);
      when(() => mockRemote.getTrendingRecipes(
            tag: any(named: 'tag'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => tRecipeModels);
      when(() => mockLocal.cacheRecipes(any()))
          .thenAnswer((_) async {});

      final result = await repository.getTrendingRecipes();

      expect(result, isA<Right>());
      result.fold(
        (_) => fail('should be Right'),
        (data) => expect(data.length, 1),
      );
      verify(() => mockLocal.cacheRecipes(tRecipeModels)).called(1);
    });

    test('returns cached data when offline', () async {
      when(() => mockNetworkInfo.isConnected)
          .thenAnswer((_) async => false);
      when(() => mockLocal.getCachedTrendingRecipes())
          .thenAnswer((_) async => tRecipeModels);

      final result = await repository.getTrendingRecipes();

      expect(result, isA<Right>());
      verifyNever(() => mockRemote.getTrendingRecipes());
    });

    test('returns ServerFailure when remote throws', () async {
      when(() => mockNetworkInfo.isConnected)
          .thenAnswer((_) async => true);
      when(() => mockRemote.getTrendingRecipes(
            tag: any(named: 'tag'),
            limit: any(named: 'limit'),
          )).thenThrow(const ServerException());

      final result = await repository.getTrendingRecipes();

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('should be Left'),
      );
    });

    test('returns CacheFailure when offline and cache throws', () async {
      when(() => mockNetworkInfo.isConnected)
          .thenAnswer((_) async => false);
      when(() => mockLocal.getCachedTrendingRecipes())
          .thenThrow(const CacheException());

      final result = await repository.getTrendingRecipes();

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('should be Left'),
      );
    });
  });

  group('getTags', () {
    test('returns remote tags and caches when online', () async {
      when(() => mockNetworkInfo.isConnected)
          .thenAnswer((_) async => true);
      when(() => mockRemote.getTags())
          .thenAnswer((_) async => tTagModels);
      when(() => mockLocal.cacheTags(any()))
          .thenAnswer((_) async {});

      final result = await repository.getTags();

      expect(result, isA<Right>());
      verify(() => mockLocal.cacheTags(tTagModels)).called(1);
    });

    test('returns cached tags when offline', () async {
      when(() => mockNetworkInfo.isConnected)
          .thenAnswer((_) async => false);
      when(() => mockLocal.getCachedTags())
          .thenAnswer((_) async => tTagModels);

      final result = await repository.getTags();

      expect(result, isA<Right>());
    });
  });

  group('getNextMealSlot', () {
    test('returns null (placeholder)', () async {
      final result = await repository.getNextMealSlot();
      result.fold(
        (_) => fail('should be Right'),
        (data) => expect(data, isNull),
      );
    });
  });
}
