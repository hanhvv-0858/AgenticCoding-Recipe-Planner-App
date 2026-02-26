import 'package:recipe_planner/features/grocery/domain/entities/grocery_item.dart';

/// GroceryItemModel — data layer model with JSON serialization.
class GroceryItemModel extends GroceryItem {
  const GroceryItemModel({
    required super.id,
    required super.name,
    required super.quantity,
    required super.unit,
    super.category = 'Other',
    super.sourceRecipes = const [],
    super.isChecked = false,
    super.isManual = false,
  });

  factory GroceryItemModel.fromJson(Map<String, dynamic> json) {
    return GroceryItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      category: json['category'] as String? ?? 'Other',
      sourceRecipes: (json['source_recipes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isChecked: json['is_checked'] as bool? ?? false,
      isManual: json['is_manual'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'category': category,
      'source_recipes': sourceRecipes,
      'is_checked': isChecked,
      'is_manual': isManual,
    };
  }
}

/// GroceryCategoryGroupModel — data layer model for grouped response.
class GroceryCategoryGroupModel extends GroceryCategoryGroup {
  const GroceryCategoryGroupModel({
    required super.name,
    required super.emoji,
    super.items = const [],
  });

  factory GroceryCategoryGroupModel.fromJson(Map<String, dynamic> json) {
    return GroceryCategoryGroupModel(
      name: json['name'] as String,
      emoji: json['emoji'] as String? ?? '📦',
      items: (json['items'] as List<dynamic>?)
              ?.map(
                  (e) => GroceryItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// GrocerySummaryModel — data layer model for summary data.
class GrocerySummaryModel extends GrocerySummary {
  const GrocerySummaryModel({
    super.totalItems = 0,
    super.checkedItems = 0,
    super.remainingItems = 0,
  });

  factory GrocerySummaryModel.fromJson(Map<String, dynamic> json) {
    return GrocerySummaryModel(
      totalItems: json['total_items'] as int? ?? 0,
      checkedItems: json['checked_items'] as int? ?? 0,
      remainingItems: json['remaining_items'] as int? ?? 0,
    );
  }
}
