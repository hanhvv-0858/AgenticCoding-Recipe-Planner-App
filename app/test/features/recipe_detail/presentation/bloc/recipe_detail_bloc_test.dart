import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/features/home/domain/entities/cooking_step.dart';
import 'package:recipe_planner/features/home/domain/entities/ingredient.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';
import 'package:recipe_planner/features/recipe_detail/domain/usecases/get_recipe_detail.dart';
import 'package:recipe_planner/features/recipe_detail/domain/usecases/save_recipe.dart';
import 'package:recipe_planner/features/recipe_detail/domain/usecases/unsave_recipe.dart';
import 'package:recipe_planner/features/recipe_detail/presentation/bloc/recipe_detail_bloc.dart';

// Mocks
class MockGetRecipeDetail extends Mock implements GetRecipeDetail {}

class MockSaveRecipe extends Mock implements SaveRecipe {}

class MockUnsaveRecipe extends Mock implements UnsaveRecipe {}

void main() {
  late RecipeDetailBloc bloc;
  late MockGetRecipeDetail mockGetRecipeDetail;
  late MockSaveRecipe mockSaveRecipe;
  late MockUnsaveRecipe mockUnsaveRecipe;

  const tRecipeId = 'recipe-123';

  final tRecipe = Recipe(
    id: tRecipeId,
    title: 'Test Recipe',
    description: 'A delicious test recipe',
    cookingTimeMinutes: 30,
    calories: 450,
    rating: 4.5,
    defaultServings: 2,
    isSaved: false,
    viewCount: 10,
    saveCount: 5,
    ingredients: const [
      Ingredient(
        id: 'ing-1',
        name: 'Flour',
        quantity: 200,
        unit: 'g',
        category: 'Dry',
        displayOrder: 0,
      ),
      Ingredient(
        id: 'ing-2',
        name: 'Sugar',
        quantity: 100,
        unit: 'g',
        category: 'Dry',
        displayOrder: 1,
      ),
    ],
    steps: const [
      CookingStep(
        id: 'step-1',
        stepNumber: 1,
        instruction: 'Mix ingredients',
      ),
      CookingStep(
        id: 'step-2',
        stepNumber: 2,
        instruction: 'Bake at 180°C',
      ),
    ],
  );

  setUp(() {
    mockGetRecipeDetail = MockGetRecipeDetail();
    mockSaveRecipe = MockSaveRecipe();
    mockUnsaveRecipe = MockUnsaveRecipe();

    // Register fallback values
    registerFallbackValue(const GetRecipeDetailParams(id: ''));
    registerFallbackValue(const SaveRecipeParams(recipeId: ''));
    registerFallbackValue(const UnsaveRecipeParams(recipeId: ''));

    bloc = RecipeDetailBloc(
      getRecipeDetail: mockGetRecipeDetail,
      saveRecipe: mockSaveRecipe,
      unsaveRecipe: mockUnsaveRecipe,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state is RecipeDetailInitial', () {
    expect(bloc.state, equals(const RecipeDetailInitial()));
  });

  group('LoadRecipeDetail', () {
    blocTest<RecipeDetailBloc, RecipeDetailState>(
      'emits [Loading, Loaded] when getRecipeDetail succeeds',
      build: () {
        when(() => mockGetRecipeDetail(any()))
            .thenAnswer((_) async => Right(tRecipe));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadRecipeDetail(id: tRecipeId)),
      expect: () => [
        const RecipeDetailLoading(),
        RecipeDetailLoaded(
          recipe: tRecipe,
          currentServings: tRecipe.defaultServings,
        ),
      ],
      verify: (_) {
        verify(() => mockGetRecipeDetail(
              const GetRecipeDetailParams(id: tRecipeId),
            )).called(1);
      },
    );

    blocTest<RecipeDetailBloc, RecipeDetailState>(
      'emits [Loading, Error] when getRecipeDetail fails',
      build: () {
        when(() => mockGetRecipeDetail(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Server error')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadRecipeDetail(id: tRecipeId)),
      expect: () => [
        const RecipeDetailLoading(),
        const RecipeDetailError(message: 'Server error'),
      ],
    );
  });

  group('AdjustServings', () {
    blocTest<RecipeDetailBloc, RecipeDetailState>(
      'emits updated Loaded state with new servings count',
      build: () {
        when(() => mockGetRecipeDetail(any()))
            .thenAnswer((_) async => Right(tRecipe));
        return bloc;
      },
      seed: () => RecipeDetailLoaded(
        recipe: tRecipe,
        currentServings: 2,
      ),
      act: (bloc) => bloc.add(const AdjustServings(servings: 4)),
      expect: () => [
        RecipeDetailLoaded(
          recipe: tRecipe,
          currentServings: 4,
        ),
      ],
    );

    blocTest<RecipeDetailBloc, RecipeDetailState>(
      'does nothing when state is not Loaded',
      build: () => bloc,
      act: (bloc) => bloc.add(const AdjustServings(servings: 4)),
      expect: () => [],
    );
  });

  group('ToggleIngredientCheck', () {
    blocTest<RecipeDetailBloc, RecipeDetailState>(
      'adds ingredient to checked set',
      build: () => bloc,
      seed: () => RecipeDetailLoaded(
        recipe: tRecipe,
        currentServings: 2,
      ),
      act: (bloc) =>
          bloc.add(const ToggleIngredientCheck(ingredientId: 'ing-1')),
      expect: () => [
        RecipeDetailLoaded(
          recipe: tRecipe,
          currentServings: 2,
          checkedIngredients: const {'ing-1'},
        ),
      ],
    );

    blocTest<RecipeDetailBloc, RecipeDetailState>(
      'removes ingredient from checked set when already checked',
      build: () => bloc,
      seed: () => RecipeDetailLoaded(
        recipe: tRecipe,
        currentServings: 2,
        checkedIngredients: const {'ing-1'},
      ),
      act: (bloc) =>
          bloc.add(const ToggleIngredientCheck(ingredientId: 'ing-1')),
      expect: () => [
        RecipeDetailLoaded(
          recipe: tRecipe,
          currentServings: 2,
          checkedIngredients: const <String>{},
        ),
      ],
    );
  });

  group('SaveRecipeToggle', () {
    blocTest<RecipeDetailBloc, RecipeDetailState>(
      'saves unsaved recipe — emits isSaving=true then isSaved=true',
      build: () {
        when(() => mockSaveRecipe(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => RecipeDetailLoaded(
        recipe: tRecipe, // isSaved: false
        currentServings: 2,
      ),
      act: (bloc) => bloc.add(const SaveRecipeToggle()),
      expect: () => [
        RecipeDetailLoaded(
          recipe: tRecipe,
          currentServings: 2,
          isSaving: true,
        ),
        RecipeDetailLoaded(
          recipe: tRecipe.copyWith(isSaved: true),
          currentServings: 2,
          isSaving: false,
        ),
      ],
    );

    blocTest<RecipeDetailBloc, RecipeDetailState>(
      'unsaves saved recipe — emits isSaving=true then isSaved=false',
      build: () {
        when(() => mockUnsaveRecipe(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => RecipeDetailLoaded(
        recipe: tRecipe.copyWith(isSaved: true),
        currentServings: 2,
      ),
      act: (bloc) => bloc.add(const SaveRecipeToggle()),
      expect: () => [
        RecipeDetailLoaded(
          recipe: tRecipe.copyWith(isSaved: true),
          currentServings: 2,
          isSaving: true,
        ),
        RecipeDetailLoaded(
          recipe: tRecipe.copyWith(isSaved: false),
          currentServings: 2,
          isSaving: false,
        ),
      ],
    );

    blocTest<RecipeDetailBloc, RecipeDetailState>(
      'reverts isSaving on save failure',
      build: () {
        when(() => mockSaveRecipe(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Save failed')),
        );
        return bloc;
      },
      seed: () => RecipeDetailLoaded(
        recipe: tRecipe,
        currentServings: 2,
      ),
      act: (bloc) => bloc.add(const SaveRecipeToggle()),
      expect: () => [
        RecipeDetailLoaded(
          recipe: tRecipe,
          currentServings: 2,
          isSaving: true,
        ),
        RecipeDetailLoaded(
          recipe: tRecipe,
          currentServings: 2,
          isSaving: false,
        ),
      ],
    );
  });
}
