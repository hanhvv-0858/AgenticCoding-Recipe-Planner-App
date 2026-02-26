import 'package:recipe_planner/features/home/domain/entities/ingredient.dart';

/// Ingredient model with JSON serialization.
class IngredientModel extends Ingredient {
  const IngredientModel({
    required super.id,
    required super.name,
    required super.quantity,
    required super.unit,
    super.category,
    super.displayOrder,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      category: json['category'] as String? ?? 'Other',
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'category': category,
      'display_order': displayOrder,
    };
  }
}
