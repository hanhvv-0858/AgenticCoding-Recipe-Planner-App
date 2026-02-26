part of 'recipe_detail_bloc.dart';

/// Recipe detail states.
sealed class RecipeDetailState extends Equatable {
  const RecipeDetailState();

  @override
  List<Object?> get props => [];
}

class RecipeDetailInitial extends RecipeDetailState {
  const RecipeDetailInitial();
}

class RecipeDetailLoading extends RecipeDetailState {
  const RecipeDetailLoading();
}

class RecipeDetailLoaded extends RecipeDetailState {
  final Recipe recipe;
  final int currentServings;
  final Set<String> checkedIngredients;
  final bool isSaving;

  const RecipeDetailLoaded({
    required this.recipe,
    required this.currentServings,
    this.checkedIngredients = const {},
    this.isSaving = false,
  });

  RecipeDetailLoaded copyWith({
    Recipe? recipe,
    int? currentServings,
    Set<String>? checkedIngredients,
    bool? isSaving,
  }) {
    return RecipeDetailLoaded(
      recipe: recipe ?? this.recipe,
      currentServings: currentServings ?? this.currentServings,
      checkedIngredients: checkedIngredients ?? this.checkedIngredients,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [
        recipe,
        currentServings,
        checkedIngredients,
        isSaving,
      ];
}

class RecipeDetailError extends RecipeDetailState {
  final String message;

  const RecipeDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
