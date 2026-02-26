import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/features/grocery/domain/entities/grocery_item.dart';
import 'package:recipe_planner/features/grocery/domain/usecases/add_manual_grocery_item.dart';
import 'package:recipe_planner/features/grocery/domain/usecases/clear_completed_items.dart';
import 'package:recipe_planner/features/grocery/domain/usecases/delete_grocery_item.dart';
import 'package:recipe_planner/features/grocery/domain/usecases/get_grocery_list.dart';
import 'package:recipe_planner/features/grocery/domain/usecases/toggle_grocery_item_check.dart';
import 'package:recipe_planner/features/grocery/presentation/bloc/grocery_bloc.dart';

// Mocks
class MockGetGroceryList extends Mock implements GetGroceryList {}

class MockAddManualGroceryItem extends Mock implements AddManualGroceryItem {}

class MockToggleGroceryItemCheck extends Mock
    implements ToggleGroceryItemCheck {}

class MockDeleteGroceryItem extends Mock implements DeleteGroceryItem {}

class MockClearCompletedItems extends Mock implements ClearCompletedItems {}

void main() {
  late GroceryBloc bloc;
  late MockGetGroceryList mockGetGroceryList;
  late MockAddManualGroceryItem mockAddManualItem;
  late MockToggleGroceryItemCheck mockToggleItem;
  late MockDeleteGroceryItem mockDeleteItem;
  late MockClearCompletedItems mockClearCompleted;

  setUp(() {
    mockGetGroceryList = MockGetGroceryList();
    mockAddManualItem = MockAddManualGroceryItem();
    mockToggleItem = MockToggleGroceryItemCheck();
    mockDeleteItem = MockDeleteGroceryItem();
    mockClearCompleted = MockClearCompletedItems();

    bloc = GroceryBloc(
      getGroceryList: mockGetGroceryList,
      addManualGroceryItem: mockAddManualItem,
      toggleGroceryItemCheck: mockToggleItem,
      deleteGroceryItem: mockDeleteItem,
      clearCompletedItems: mockClearCompleted,
    );

    // Register fallback values
    registerFallbackValue(const GetGroceryListParams(weekStart: '2024-01-08'));
    registerFallbackValue(const AddManualGroceryItemParams(
      name: 'Test',
      quantity: 1.0,
      unit: 'piece',
      category: 'Other',
      weekStart: '2024-01-08',
    ));
    registerFallbackValue(
        const ToggleGroceryItemCheckParams(id: 'id', isChecked: true));
    registerFallbackValue(const DeleteGroceryItemParams(id: 'id'));
    registerFallbackValue(
        const ClearCompletedItemsParams(weekStart: '2024-01-08'));
  });

  tearDown(() => bloc.close());

  // Test data
  final tCategories = [
    GroceryCategoryGroup(
      name: 'Vegetables',
      emoji: '🥬',
      items: [
        const GroceryItem(
          id: '1',
          name: 'Carrots',
          quantity: 2,
          unit: 'kg',
          category: 'Vegetables',
          sourceRecipes: ['Soup'],
          isChecked: false,
          isManual: false,
        ),
        const GroceryItem(
          id: '2',
          name: 'Onions',
          quantity: 3,
          unit: 'piece',
          category: 'Vegetables',
          sourceRecipes: ['Soup', 'Stir Fry'],
          isChecked: true,
          isManual: false,
        ),
      ],
    ),
    GroceryCategoryGroup(
      name: 'Dairy',
      emoji: '🧀',
      items: [
        const GroceryItem(
          id: '3',
          name: 'Milk',
          quantity: 1,
          unit: 'liter',
          category: 'Dairy',
          sourceRecipes: ['Pancakes'],
          isChecked: false,
          isManual: false,
        ),
      ],
    ),
  ];

  const tSummary = GrocerySummary(
    totalItems: 3,
    checkedItems: 1,
    remainingItems: 2,
  );

  group('initial state', () {
    test('should be GroceryInitial', () {
      expect(bloc.state, const GroceryInitial());
    });
  });

  group('LoadGroceryList', () {
    blocTest<GroceryBloc, GroceryState>(
      'emits [Loading, Loaded] on success',
      build: () {
        when(() => mockGetGroceryList(any())).thenAnswer(
          (_) async => Right((categories: tCategories, summary: tSummary)),
        );
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const LoadGroceryList(weekStart: '2024-01-08')),
      expect: () => [
        const GroceryLoading(),
        isA<GroceryLoaded>()
            .having((s) => s.categories.length, 'categories', 2)
            .having((s) => s.summary.totalItems, 'total', 3)
            .having((s) => s.weekStart, 'weekStart', '2024-01-08'),
      ],
    );

    blocTest<GroceryBloc, GroceryState>(
      'emits [Loading, Empty] when no items',
      build: () {
        when(() => mockGetGroceryList(any())).thenAnswer(
          (_) async => Right((
            categories: <GroceryCategoryGroup>[],
            summary: const GrocerySummary(
                totalItems: 0, checkedItems: 0, remainingItems: 0),
          )),
        );
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const LoadGroceryList(weekStart: '2024-01-08')),
      expect: () => [
        const GroceryLoading(),
        const GroceryEmpty(weekStart: '2024-01-08'),
      ],
    );

    blocTest<GroceryBloc, GroceryState>(
      'emits [Loading, Error] on failure',
      build: () {
        when(() => mockGetGroceryList(any())).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'Server error')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadGroceryList()),
      expect: () => [
        const GroceryLoading(),
        const GroceryError(message: 'Server error'),
      ],
    );
  });

  group('ToggleItem', () {
    blocTest<GroceryBloc, GroceryState>(
      'optimistically toggles item check state',
      build: () {
        when(() => mockToggleItem(any())).thenAnswer(
          (_) async => const Right(GroceryItem(
            id: '1',
            name: 'Carrots',
            quantity: 2,
            unit: 'kg',
            category: 'Vegetables',
            sourceRecipes: ['Soup'],
            isChecked: true,
            isManual: false,
          )),
        );
        return bloc;
      },
      seed: () => GroceryLoaded(
        categories: tCategories,
        summary: tSummary,
        weekStart: '2024-01-08',
      ),
      act: (bloc) => bloc.add(const ToggleItem(id: '1')),
      expect: () => [
        isA<GroceryLoaded>().having(
          (s) => s.categories.first.items.first.isChecked,
          'item checked',
          true,
        ),
      ],
    );
  });

  group('AddManualItem', () {
    blocTest<GroceryBloc, GroceryState>(
      'adds item then reloads list',
      build: () {
        when(() => mockAddManualItem(any())).thenAnswer(
          (_) async => const Right(GroceryItem(
            id: '4',
            name: 'Sugar',
            quantity: 1,
            unit: 'kg',
            category: 'Other',
            sourceRecipes: [],
            isChecked: false,
            isManual: true,
          )),
        );
        when(() => mockGetGroceryList(any())).thenAnswer(
          (_) async => Right((categories: tCategories, summary: tSummary)),
        );
        return bloc;
      },
      seed: () => GroceryLoaded(
        categories: tCategories,
        summary: tSummary,
        weekStart: '2024-01-08',
      ),
      act: (bloc) => bloc.add(const AddManualItem(
        name: 'Sugar',
        quantity: 1,
        unit: 'kg',
        category: 'Other',
      )),
      expect: () => [
        // Reload triggers Loading -> Loaded
        const GroceryLoading(),
        isA<GroceryLoaded>(),
      ],
    );
  });

  group('ClearCompleted', () {
    blocTest<GroceryBloc, GroceryState>(
      'clears completed items then reloads',
      build: () {
        when(() => mockClearCompleted(any())).thenAnswer(
          (_) async =>
              const Right((clearedCount: 1, remainingCount: 2)),
        );
        when(() => mockGetGroceryList(any())).thenAnswer(
          (_) async => Right((categories: tCategories, summary: tSummary)),
        );
        return bloc;
      },
      seed: () => GroceryLoaded(
        categories: tCategories,
        summary: tSummary,
        weekStart: '2024-01-08',
      ),
      act: (bloc) => bloc.add(const ClearCompleted()),
      expect: () => [
        const GroceryLoading(),
        isA<GroceryLoaded>(),
      ],
    );
  });

  group('DeleteItem', () {
    blocTest<GroceryBloc, GroceryState>(
      'deletes item then reloads',
      build: () {
        when(() => mockDeleteItem(any())).thenAnswer(
          (_) async => const Right(null),
        );
        when(() => mockGetGroceryList(any())).thenAnswer(
          (_) async => Right((categories: tCategories, summary: tSummary)),
        );
        return bloc;
      },
      seed: () => GroceryLoaded(
        categories: tCategories,
        summary: tSummary,
        weekStart: '2024-01-08',
      ),
      act: (bloc) => bloc.add(const DeleteItem(id: '1')),
      expect: () => [
        const GroceryLoading(),
        isA<GroceryLoaded>(),
      ],
    );
  });

  group('RegenerateList', () {
    blocTest<GroceryBloc, GroceryState>(
      'emits Loading then Loaded with regenerated data',
      build: () {
        when(() => mockGetGroceryList(any())).thenAnswer(
          (_) async => Right((categories: tCategories, summary: tSummary)),
        );
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const RegenerateList(weekStart: '2024-01-08')),
      expect: () => [
        const GroceryLoading(),
        isA<GroceryLoaded>(),
      ],
      verify: (_) {
        verify(() => mockGetGroceryList(any())).called(1);
      },
    );
  });

  group('formatShareText', () {
    test('returns empty string when not loaded', () {
      expect(bloc.formatShareText(), '');
    });

    test('formats grocery list with categories and items', () {
      bloc.emit(GroceryLoaded(
        categories: tCategories,
        summary: tSummary,
        weekStart: '2024-01-08',
      ));

      final result = bloc.formatShareText();

      expect(result, contains('🛒 Grocery List'));
      expect(result, contains('🥬 Vegetables'));
      expect(result, contains('□ Carrots — 2 kg'));
      // Onions is checked — should NOT be in share
      expect(result, isNot(contains('Onions')));
      expect(result, contains('🧀 Dairy'));
      expect(result, contains('□ Milk — 1 liter'));
      expect(result, contains('Total: 2 items'));
    });

    test('skips categories with all items checked', () {
      final allCheckedCategories = [
        GroceryCategoryGroup(
          name: 'Vegetables',
          emoji: '🥬',
          items: [
            const GroceryItem(
              id: '1',
              name: 'Carrots',
              quantity: 2,
              unit: 'kg',
              category: 'Vegetables',
              sourceRecipes: [],
              isChecked: true,
              isManual: false,
            ),
          ],
        ),
      ];

      bloc.emit(GroceryLoaded(
        categories: allCheckedCategories,
        summary: const GrocerySummary(
            totalItems: 1, checkedItems: 1, remainingItems: 0),
        weekStart: '2024-01-08',
      ));

      final result = bloc.formatShareText();
      expect(result, isNot(contains('🥬 Vegetables')));
      expect(result, contains('Total: 0 items'));
    });
  });
}
