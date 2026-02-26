import 'package:equatable/equatable.dart';

/// Ingredient domain entity.
class Ingredient extends Equatable {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final String category;
  final int displayOrder;

  const Ingredient({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.category = 'Other',
    this.displayOrder = 0,
  });

  /// Returns a new Ingredient with quantity adjusted for [targetServings].
  Ingredient adjustForServings(int defaultServings, int targetServings) {
    return Ingredient(
      id: id,
      name: name,
      quantity: quantity * targetServings / defaultServings,
      unit: unit,
      category: category,
      displayOrder: displayOrder,
    );
  }

  Ingredient copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    String? category,
    int? displayOrder,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  @override
  List<Object?> get props => [id];
}
