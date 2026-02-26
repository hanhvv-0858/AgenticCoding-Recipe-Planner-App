part of 'recipe_detail_bloc.dart';

/// Recipe detail events.
sealed class RecipeDetailEvent extends Equatable {
  const RecipeDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Load full recipe detail by ID.
class LoadRecipeDetail extends RecipeDetailEvent {
  final String id;

  const LoadRecipeDetail({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Adjust the number of servings.
class AdjustServings extends RecipeDetailEvent {
  final int servings;

  const AdjustServings({required this.servings});

  @override
  List<Object?> get props => [servings];
}

/// Toggle an ingredient's checked state.
class ToggleIngredientCheck extends RecipeDetailEvent {
  final String ingredientId;

  const ToggleIngredientCheck({required this.ingredientId});

  @override
  List<Object?> get props => [ingredientId];
}

/// Toggle save/unsave recipe to cookbook.
class SaveRecipeToggle extends RecipeDetailEvent {
  const SaveRecipeToggle();
}
