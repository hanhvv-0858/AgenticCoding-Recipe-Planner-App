import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_planner/features/cookbook/domain/usecases/cookbook_save_recipe.dart';
import 'package:recipe_planner/features/cookbook/domain/usecases/cookbook_unsave_recipe.dart';
import 'package:recipe_planner/features/cookbook/domain/usecases/get_saved_recipes.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';

part 'cookbook_event.dart';
part 'cookbook_state.dart';

/// BLoC for the Cookbook feature — saved recipes management.
class CookbookBloc extends Bloc<CookbookEvent, CookbookState> {
  final GetSavedRecipes getSavedRecipes;
  final CookbookSaveRecipe cookbookSaveRecipe;
  final CookbookUnsaveRecipe cookbookUnsaveRecipe;

  CookbookBloc({
    required this.getSavedRecipes,
    required this.cookbookSaveRecipe,
    required this.cookbookUnsaveRecipe,
  }) : super(const CookbookInitial()) {
    on<LoadCookbook>(_onLoadCookbook);
    on<LoadMoreCookbook>(_onLoadMore);
    on<UnsaveFromList>(_onUnsaveFromList);
    on<SaveToCookbook>(_onSaveToCookbook);
  }

  Future<void> _onLoadCookbook(
    LoadCookbook event,
    Emitter<CookbookState> emit,
  ) async {
    emit(const CookbookLoading());

    final result = await getSavedRecipes(
      const GetSavedRecipesParams(),
    );

    result.fold(
      (failure) {
        // Show empty state if user is not authenticated (401)
        if (failure.message.contains('401')) {
          emit(const CookbookEmpty());
        } else {
          emit(CookbookError(message: failure.message));
        }
      },
      (data) {
        if (data.recipes.isEmpty) {
          emit(const CookbookEmpty());
        } else {
          emit(CookbookLoaded(
            recipes: data.recipes,
            hasMore: data.hasMore,
            nextCursor: data.nextCursor,
          ));
        }
      },
    );
  }

  Future<void> _onLoadMore(
    LoadMoreCookbook event,
    Emitter<CookbookState> emit,
  ) async {
    if (state is! CookbookLoaded) return;
    final currentState = state as CookbookLoaded;
    if (!currentState.hasMore || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final result = await getSavedRecipes(
      GetSavedRecipesParams(cursor: currentState.nextCursor),
    );

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMore: false)),
      (data) {
        emit(CookbookLoaded(
          recipes: [...currentState.recipes, ...data.recipes],
          hasMore: data.hasMore,
          nextCursor: data.nextCursor,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> _onUnsaveFromList(
    UnsaveFromList event,
    Emitter<CookbookState> emit,
  ) async {
    if (state is! CookbookLoaded) return;
    final currentState = state as CookbookLoaded;

    // Optimistic removal
    final updatedRecipes =
        currentState.recipes.where((r) => r.id != event.recipeId).toList();

    if (updatedRecipes.isEmpty) {
      emit(const CookbookEmpty());
    } else {
      emit(currentState.copyWith(recipes: updatedRecipes));
    }

    final result = await cookbookUnsaveRecipe(
      CookbookUnsaveRecipeParams(recipeId: event.recipeId),
    );

    result.fold(
      (failure) {
        // Revert on failure
        emit(currentState);
      },
      (_) {
        // Success — keep optimistic state
      },
    );
  }

  Future<void> _onSaveToCookbook(
    SaveToCookbook event,
    Emitter<CookbookState> emit,
  ) async {
    await cookbookSaveRecipe(
      CookbookSaveRecipeParams(recipeId: event.recipeId),
    );

    // Reload the list to get fresh data
    add(const LoadCookbook());
  }
}
