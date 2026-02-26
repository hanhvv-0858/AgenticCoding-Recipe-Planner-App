import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/features/cookbook/domain/usecases/cookbook_save_recipe.dart';
import 'package:recipe_planner/features/cookbook/domain/usecases/cookbook_unsave_recipe.dart';
import 'package:recipe_planner/features/cookbook/domain/usecases/get_saved_recipes.dart';
import 'package:recipe_planner/features/cookbook/presentation/bloc/cookbook_bloc.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';

class MockGetSavedRecipes extends Mock implements GetSavedRecipes {}

class MockCookbookSaveRecipe extends Mock implements CookbookSaveRecipe {}

class MockCookbookUnsaveRecipe extends Mock implements CookbookUnsaveRecipe {}

void main() {
  late CookbookBloc bloc;
  late MockGetSavedRecipes mockGetSavedRecipes;
  late MockCookbookSaveRecipe mockSaveRecipe;
  late MockCookbookUnsaveRecipe mockUnsaveRecipe;

  setUp(() {
    mockGetSavedRecipes = MockGetSavedRecipes();
    mockSaveRecipe = MockCookbookSaveRecipe();
    mockUnsaveRecipe = MockCookbookUnsaveRecipe();

    bloc = CookbookBloc(
      getSavedRecipes: mockGetSavedRecipes,
      cookbookSaveRecipe: mockSaveRecipe,
      cookbookUnsaveRecipe: mockUnsaveRecipe,
    );

    registerFallbackValue(const GetSavedRecipesParams());
    registerFallbackValue(
        const CookbookSaveRecipeParams(recipeId: 'id'));
    registerFallbackValue(
        const CookbookUnsaveRecipeParams(recipeId: 'id'));
  });

  tearDown(() => bloc.close());

  final tRecipes = [
    const Recipe(
      id: 'r1',
      title: 'Grilled Salmon',
      cookingTimeMinutes: 25,
      calories: 380,
      isSaved: true,
    ),
    const Recipe(
      id: 'r2',
      title: 'Chicken Stir-Fry',
      cookingTimeMinutes: 20,
      calories: 450,
      isSaved: true,
    ),
  ];

  group('initial state', () {
    test('should be CookbookInitial', () {
      expect(bloc.state, const CookbookInitial());
    });
  });

  group('LoadCookbook', () {
    blocTest<CookbookBloc, CookbookState>(
      'emits [Loading, Loaded] on success with recipes',
      build: () {
        when(() => mockGetSavedRecipes(any())).thenAnswer(
          (_) async => Right((
            recipes: tRecipes,
            nextCursor: null,
            hasMore: false,
          )),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadCookbook()),
      expect: () => [
        const CookbookLoading(),
        isA<CookbookLoaded>()
            .having((s) => s.recipes.length, 'recipes', 2)
            .having((s) => s.hasMore, 'hasMore', false),
      ],
    );

    blocTest<CookbookBloc, CookbookState>(
      'emits [Loading, Empty] when no recipes',
      build: () {
        when(() => mockGetSavedRecipes(any())).thenAnswer(
          (_) async => Right((
            recipes: <Recipe>[],
            nextCursor: null,
            hasMore: false,
          )),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadCookbook()),
      expect: () => [
        const CookbookLoading(),
        const CookbookEmpty(),
      ],
    );

    blocTest<CookbookBloc, CookbookState>(
      'emits [Loading, Error] on failure',
      build: () {
        when(() => mockGetSavedRecipes(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Server error')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadCookbook()),
      expect: () => [
        const CookbookLoading(),
        const CookbookError(message: 'Server error'),
      ],
    );
  });

  group('UnsaveFromList', () {
    blocTest<CookbookBloc, CookbookState>(
      'optimistically removes recipe from list',
      build: () {
        when(() => mockUnsaveRecipe(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => CookbookLoaded(
        recipes: tRecipes,
        hasMore: false,
      ),
      act: (bloc) =>
          bloc.add(const UnsaveFromList(recipeId: 'r1')),
      expect: () => [
        isA<CookbookLoaded>()
            .having((s) => s.recipes.length, 'recipes', 1)
            .having(
                (s) => s.recipes.first.id, 'remaining', 'r2'),
      ],
    );

    blocTest<CookbookBloc, CookbookState>(
      'emits Empty when last recipe is unsaved',
      build: () {
        when(() => mockUnsaveRecipe(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => const CookbookLoaded(
        recipes: [
          Recipe(
            id: 'r1',
            title: 'Only Recipe',
            cookingTimeMinutes: 10,
            isSaved: true,
          ),
        ],
        hasMore: false,
      ),
      act: (bloc) =>
          bloc.add(const UnsaveFromList(recipeId: 'r1')),
      expect: () => [const CookbookEmpty()],
    );
  });

  group('LoadMoreCookbook', () {
    blocTest<CookbookBloc, CookbookState>(
      'appends more recipes to existing list',
      build: () {
        when(() => mockGetSavedRecipes(any())).thenAnswer(
          (_) async => Right((
            recipes: [
              const Recipe(
                id: 'r3',
                title: 'New Recipe',
                cookingTimeMinutes: 15,
                isSaved: true,
              ),
            ],
            nextCursor: null,
            hasMore: false,
          )),
        );
        return bloc;
      },
      seed: () => CookbookLoaded(
        recipes: tRecipes,
        hasMore: true,
        nextCursor: 'cursor-1',
      ),
      act: (bloc) => bloc.add(const LoadMoreCookbook()),
      expect: () => [
        // isLoadingMore = true
        isA<CookbookLoaded>()
            .having((s) => s.isLoadingMore, 'loading', true),
        // appended result
        isA<CookbookLoaded>()
            .having((s) => s.recipes.length, 'total', 3)
            .having((s) => s.hasMore, 'hasMore', false),
      ],
    );
  });
}
