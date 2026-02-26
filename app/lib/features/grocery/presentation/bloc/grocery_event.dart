part of 'grocery_bloc.dart';

/// Events for the Grocery BLoC.
abstract class GroceryEvent extends Equatable {
  const GroceryEvent();

  @override
  List<Object?> get props => [];
}

/// Load the grocery list for a given week.
class LoadGroceryList extends GroceryEvent {
  final String? weekStart;

  const LoadGroceryList({this.weekStart});

  @override
  List<Object?> get props => [weekStart];
}

/// Toggle the checked state of a grocery item.
class ToggleItem extends GroceryEvent {
  final String id;

  const ToggleItem({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Clear all completed (checked) items.
class ClearCompleted extends GroceryEvent {
  const ClearCompleted();
}

/// Add a manual grocery item.
class AddManualItem extends GroceryEvent {
  final String name;
  final double quantity;
  final String unit;
  final String category;

  const AddManualItem({
    required this.name,
    required this.quantity,
    required this.unit,
    this.category = 'Other',
  });

  @override
  List<Object?> get props => [name, quantity, unit, category];
}

/// Delete a grocery item.
class DeleteItem extends GroceryEvent {
  final String id;

  const DeleteItem({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Share the current grocery list.
class ShareList extends GroceryEvent {
  const ShareList();
}

/// Regenerate the grocery list from meal plan.
class RegenerateList extends GroceryEvent {
  final String? weekStart;

  const RegenerateList({this.weekStart});

  @override
  List<Object?> get props => [weekStart];
}
