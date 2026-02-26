import 'package:equatable/equatable.dart';

/// GroceryItem domain entity — a single item in the grocery list.
class GroceryItem extends Equatable {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final String category;
  final List<String> sourceRecipes;
  final bool isChecked;
  final bool isManual;

  const GroceryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.category = 'Other',
    this.sourceRecipes = const [],
    this.isChecked = false,
    this.isManual = false,
  });

  GroceryItem copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    String? category,
    List<String>? sourceRecipes,
    bool? isChecked,
    bool? isManual,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      sourceRecipes: sourceRecipes ?? this.sourceRecipes,
      isChecked: isChecked ?? this.isChecked,
      isManual: isManual ?? this.isManual,
    );
  }

  @override
  List<Object?> get props => [id];
}

/// Grocery list category group — a group of items under one category.
class GroceryCategoryGroup extends Equatable {
  final String name;
  final String emoji;
  final List<GroceryItem> items;

  const GroceryCategoryGroup({
    required this.name,
    required this.emoji,
    this.items = const [],
  });

  @override
  List<Object?> get props => [name, items];
}

/// Summary of grocery list status.
class GrocerySummary extends Equatable {
  final int totalItems;
  final int checkedItems;
  final int remainingItems;

  const GrocerySummary({
    this.totalItems = 0,
    this.checkedItems = 0,
    this.remainingItems = 0,
  });

  @override
  List<Object?> get props => [totalItems, checkedItems, remainingItems];
}
