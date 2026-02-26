import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_planner/features/home/domain/entities/ingredient.dart';
import 'package:recipe_planner/features/recipe_detail/presentation/widgets/ingredients_tab.dart';

void main() {
  const tIngredients = [
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
    Ingredient(
      id: 'ing-3',
      name: 'Milk',
      quantity: 1,
      unit: 'cup',
      category: 'Dairy',
      displayOrder: 2,
    ),
  ];

  Widget buildWidget({
    List<Ingredient> ingredients = tIngredients,
    int defaultServings = 2,
    int currentServings = 2,
    Set<String> checkedIngredients = const {},
    ValueChanged<int>? onServingsChanged,
    ValueChanged<String>? onIngredientToggle,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: IngredientsTab(
            ingredients: ingredients,
            defaultServings: defaultServings,
            currentServings: currentServings,
            checkedIngredients: checkedIngredients,
            onServingsChanged: onServingsChanged,
            onIngredientToggle: onIngredientToggle,
          ),
        ),
      ),
    );
  }

  group('IngredientsTab', () {
    testWidgets('displays all ingredients', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Servings'), findsOneWidget);
      // Flour: 200 g
      expect(find.textContaining('Flour'), findsOneWidget);
      // Sugar: 100 g
      expect(find.textContaining('Sugar'), findsOneWidget);
      // Milk: 1 cup
      expect(find.textContaining('Milk'), findsOneWidget);
    });

    testWidgets('shows current servings in dropdown', (tester) async {
      await tester.pumpWidget(buildWidget(currentServings: 4));

      // Dropdown should show "4"
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('displays adjusted quantities for different servings',
        (tester) async {
      await tester.pumpWidget(buildWidget(
        defaultServings: 2,
        currentServings: 4,
      ));

      // Flour was 200g for 2 servings → 400g for 4 servings
      expect(find.textContaining('400'), findsOneWidget);
      // Sugar was 100g for 2 servings → 200g for 4 servings
      expect(find.textContaining('200'), findsOneWidget);
      // Milk was 1 cup for 2 servings → 2 cups for 4 servings
      expect(find.textContaining('2'), findsWidgets);
    });

    testWidgets('shows checkboxes for each ingredient', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byType(Checkbox), findsNWidgets(3));
    });

    testWidgets('checked ingredient shows strikethrough', (tester) async {
      await tester.pumpWidget(buildWidget(
        checkedIngredients: {'ing-1'},
      ));

      // Find the text widget for Flour and verify decoration
      final flourText = find.textContaining('Flour');
      expect(flourText, findsOneWidget);
      final textWidget = tester.widget<Text>(flourText);
      expect(textWidget.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('tapping checkbox calls onIngredientToggle', (tester) async {
      String? toggledId;
      await tester.pumpWidget(buildWidget(
        onIngredientToggle: (id) => toggledId = id,
      ));

      // Tap first checkbox
      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();

      expect(toggledId, 'ing-1');
    });

    testWidgets('shows category as subtitle', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Dry'), findsNWidgets(2));
      expect(find.text('Dairy'), findsOneWidget);
    });

    testWidgets('displays empty state when no ingredients', (tester) async {
      await tester.pumpWidget(buildWidget(ingredients: const []));

      expect(find.text('Servings'), findsOneWidget);
      expect(find.byType(Checkbox), findsNothing);
    });
  });
}
