import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/usecases/usecase.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';
import 'package:recipe_planner/features/home/domain/entities/tag.dart';
import 'package:recipe_planner/features/home/domain/usecases/get_next_meal_slot.dart';
import 'package:recipe_planner/features/home/domain/usecases/get_tags.dart';
import 'package:recipe_planner/features/home/domain/usecases/get_trending_recipes.dart';
import 'package:recipe_planner/features/home/domain/usecases/search_recipes.dart'
    as uc_search;
import 'package:recipe_planner/features/home/presentation/bloc/home_bloc.dart';

class MockSearchRecipes extends Mock implements uc_search.SearchRecipes {}

class MockGetTrendingRecipes extends Mock implements GetTrendingRecipes {}

class MockGetTags extends Mock implements GetTags {}

class MockGetNextMealSlot extends Mock implements GetNextMealSlot {}

class FakeSearchRecipesParams extends Fake
    implements uc_search.SearchRecipesParams {}

class FakeGetTrendingRecipesParams extends Fake
    implements GetTrendingRecipesParams {}

class FakeNoParams extends Fake implements NoParams {}

void main() {
  late HomeBloc homeBloc;
  late MockSearchRecipes mockSearchRecipes;
  late MockGetTrendingRecipes mockGetTrendingRecipes;
  late MockGetTags mockGetTags;
  late MockGetNextMealSlot mockGetNextMealSlot;

  final tTags = [
    const Tag(id: '1', name: '#QuickLunch', slug: 'quick-lunch'),
    const Tag(id: '2', name: '#Healthy', slug: 'healthy'),
  ];

  final tRecipes = [
    const Recipe(
      id: 'r1',
      title: 'Test Recipe 1',
      cookingTimeMinutes: 20,
      calories: 350,
    ),
    const Recipe(
      id: 'r2',
      title: 'Test Recipe 2',
      cookingTimeMinutes: 30,
      calories: 450,
    ),
  ];

  setUpAll(() {
    registerFallbackValue(FakeSearchRecipesParams());
    registerFallbackValue(FakeGetTrendingRecipesParams());
    registerFallbackValue(FakeNoParams());
  });

  setUp(() {
    mockSearchRecipes = MockSearchRecipes();
    mockGetTrendingRecipes = MockGetTrendingRecipes();
    mockGetTags = MockGetTags();
    mockGetNextMealSlot = MockGetNextMealSlot();

    homeBloc = HomeBloc(
      searchRecipes: mockSearchRecipes,
      getTrendingRecipes: mockGetTrendingRecipes,
      getTags: mockGetTags,
      getNextMealSlot: mockGetNextMealSlot,
    );
  });

  tearDown(() => homeBloc.close());

  test('initial state is HomeInitial', () {
    expect(homeBloc.state, const HomeInitial());
  });

  group('LoadHome', () {
    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeLoaded] when all data fetched successfully',
      build: () {
        when(() => mockGetTags(any()))
            .thenAnswer((_) async => Right(tTags));
        when(() => mockGetTrendingRecipes(any()))
            .thenAnswer((_) async => Right(tRecipes));
        when(() => mockGetNextMealSlot(any()))
            .thenAnswer((_) async => const Right(null));
        return homeBloc;
      },
      act: (bloc) => bloc.add(const LoadHome()),
      expect: () => [
        const HomeLoading(),
        isA<HomeLoaded>()
            .having((s) => s.tags.length, 'tags count', 2)
            .having(
                (s) => s.trendingRecipes.length, 'trending count', 2)
            .having((s) => s.nextMealSlot, 'next meal', null),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits HomeLoaded with empty lists when all requests fail',
      build: () {
        when(() => mockGetTags(any())).thenAnswer(
            (_) async => const Left(ServerFailure(message: 'error')));
        when(() => mockGetTrendingRecipes(any())).thenAnswer(
            (_) async => const Left(ServerFailure(message: 'error')));
        when(() => mockGetNextMealSlot(any())).thenAnswer(
            (_) async => const Left(ServerFailure(message: 'error')));
        return homeBloc;
      },
      act: (bloc) => bloc.add(const LoadHome()),
      expect: () => [
        const HomeLoading(),
        isA<HomeLoaded>()
            .having((s) => s.tags, 'tags', isEmpty)
            .having((s) => s.trendingRecipes, 'trending', isEmpty),
      ],
    );
  });

  group('SearchRecipes', () {
    final searchResult = (recipes: tRecipes, nextCursor: null as String?);

    blocTest<HomeBloc, HomeState>(
      'emits HomeLoaded with searchResults when search succeeds',
      build: () {
        when(() => mockGetTags(any()))
            .thenAnswer((_) async => Right(tTags));
        when(() => mockGetTrendingRecipes(any()))
            .thenAnswer((_) async => Right(tRecipes));
        when(() => mockGetNextMealSlot(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockSearchRecipes(any()))
            .thenAnswer((_) async => Right(searchResult));
        return homeBloc;
      },
      act: (bloc) async {
        bloc.add(const LoadHome());
        await Future<void>.delayed(const Duration(milliseconds: 100));
        bloc.add(const SearchRecipes(query: 'salmon'));
      },
      skip: 2, // skip LoadHome states
      expect: () => [
        isA<HomeLoaded>().having((s) => s.isSearching, 'searching', true),
        isA<HomeLoaded>()
            .having((s) => s.searchResults, 'results', isNotNull)
            .having((s) => s.isSearching, 'searching', false),
      ],
    );
  });

  group('FilterByTag', () {
    blocTest<HomeBloc, HomeState>(
      'emits HomeLoaded with selectedTag after FilterByTag',
      build: () {
        when(() => mockGetTags(any()))
            .thenAnswer((_) async => Right(tTags));
        when(() => mockGetTrendingRecipes(any()))
            .thenAnswer((_) async => Right(tRecipes));
        when(() => mockGetNextMealSlot(any()))
            .thenAnswer((_) async => const Right(null));
        return homeBloc;
      },
      act: (bloc) async {
        bloc.add(const LoadHome());
        await Future<void>.delayed(const Duration(milliseconds: 100));
        bloc.add(const FilterByTag(tagSlug: 'healthy'));
      },
      skip: 2,
      expect: () => [
        isA<HomeLoaded>().having((s) => s.isSearching, 'searching', true),
        isA<HomeLoaded>()
            .having((s) => s.selectedTag, 'tag', 'healthy')
            .having((s) => s.isSearching, 'searching', false),
      ],
    );
  });
}
