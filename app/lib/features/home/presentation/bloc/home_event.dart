part of 'home_bloc.dart';

/// Home feature events.
sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial home screen data (trending, tags, next meal).
class LoadHome extends HomeEvent {
  const LoadHome();
}

/// Search recipes with optional query and filters.
class SearchRecipes extends HomeEvent {
  final String? query;
  final String? ingredient;
  final int? maxTime;
  final int? maxCalories;

  const SearchRecipes({
    this.query,
    this.ingredient,
    this.maxTime,
    this.maxCalories,
  });

  @override
  List<Object?> get props => [query, ingredient, maxTime, maxCalories];
}

/// Filter trending recipes by tag.
class FilterByTag extends HomeEvent {
  final String? tagSlug;

  const FilterByTag({this.tagSlug});

  @override
  List<Object?> get props => [tagSlug];
}

/// Load more trending recipes (pagination).
class LoadMoreTrending extends HomeEvent {
  const LoadMoreTrending();
}

/// Clear search and return to trending view.
class ClearSearch extends HomeEvent {
  const ClearSearch();
}
