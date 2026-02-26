import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_planner/core/constants/app_constants.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';
import 'package:recipe_planner/features/planner/domain/entities/meal_plan.dart';
import 'package:recipe_planner/features/planner/domain/entities/meal_slot.dart';
import 'package:recipe_planner/features/planner/domain/usecases/add_meal_slot.dart';
import 'package:recipe_planner/features/planner/domain/usecases/create_meal_plan.dart';
import 'package:recipe_planner/features/planner/domain/usecases/get_week_meal_plans.dart';
import 'package:recipe_planner/features/planner/domain/usecases/remove_meal_slot.dart';
import 'package:recipe_planner/features/planner/domain/usecases/update_meal_slot.dart';
import 'package:recipe_planner/features/planner/presentation/bloc/planner_bloc.dart';

class MockGetWeekMealPlans extends Mock implements GetWeekMealPlans {}

class MockCreateMealPlan extends Mock implements CreateMealPlan {}

class MockAddMealSlot extends Mock implements AddMealSlot {}

class MockUpdateMealSlot extends Mock implements UpdateMealSlot {}

class MockRemoveMealSlot extends Mock implements RemoveMealSlot {}

class FakeGetWeekMealPlansParams extends Fake
    implements GetWeekMealPlansParams {}

class FakeCreateMealPlanParams extends Fake implements CreateMealPlanParams {}

class FakeAddMealSlotParams extends Fake implements AddMealSlotParams {}

class FakeUpdateMealSlotParams extends Fake implements UpdateMealSlotParams {}

class FakeRemoveMealSlotParams extends Fake implements RemoveMealSlotParams {}

