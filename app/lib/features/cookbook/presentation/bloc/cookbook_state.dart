part of 'cookbook_bloc.dart';

/// States for the Cookbook BLoC.
sealed class CookbookState extends Equatable {
  const CookbookState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class CookbookInitial extends CookbookState {
  const CookbookInitial();
}

/// Loading state.
class CookbookLoading extends CookbookState {
  const CookbookLoading();
}

/// Empty state — no saved recipes.
class CookbookEmpty extends CookbookState {
  const CookbookEmpty();
}

/// Loaded state with saved recipes.
class CookbookLoaded extends CookbookState {
  final List<Recipe> recipes;
  final bool hasMore;
  final String? nextCursor;
  final bool isLoadingMore;

  const CookbookLoaded({
    required this.recipes,
    required this.hasMore,
    this.nextCursor,
    this.isLoadingMore = false,
  });

  CookbookLoaded copyWith({
    List<Recipe>? recipes,
    bool? hasMore,
    String? nextCursor,
    bool? isLoadingMore,
  }) {
    return CookbookLoaded(
      recipes: recipes ?? this.recipes,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [recipes, hasMore, nextCursor, isLoadingMore];
}

/// Error state.
class CookbookError extends CookbookState {
  final String message;

  const CookbookError({required this.message});

  @override
  List<Object?> get props => [message];
}
