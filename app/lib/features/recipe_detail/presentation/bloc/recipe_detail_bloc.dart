import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';
import 'package:recipe_planner/features/recipe_detail/domain/usecases/get_recipe_detail.dart';
import 'package:recipe_planner/features/recipe_detail/domain/usecases/save_recipe.dart';
import 'package:recipe_planner/features/recipe_detail/domain/usecases/unsave_recipe.dart';

part 'recipe_detail_event.dart';
part 'recipe_detail_state.dart';

/// BLoC for Recipe Detail screen.
class RecipeDetailBloc extends Bloc<RecipeDetailEvent, RecipeDetailState> {
  final GetRecipeDetail getRecipeDetail;
  final SaveRecipe saveRecipe;
  final UnsaveRecipe unsaveRecipe;

  RecipeDetailBloc({
    required this.getRecipeDetail,
    required this.saveRecipe,
    required this.unsaveRecipe,
  }) : super(const RecipeDetailInitial()) {
    on<LoadRecipeDetail>(_onLoadRecipeDetail);
    on<AdjustServings>(_onAdjustServings);
    on<ToggleIngredientCheck>(_onToggleIngredientCheck);
    on<SaveRecipeToggle>(_onSaveRecipeToggle);
  }

  Future<void> _onLoadRecipeDetail(
    LoadRecipeDetail event,
    Emitter<RecipeDetailState> emit,
  ) async {
    emit(const RecipeDetailLoading());

    final result = await getRecipeDetail(
      GetRecipeDetailParams(id: event.id),
    );

    result.fold(
      (failure) => emit(RecipeDetailError(message: failure.message)),
      (recipe) => emit(RecipeDetailLoaded(
        recipe: recipe,
        currentServings: recipe.defaultServings,
      )),
    );
  }

  void _onAdjustServings(
    AdjustServings event,
    Emitter<RecipeDetailState> emit,
  ) {
    final currentState = state;
    if (currentState is RecipeDetailLoaded) {
      emit(currentState.copyWith(currentServings: event.servings));
    }
  }

  void _onToggleIngredientCheck(
    ToggleIngredientCheck event,
    Emitter<RecipeDetailState> emit,
  ) {
    final currentState = state;
    if (currentState is RecipeDetailLoaded) {
      final checked = Set<String>.from(currentState.checkedIngredients);
      if (checked.contains(event.ingredientId)) {
        checked.remove(event.ingredientId);
      } else {
        checked.add(event.ingredientId);
      }
      emit(currentState.copyWith(checkedIngredients: checked));
    }
  }

  Future<void> _onSaveRecipeToggle(
    SaveRecipeToggle event,
    Emitter<RecipeDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is RecipeDetailLoaded) {
      final recipe = currentState.recipe;
      emit(currentState.copyWith(isSaving: true));

      if (recipe.isSaved) {
        final result = await unsaveRecipe(
          UnsaveRecipeParams(recipeId: recipe.id),
        );
        result.fold(
          (failure) => emit(currentState.copyWith(isSaving: false)),
          (_) => emit(currentState.copyWith(
            recipe: recipe.copyWith(isSaved: false),
            isSaving: false,
          )),
        );
      } else {
        final result = await saveRecipe(
          SaveRecipeParams(recipeId: recipe.id),
        );
        result.fold(
          (failure) => emit(currentState.copyWith(isSaving: false)),
          (_) => emit(currentState.copyWith(
            recipe: recipe.copyWith(isSaved: true),
            isSaving: false,
          )),
        );
      }
    }
  }
}
