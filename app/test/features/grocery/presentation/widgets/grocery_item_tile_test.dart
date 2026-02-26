import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_planner/features/grocery/domain/entities/grocery_item.dart';
import 'package:recipe_planner/features/grocery/presentation/widgets/grocery_item_tile.dart';

void main() {
  const tItem = GroceryItem(
    id: '1',
    name: 'Carrots',
    quantity: 2,
    unit: 'kg',
    category: 'Vegetables',
    sourceRecipes: ['Chicken Soup', 'Stew'],
    isChecked: false,
    isManual: false,
  );

  const tCheckedItem = GroceryItem(
    id: '2',
    name: 'Onions',
    quantity: 3,
    unit: 'piece',
    category: 'Vegetables',
    sourceRecipes: [],
    isChecked: true,
    isManual: false,
  );

  const tManualItem = GroceryItem(
    id: '3',
    name: 'Sugar',
    quantity: 1,
    unit: 'kg',
    category: 'Other',
    sourceRecipes: [],
    isChecked: false,
    isManual: true,
  );

  Widget buildWidget(GroceryItem item,
      {VoidCallback? onToggle, VoidCallback? onDelete}) {
    return MaterialApp(
      home: Scaffold(
        body: GroceryItemTile(
          item: item,
          onToggle: onToggle ?? () {},
          onDelete: onDelete ?? () {},
        ),
      ),
    );
  }

  group('GroceryItemTile', () {
    testWidgets('displays item name and quantity', (tester) async {
      await tester.pumpWidget(buildWidget(tItem));

      expect(find.text('Carrots'), findsOneWidget);
      expect(find.text('2 kg'), findsOneWidget);
    });

    testWidgets('displays source recipes', (tester) async {
      await tester.pumpWidget(buildWidget(tItem));

      expect(find.text('Chicken Soup, Stew'), findsOneWidget);
    });

    testWidgets('shows unchecked checkbox for unchecked item', (tester) async {
      await tester.pumpWidget(buildWidget(tItem));

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, false);
    });

    testWidgets('shows checked checkbox for checked item', (tester) async {
      await tester.pumpWidget(buildWidget(tCheckedItem));

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, true);
    });

    testWidgets('shows manual item indicator', (tester) async {
      await tester.pumpWidget(buildWidget(tManualItem));

      expect(find.byIcon(Icons.edit_note), findsOneWidget);
    });

    testWidgets('does not show manual indicator for auto items',
        (tester) async {
      await tester.pumpWidget(buildWidget(tItem));

      expect(find.byIcon(Icons.edit_note), findsNothing);
    });

    testWidgets('calls onToggle when tapped', (tester) async {
      var toggled = false;
      await tester.pumpWidget(buildWidget(tItem, onToggle: () {
        toggled = true;
      }));

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(toggled, true);
    });

    testWidgets('formats integer quantity without decimal', (tester) async {
      await tester.pumpWidget(buildWidget(tItem));
      expect(find.text('2 kg'), findsOneWidget);
    });

    testWidgets('formats decimal quantity with one decimal', (tester) async {
      const decimalItem = GroceryItem(
        id: '4',
        name: 'Flour',
        quantity: 1.5,
        unit: 'kg',
        category: 'Grains',
        sourceRecipes: [],
        isChecked: false,
        isManual: false,
      );
      await tester.pumpWidget(buildWidget(decimalItem));
      expect(find.text('1.5 kg'), findsOneWidget);
    });
  });
}
