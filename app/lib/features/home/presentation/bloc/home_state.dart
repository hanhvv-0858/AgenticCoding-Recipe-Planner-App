part of 'home_bloc.dart';

/// Home feature states.
sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded.
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Loading state while fetching data.
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Successfully loaded home data.
class HomeLoaded extends HomeState {
  final Recipe? nextMealSlot;
  final List<Tag> tags;
  final List<Recipe> trendingRecipes;
  final List<Recipe>? searchResults;
  final String? selectedTag;
  final bool isSearching;
  final bool hasMoreTrending;

  const HomeLoaded({
    this.nextMealSlot,
    this.tags = const [],
    this.trendingRecipes = const [],
    this.searchResults,
    this.selectedTag,
    this.isSearching = false,
    this.hasMoreTrending = false,
  });

  HomeLoaded copyWith({
    Recipe? Function()? nextMealSlot,
    List<Tag>? tags,
    List<Recipe>? trendingRecipes,
    List<Recipe>? Function()? searchResults,
    String? Function()? selectedTag,
    bool? isSearching,
    bool? hasMoreTrending,
  }) {
    return HomeLoaded(
      nextMealSlot:
          nextMealSlot != null ? nextMealSlot() : this.nextMealSlot,
      tags: tags ?? this.tags,
      trendingRecipes: trendingRecipes ?? this.trendingRecipes,
      searchResults:
          searchResults != null ? searchResults() : this.searchResults,
      selectedTag: selectedTag != null ? selectedTag() : this.selectedTag,
      isSearching: isSearching ?? this.isSearching,
      hasMoreTrending: hasMoreTrending ?? this.hasMoreTrending,
    );
  }

  @override
  List<Object?> get props => [
        nextMealSlot,
        tags,
        trendingRecipes,
        searchResults,
        selectedTag,
        isSearching,
        hasMoreTrending,
      ];
}

/// Error state.
class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