void main() {
  late PlannerBloc plannerBloc;
  late MockGetWeekMealPlans mockGetWeekMealPlans;
  late MockCreateMealPlan mockCreateMealPlan;
  late MockAddMealSlot mockAddMealSlot;
  late MockUpdateMealSlot mockUpdateMealSlot;
  late MockRemoveMealSlot mockRemoveMealSlot;

  // Use a fixed Monday for deterministic tests
  final tMonday = DateTime(2025, 1, 6); // Monday
  final tTuesday = DateTime(2025, 1, 7);

  const tRecipe = Recipe(
    id: 'recipe-1',
    title: 'Grilled Salmon',
    cookingTimeMinutes: 25,
    calories: 450,
  );

  final tSlot = MealSlot(
    id: 'slot-1',
    mealType: MealType.lunch,
    recipe: tRecipe,
    servings: 2,
    displayOrder: 0,
  );

  final tMondayPlan = MealPlan(
    id: 'plan-1',
    userId: 'user-1',
    date: tMonday,
    slots: [tSlot],
  );

  final tTuesdayPlan = MealPlan(
    id: 'plan-2',
    userId: 'user-1',
    date: tTuesday,
    slots: [],
  );

  final tWeekPlans = [tMondayPlan, tTuesdayPlan];

  setUpAll(() {
    registerFallbackValue(FakeGetWeekMealPlansParams());
    registerFallbackValue(FakeCreateMealPlanParams());
    registerFallbackValue(FakeAddMealSlotParams());
    registerFallbackValue(FakeUpdateMealSlotParams());
    registerFallbackValue(FakeRemoveMealSlotParams());
  });

  setUp(() {
    mockGetWeekMealPlans = MockGetWeekMealPlans();
    mockCreateMealPlan = MockCreateMealPlan();
    mockAddMealSlot = MockAddMealSlot();
    mockUpdateMealSlot = MockUpdateMealSlot();
    mockRemoveMealSlot = MockRemoveMealSlot();

    plannerBloc = PlannerBloc(
      getWeekMealPlans: mockGetWeekMealPlans,
      createMealPlan: mockCreateMealPlan,
      addMealSlot: mockAddMealSlot,
      updateMealSlot: mockUpdateMealSlot,
      removeMealSlot: mockRemoveMealSlot,
    );
  });

  tearDown(() => plannerBloc.close());

  test('initial state is PlannerInitial', () {
    expect(plannerBloc.state, const PlannerInitial());
  });

  group('LoadWeek', () {
    blocTest<PlannerBloc, PlannerState>(
      'emits [PlannerLoading, PlannerLoaded] when fetched successfully',
      build: () {
        when(() => mockGetWeekMealPlans(any()))
            .thenAnswer((_) async => Right(tWeekPlans));
        return plannerBloc;
      },
      act: (bloc) => bloc.add(LoadWeek(startDate: tMonday)),
      expect: () => [
        const PlannerLoading(),
        isA<PlannerLoaded>()
            .having((s) => s.weekPlans.length, 'weekPlans count', 2)
            .having((s) => s.weekStart, 'weekStart', tMonday),
      ],
    );

    blocTest<PlannerBloc, PlannerState>(
      'emits [PlannerLoading, PlannerError] when fetch fails',
      build: () {
        when(() => mockGetWeekMealPlans(any())).thenAnswer(
            (_) async => const Left(ServerFailure(message: 'Network error')));
        return plannerBloc;
      },
      act: (bloc) => bloc.add(LoadWeek(startDate: tMonday)),
      expect: () => [
        const PlannerLoading(),
        const PlannerError(message: 'Network error'),
      ],
    );

    blocTest<PlannerBloc, PlannerState>(
      'computes weekStart as Monday even if startDate is Wednesday',
      build: () {
        when(() => mockGetWeekMealPlans(any()))
            .thenAnswer((_) async => Right(tWeekPlans));
        return plannerBloc;
      },
      act: (bloc) =>
          bloc.add(LoadWeek(startDate: DateTime(2025, 1, 8))), // Wednesday
      expect: () => [
        const PlannerLoading(),
        isA<PlannerLoaded>().having((s) => s.weekStart, 'weekStart', tMonday),
      ],
    );

    blocTest<PlannerBloc, PlannerState>(
      'emits PlannerLoaded with empty weekPlans when no plans exist',
      build: () {
        when(() => mockGetWeekMealPlans(any()))
            .thenAnswer((_) async => const Right([]));
        return plannerBloc;
      },
      act: (bloc) => bloc.add(LoadWeek(startDate: tMonday)),
      expect: () => [
        const PlannerLoading(),
        isA<PlannerLoaded>().having((s) => s.weekPlans, 'weekPlans', isEmpty),
      ],
    );
  });

  group('SelectDay', () {
    blocTest<PlannerBloc, PlannerState>(
      'emits PlannerLoaded with new selectedDate and selectedDayPlan',
      build: () {
        when(() => mockGetWeekMealPlans(any()))
            .thenAnswer((_) async => Right(tWeekPlans));
        return plannerBloc;
      },
      seed: () => PlannerLoaded(
        weekPlans: tWeekPlans,
        selectedDate: tMonday,
        selectedDayPlan: tMondayPlan,
        nutritionSummary: tMondayPlan.nutritionSummary,
        weekStart: tMonday,
      ),
      act: (bloc) => bloc.add(SelectDay(date: tTuesday)),
      expect: () => [
        isA<PlannerLoaded>()
            .having((s) => s.selectedDate, 'selectedDate', tTuesday)
            .having((s) => s.selectedDayPlan, 'selectedDayPlan', tTuesdayPlan)
            .having((s) => s.nutritionSummary.calories, 'calories', 0),
      ],
    );

    blocTest<PlannerBloc, PlannerState>(
      'sets selectedDayPlan to null when no plan exists for date',
      build: () {
        return plannerBloc;
      },
      seed: () => PlannerLoaded(
        weekPlans: tWeekPlans,
        selectedDate: tMonday,
        selectedDayPlan: tMondayPlan,
        nutritionSummary: tMondayPlan.nutritionSummary,
        weekStart: tMonday,
      ),
      act: (bloc) =>
          bloc.add(SelectDay(date: DateTime(2025, 1, 10))), // Friday, no plan
      expect: () => [
        isA<PlannerLoaded>()
            .having((s) => s.selectedDayPlan, 'selectedDayPlan', isNull)
            .having((s) => s.nutritionSummary.calories, 'calories', 0),
      ],
    );

    blocTest<PlannerBloc, PlannerState>(
      'updates nutrition summary based on selected day plan',
      build: () {
        return plannerBloc;
      },
      seed: () => PlannerLoaded(
        weekPlans: tWeekPlans,
        selectedDate: tTuesday,
        selectedDayPlan: tTuesdayPlan,
        nutritionSummary: const NutritionSummary(),
        weekStart: tMonday,
      ),
      act: (bloc) => bloc.add(SelectDay(date: tMonday)),
      expect: () => [
        isA<PlannerLoaded>()
            .having((s) => s.nutritionSummary.calories, 'calories', 450),
      ],
    );
  });

  group('AddRecipeToSlot', () {
    blocTest<PlannerBloc, PlannerState>(
      'calls addMealSlot use case and reloads week on success',
      build: () {
        when(() => mockAddMealSlot(any()))
            .thenAnswer((_) async => Right(tSlot));
        when(() => mockGetWeekMealPlans(any()))
            .thenAnswer((_) async => Right(tWeekPlans));
        return plannerBloc;
      },
      seed: () => PlannerLoaded(
        weekPlans: tWeekPlans,
        selectedDate: tMonday,
        selectedDayPlan: tMondayPlan,
        nutritionSummary: tMondayPlan.nutritionSummary,
        weekStart: tMonday,
      ),
      act: (bloc) => bloc.add(const AddRecipeToSlot(
        planId: 'plan-1',
        mealType: MealType.lunch,
        recipeId: 'recipe-1',
        servings: 2,
      )),
      verify: (_) {
        verify(() => mockAddMealSlot(any())).called(1);
        verify(() => mockGetWeekMealPlans(any())).called(1);
      },
    );

    blocTest<PlannerBloc, PlannerState>(
      'emits PlannerError when addMealSlot fails',
      build: () {
        when(() => mockAddMealSlot(any())).thenAnswer(
            (_) async => const Left(ServerFailure(message: 'Failed to add')));
        return plannerBloc;
      },
      seed: () => PlannerLoaded(
        weekPlans: tWeekPlans,
        selectedDate: tMonday,
        selectedDayPlan: tMondayPlan,
        nutritionSummary: tMondayPlan.nutritionSummary,
        weekStart: tMonday,
      ),
      act: (bloc) => bloc.add(const AddRecipeToSlot(
        planId: 'plan-1',
        mealType: MealType.dinner,
        recipeId: 'recipe-2',
      )),
      expect: () => [
        const PlannerError(message: 'Failed to add'),
      ],
    );
  });

  group('RemoveSlot', () {
    blocTest<PlannerBloc, PlannerState>(
      'calls removeMealSlot use case and reloads week on success',
      build: () {
        when(() => mockRemoveMealSlot(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetWeekMealPlans(any()))
            .thenAnswer((_) async => Right(tWeekPlans));
        return plannerBloc;
      },
      seed: () => PlannerLoaded(
        weekPlans: tWeekPlans,
        selectedDate: tMonday,
        selectedDayPlan: tMondayPlan,
        nutritionSummary: tMondayPlan.nutritionSummary,
        weekStart: tMonday,
      ),
      act: (bloc) => bloc.add(const RemoveSlot(
        planId: 'plan-1',
        slotId: 'slot-1',
      )),
      verify: (_) {
        verify(() => mockRemoveMealSlot(any())).called(1);
        verify(() => mockGetWeekMealPlans(any())).called(1);
      },
    );

    blocTest<PlannerBloc, PlannerState>(
      'emits PlannerError when removeMealSlot fails',
      build: () {
        when(() => mockRemoveMealSlot(any())).thenAnswer((_) async =>
            const Left(ServerFailure(message: 'Failed to remove')));
        return plannerBloc;
      },
      seed: () => PlannerLoaded(
        weekPlans: tWeekPlans,
        selectedDate: tMonday,
        selectedDayPlan: tMondayPlan,
        nutritionSummary: tMondayPlan.nutritionSummary,
        weekStart: tMonday,
      ),
      act: (bloc) => bloc.add(const RemoveSlot(
        planId: 'plan-1',
        slotId: 'slot-1',
      )),
      expect: () => [
        const PlannerError(message: 'Failed to remove'),
      ],
    );
  });

  group('MoveSlot', () {
    blocTest<PlannerBloc, PlannerState>(
      'calls updateMealSlot and reloads week on success',
      build: () {
        when(() => mockUpdateMealSlot(any()))
            .thenAnswer((_) async => Right(tSlot));
        when(() => mockGetWeekMealPlans(any()))
            .thenAnswer((_) async => Right(tWeekPlans));
        return plannerBloc;
      },
      seed: () => PlannerLoaded(
        weekPlans: tWeekPlans,
        selectedDate: tMonday,
        selectedDayPlan: tMondayPlan,
        nutritionSummary: tMondayPlan.nutritionSummary,
        weekStart: tMonday,
      ),
      act: (bloc) => bloc.add(const MoveSlot(
        planId: 'plan-1',
        slotId: 'slot-1',
        toMealType: MealType.dinner,
      )),
      verify: (_) {
        verify(() => mockUpdateMealSlot(any())).called(1);
        verify(() => mockGetWeekMealPlans(any())).called(1);
      },
    );
  });

  group('CreatePlan', () {
    blocTest<PlannerBloc, PlannerState>(
      'calls createMealPlan and reloads week on success',
      build: () {
        when(() => mockCreateMealPlan(any()))
            .thenAnswer((_) async => Right(tMondayPlan));
        when(() => mockGetWeekMealPlans(any()))
            .thenAnswer((_) async => Right(tWeekPlans));
        return plannerBloc;
      },
      seed: () => PlannerLoaded(
        weekPlans: tWeekPlans,
        selectedDate: tMonday,
        selectedDayPlan: null,
        nutritionSummary: const NutritionSummary(),
        weekStart: tMonday,
      ),
      act: (bloc) => bloc.add(CreatePlan(date: tMonday)),
      verify: (_) {
        verify(() => mockCreateMealPlan(any())).called(1);
        verify(() => mockGetWeekMealPlans(any())).called(1);
      },
    );

    blocTest<PlannerBloc, PlannerState>(
      'emits PlannerError when createMealPlan fails',
      build: () {
        when(() => mockCreateMealPlan(any())).thenAnswer((_) async =>
            const Left(ServerFailure(message: 'Plan already exists')));
        return plannerBloc;
      },
      seed: () => PlannerLoaded(
        weekPlans: tWeekPlans,
        selectedDate: tMonday,
        selectedDayPlan: null,
        nutritionSummary: const NutritionSummary(),
        weekStart: tMonday,
      ),
      act: (bloc) => bloc.add(CreatePlan(date: tMonday)),
      expect: () => [
        const PlannerError(message: 'Plan already exists'),
      ],
    );
  });

  group('NutritionSummary', () {
    test('NutritionSummary defaults to zero values', () {
      const summary = NutritionSummary();
      expect(summary.calories, 0);
      expect(summary.proteinGrams, 0);
      expect(summary.carbsGrams, 0);
    });

    test('MealPlan.nutritionSummary computes from recipe slots', () {
      final plan = MealPlan(
        id: 'p1',
        userId: 'u1',
        date: tMonday,
        slots: [
          const MealSlot(
            id: 's1',
            mealType: MealType.breakfast,
            recipe: Recipe(
              id: 'r1',
              title: 'Eggs',
              cookingTimeMinutes: 10,
              calories: 200,
            ),
          ),
          const MealSlot(
            id: 's2',
            mealType: MealType.lunch,
            recipe: Recipe(
              id: 'r2',
              title: 'Salad',
              cookingTimeMinutes: 15,
              calories: 300,
            ),
          ),
        ],
      );
      expect(plan.nutritionSummary.calories, 500);
    });

    test('MealPlan.nutritionSummary handles slots without recipes', () {
      final plan = MealPlan(
        id: 'p1',
        userId: 'u1',
        date: tMonday,
        slots: const [
          MealSlot(
            id: 's1',
            mealType: MealType.lunch,
            quickNote: 'Order pizza',
          ),
        ],
      );
      expect(plan.nutritionSummary.calories, 0);
    });
  });
}
