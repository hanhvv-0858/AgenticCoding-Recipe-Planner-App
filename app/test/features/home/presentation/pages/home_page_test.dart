import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';
import 'package:recipe_planner/features/home/domain/entities/tag.dart';
import 'package:recipe_planner/features/home/presentation/bloc/home_bloc.dart';
import 'package:recipe_planner/features/home/presentation/pages/home_page.dart';

class MockHomeBloc extends Mock implements HomeBloc {}

void main() {
  late MockHomeBloc mockHomeBloc;

  final tTags = [
    const Tag(id: '1', name: '#QuickLunch', slug: 'quick-lunch'),
  ];

  final tRecipes = [
    const Recipe(
      id: 'r1',
      title: 'Test Recipe',
      cookingTimeMinutes: 20,
      calories: 350,
    ),
  ];

  setUpAll(() {
    // Use concrete subclasses of sealed classes as fallback values
    registerFallbackValue(const HomeInitial());
    registerFallbackValue(const LoadHome());
  });

  setUp(() {
    mockHomeBloc = MockHomeBloc();
  });

  Widget buildWidget() {
    return MaterialApp(
      home: BlocProvider<HomeBloc>.value(
        value: mockHomeBloc,
        child: const HomePage(),
      ),
    );
  }

  group('HomePage', () {
    testWidgets('shows loading indicator when HomeLoading', (tester) async {
      when(() => mockHomeBloc.state).thenReturn(const HomeLoading());
      when(() => mockHomeBloc.stream)
          .thenAnswer((_) => Stream.value(const HomeLoading()));

      await tester.pumpWidget(buildWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when HomeError', (tester) async {
      const errorState = HomeError(message: 'Something went wrong');
      when(() => mockHomeBloc.state).thenReturn(errorState);
      when(() => mockHomeBloc.stream)
          .thenAnswer((_) => Stream.value(errorState));

      await tester.pumpWidget(buildWidget());

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows recipe grid when HomeLoaded', (tester) async {
      final loadedState = HomeLoaded(
        tags: tTags,
        trendingRecipes: tRecipes,
      );
      when(() => mockHomeBloc.state).thenReturn(loadedState);
      when(() => mockHomeBloc.stream)
          .thenAnswer((_) => Stream.value(loadedState));

      await tester.pumpWidget(buildWidget());

      expect(find.text('Recipe Planner'), findsOneWidget);
      expect(find.text('Trending Recipes'), findsOneWidget);
      expect(find.text('Test Recipe'), findsOneWidget);
    });

    testWidgets('shows empty state when no recipes', (tester) async {
      final loadedState = HomeLoaded(
        tags: tTags,
        trendingRecipes: const [],
      );
      when(() => mockHomeBloc.state).thenReturn(loadedState);
      when(() => mockHomeBloc.stream)
          .thenAnswer((_) => Stream.value(loadedState));

      await tester.pumpWidget(buildWidget());

      expect(find.text('No recipes found'), findsOneWidget);
    });

    testWidgets('shows search results count when searching', (tester) async {
      final loadedState = HomeLoaded(
        tags: tTags,
        trendingRecipes: tRecipes,
        searchResults: tRecipes,
      );
      when(() => mockHomeBloc.state).thenReturn(loadedState);
      when(() => mockHomeBloc.stream)
          .thenAnswer((_) => Stream.value(loadedState));

      await tester.pumpWidget(buildWidget());

      expect(find.text('Search Results (1)'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
    });
  });
}
