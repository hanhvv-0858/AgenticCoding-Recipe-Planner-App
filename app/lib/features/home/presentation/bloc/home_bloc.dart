import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_planner/core/usecases/usecase.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';
import 'package:recipe_planner/features/home/domain/entities/tag.dart';
import 'package:recipe_planner/features/home/domain/usecases/get_next_meal_slot.dart';
import 'package:recipe_planner/features/home/domain/usecases/get_tags.dart';
import 'package:recipe_planner/features/home/domain/usecases/get_trending_recipes.dart';
import 'package:recipe_planner/features/home/domain/usecases/search_recipes.dart'
    as uc;

part 'home_event.dart';
part 'home_state.dart';

/// BLoC for the Home screen.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final uc.SearchRecipes searchRecipes;
  final GetTrendingRecipes getTrendingRecipes;
  final GetTags getTags;
  final GetNextMealSlot getNextMealSlot;

  HomeBloc({
    required this.searchRecipes,
    required this.getTrendingRecipes,
    required this.getTags,
    required this.getNextMealSlot,
  }) : super(const HomeInitial()) {
    on<LoadHome>(_onLoadHome);
    on<SearchRecipes>(_onSearchRecipes);
    on<FilterByTag>(_onFilterByTag);
    on<LoadMoreTrending>(_onLoadMoreTrending);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadHome(
    LoadHome event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    // Fetch all data concurrently
    final results = await Future.wait([
      getTags(NoParams()),
      getTrendingRecipes(const GetTrendingRecipesParams()),
      getNextMealSlot(NoParams()),
    ]);

    final tagsResult = results[0];
    final trendingResult = results[1];
    final nextMealResult = results[2];

    // Check for errors
    final tags = tagsResult.fold(
      (failure) => <Tag>[],
      (data) => data as List<Tag>,
    );

    final trending = trendingResult.fold(
      (failure) => <Recipe>[],
      (data) => data as List<Recipe>,
    );

    final nextMeal = nextMealResult.fold(
      (failure) => null,
      (data) => data as Recipe?,
    );

    emit(HomeLoaded(
      tags: tags,
      trendingRecipes: trending,
      nextMealSlot: nextMeal,
      hasMoreTrending: trending.length >= 20,
    ));
  }

  Future<void> _onSearchRecipes(
    SearchRecipes event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is HomeLoaded) {
      emit(currentState.copyWith(isSearching: true));

      final result = await searchRecipes(uc.SearchRecipesParams(
        query: event.query,
        ingredient: event.ingredient,
        maxTime: event.maxTime,
        maxCalories: event.maxCalories,
      ));

      result.fold(
        (failure) => emit(currentState.copyWith(
          isSearching: false,
          searchResults: () => [],
        )),
        (data) => emit(currentState.copyWith(
          isSearching: false,
          searchResults: () => data.recipes,
        )),
      );
    }
  }

  Future<void> _onFilterByTag(
    FilterByTag event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is HomeLoaded) {
      // Toggle tag: deselect if same tag tapped again
      final newTag =
          currentState.selectedTag == event.tagSlug ? null : event.tagSlug;

      emit(currentState.copyWith(
        selectedTag: () => newTag,
        isSearching: true,
      ));

      final result = await getTrendingRecipes(
        GetTrendingRecipesParams(tag: newTag),
      );

      result.fold(
        (failure) => emit(currentState.copyWith(
          selectedTag: () => newTag,
          isSearching: false,
        )),
        (recipes) => emit(currentState.copyWith(
          selectedTag: () => newTag,
          trendingRecipes: recipes,
          isSearching: false,
          hasMoreTrending: recipes.length >= 20,
        )),
      );
    }
  }

  Future<void> _onLoadMoreTrending(
    LoadMoreTrending event,
    Emitter<HomeState> emit,
  ) async {
    // Trending endpoint doesn't have pagination in current spec,
    // but structure is ready for it.
    final currentState = state;
    if (currentState is HomeLoaded && currentState.hasMoreTrending) {
      // Future: implement cursor-based pagination for trending
    }
  }

  void _onClearSearch(
    ClearSearch event,
    Emitter<HomeState> emit,
  ) {
    final currentState = state;
    if (currentState is HomeLoaded) {
      emit(currentState.copyWith(
        searchResults: () => null,
        isSearching: false,
      ));
    }
  }
}
