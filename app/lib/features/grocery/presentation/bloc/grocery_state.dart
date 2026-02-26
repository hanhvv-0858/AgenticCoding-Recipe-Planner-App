part of 'grocery_bloc.dart';

/// States for the Grocery BLoC.
sealed class GroceryState extends Equatable {
  const GroceryState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any grocery list is loaded.
class GroceryInitial extends GroceryState {
  const GroceryInitial();
}

/// Loading state while fetching grocery data.
class GroceryLoading extends GroceryState {
  const GroceryLoading();
}

/// State when no grocery items exist (empty list).
class GroceryEmpty extends GroceryState {
  final String weekStart;

  const GroceryEmpty({required this.weekStart});

  @override
  List<Object?> get props => [weekStart];
}

/// State when grocery list is loaded.
class GroceryLoaded extends GroceryState {
  final List<GroceryCategoryGroup> categories;
  final GrocerySummary summary;
  final String weekStart;

  const GroceryLoaded({
    required this.categories,
    required this.summary,
    required this.weekStart,
  });

  GroceryLoaded copyWith({
    List<GroceryCategoryGroup>? categories,
    GrocerySummary? summary,
    String? weekStart,
  }) {
    return GroceryLoaded(
      categories: categories ?? this.categories,
      summary: summary ?? this.summary,
      weekStart: weekStart ?? this.weekStart,
    );
  }

  @override
  List<Object?> get props => [categories, summary, weekStart];
}

/// Error state when grocery operations fail.
class GroceryError extends GroceryState {
  final String message;

  const GroceryError({required this.message});

  @override
  List<Object?> get props => [message];
}
