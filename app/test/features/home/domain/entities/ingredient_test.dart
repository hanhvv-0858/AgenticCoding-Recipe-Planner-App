import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_planner/features/home/domain/entities/ingredient.dart';

void main() {
  group('Ingredient.adjustForServings', () {
    const ingredient = Ingredient(
      id: 'ing-1',
      name: 'Flour',
      quantity: 200,
      unit: 'g',
      category: 'Dry',
      displayOrder: 0,
    );

    test('doubles quantity when servings go from 2 to 4', () {
      final adjusted = ingredient.adjustForServings(2, 4);

      expect(adjusted.quantity, 400);
      expect(adjusted.name, 'Flour');
      expect(adjusted.unit, 'g');
      expect(adjusted.id, 'ing-1');
      expect(adjusted.category, 'Dry');
      expect(adjusted.displayOrder, 0);
    });

    test('halves quantity when servings go from 4 to 2', () {
      final adjusted = ingredient.adjustForServings(4, 2);

      expect(adjusted.quantity, 100);
    });

    test('keeps quantity the same when servings unchanged', () {
      final adjusted = ingredient.adjustForServings(2, 2);

      expect(adjusted.quantity, 200);
    });

    test('computes correctly for servings = 1', () {
      final adjusted = ingredient.adjustForServings(2, 1);

      expect(adjusted.quantity, 100);
    });

    test('computes correctly for servings = 50', () {
      final adjusted = ingredient.adjustForServings(2, 50);

      expect(adjusted.quantity, 5000);
    });

    test('handles non-integer results for odd servings', () {
      final adjusted = ingredient.adjustForServings(2, 3);

      expect(adjusted.quantity, 300);
    });

    test('handles fractional initial quantities', () {
      const halfIngredient = Ingredient(
        id: 'ing-2',
        name: 'Butter',
        quantity: 0.5,
        unit: 'cup',
      );

      final adjusted = halfIngredient.adjustForServings(2, 4);

      expect(adjusted.quantity, 1.0);
    });

    test('handles default servings = 1', () {
      final adjusted = ingredient.adjustForServings(1, 3);

      expect(adjusted.quantity, 600);
    });

    test('preserves all non-quantity fields', () {
      const full = Ingredient(
        id: 'test-id',
        name: 'Test Ingredient',
        quantity: 10,
        unit: 'ml',
        category: 'Liquid',
        displayOrder: 5,
      );

      final adjusted = full.adjustForServings(2, 4);

      expect(adjusted.id, 'test-id');
      expect(adjusted.name, 'Test Ingredient');
      expect(adjusted.unit, 'ml');
      expect(adjusted.category, 'Liquid');
      expect(adjusted.displayOrder, 5);
      expect(adjusted.quantity, 20);
    });
  });
}
