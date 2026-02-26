import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_planner/features/cookbook/presentation/bloc/cookbook_bloc.dart';
import 'package:recipe_planner/features/cookbook/presentation/pages/cookbook_page.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';

class MockCookbookBloc extends MockBloc<CookbookEvent, CookbookState>
    implements CookbookBloc {}

void main() {
  late MockCookbookBloc mockBloc;

  setUp(() {
    mockBloc = MockCookbookBloc();
  });

  Widget buildWidget() {
    return MaterialApp(
      home: BlocProvider<CookbookBloc>.value(
        value: mockBloc,
        child: const CookbookPage(),
      ),
    );
  }

  group('CookbookPage', () {
    testWidgets('shows loading indicator when loading', (tester) async {
      when(() => mockBloc.state).thenReturn(const CookbookLoading());

      await tester.pumpWidget(buildWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state with CTA when no recipes', (tester) async {
      when(() => mockBloc.state).thenReturn(const CookbookEmpty());

      await tester.pumpWidget(buildWidget());

      expect(find.text('No saved recipes'), findsOneWidget);
      expect(find.text('Explore Recipes'), findsOneWidget);
    });

    testWidgets('shows error state with retry button', (tester) async {
      when(() => mockBloc.state)
          .thenReturn(const CookbookError(message: 'Network error'));

      await tester.pumpWidget(buildWidget());

      expect(find.text('Network error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows grid of recipes when loaded', (tester) async {
      when(() => mockBloc.state).thenReturn(const CookbookLoaded(
        recipes: [
          Recipe(
            id: 'r1',
            title: 'Grilled Salmon',
            cookingTimeMinutes: 25,
            calories: 380,
            isSaved: true,
          ),
          Recipe(
            id: 'r2',
            title: 'Chicken Stir-Fry',
            cookingTimeMinutes: 20,
            isSaved: true,
          ),
        ],
        hasMore: false,
      ));

      await tester.pumpWidget(buildWidget());

      expect(find.text('Grilled Salmon'), findsOneWidget);
      expect(find.text('Chicken Stir-Fry'), findsOneWidget);
      expect(find.text('25 min'), findsOneWidget);
      expect(find.text('380 cal'), findsOneWidget);
    });

    testWidgets('shows appbar with My Cookbook title', (tester) async {
      when(() => mockBloc.state).thenReturn(const CookbookEmpty());

      await tester.pumpWidget(buildWidget());

      expect(find.text('My Cookbook'), findsOneWidget);
    });
  });
}
