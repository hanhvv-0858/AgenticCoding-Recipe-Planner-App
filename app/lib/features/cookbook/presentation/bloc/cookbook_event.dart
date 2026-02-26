part of 'cookbook_bloc.dart';

/// Events for the Cookbook BLoC.
abstract class CookbookEvent extends Equatable {
  const CookbookEvent();

  @override
  List<Object?> get props => [];
}

/// Load saved recipes (initial load).
class LoadCookbook extends CookbookEvent {
  const LoadCookbook();
}

/// Load more saved recipes (pagination).
class LoadMoreCookbook extends CookbookEvent {
  const LoadMoreCookbook();
}

/// Unsave a recipe from the cookbook list.
class UnsaveFromList extends CookbookEvent {
  final String recipeId;

  const UnsaveFromList({required this.recipeId});

  @override
  List<Object?> get props => [recipeId];
}

/// Save a recipe to the cookbook.
class SaveToCookbook extends CookbookEvent {
  final String recipeId;

  const SaveToCookbook({required this.recipeId});

  @override
  List<Object?> get props => [recipeId];
}
