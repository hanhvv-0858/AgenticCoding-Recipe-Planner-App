import 'package:recipe_planner/features/home/data/models/cooking_step_model.dart';
import 'package:recipe_planner/features/home/data/models/ingredient_model.dart';
import 'package:recipe_planner/features/home/data/models/tag_model.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';

/// Recipe model with JSON serialization matching API response shape.
class RecipeModel extends Recipe {
  const RecipeModel({
    required super.id,
    required super.title,
    super.description,
    super.coverImageUrl,
    required super.cookingTimeMinutes,
    super.calories,
    super.proteinGrams,
    super.carbsGrams,
    super.rating,
    super.defaultServings,
    super.ingredients,
    super.steps,
    super.tags,
    super.isSaved,
    super.viewCount,
    super.saveCount,
  });

  /// Parse from API list response (recipes search / trending).
  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      cookingTimeMinutes: json['cooking_time_minutes'] as int,
      calories: json['calories'] as int?,
      proteinGrams: (json['protein_grams'] as num?)?.toDouble(),
      carbsGrams: (json['carbs_grams'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      defaultServings: json['default_servings'] as int? ?? 2,
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) =>
                  IngredientModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      steps: (json['steps'] as List<dynamic>?)
              ?.map((e) =>
                  CookingStepModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => TagModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isSaved: json['is_saved'] as bool? ?? false,
      viewCount: json['view_count'] as int? ?? 0,
      saveCount: json['save_count'] as int? ?? 0,
    );
  }

  /// Serialize to JSON for local caching.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cover_image_url': coverImageUrl,
      'cooking_time_minutes': cookingTimeMinutes,
      'calories': calories,
      'protein_grams': proteinGrams,
      'carbs_grams': carbsGrams,
      'rating': rating,
      'default_servings': defaultServings,
      'ingredients': ingredients
          .map((e) => e is IngredientModel
              ? e.toJson()
              : IngredientModel(
                  id: e.id,
                  name: e.name,
                  quantity: e.quantity,
                  unit: e.unit,
                  category: e.category,
                  displayOrder: e.displayOrder,
                ).toJson())
          .toList(),
      'steps': steps
          .map((e) => e is CookingStepModel
              ? e.toJson()
              : CookingStepModel(
                  id: e.id,
                  stepNumber: e.stepNumber,
                  instruction: e.instruction,
                  mediaUrl: e.mediaUrl,
                  mediaType: e.mediaType,
                ).toJson())
          .toList(),
      'tags': tags
          .map((e) => e is TagModel
              ? e.toJson()
              : TagModel(
                  id: e.id,
                  name: e.name,
                  slug: e.slug,
                  displayOrder: e.displayOrder,
                ).toJson())
          .toList(),
      'is_saved': isSaved,
      'view_count': viewCount,
      'save_count': saveCount,
    };
  }

  factory RecipeModel.fromEntity(Recipe recipe) {
    return RecipeModel(
      id: recipe.id,
      title: recipe.title,
      description: recipe.description,
      coverImageUrl: recipe.coverImageUrl,
      cookingTimeMinutes: recipe.cookingTimeMinutes,
      calories: recipe.calories,
      proteinGrams: recipe.proteinGrams,
      carbsGrams: recipe.carbsGrams,
      rating: recipe.rating,
      defaultServings: recipe.defaultServings,
      ingredients: recipe.ingredients,
      steps: recipe.steps,
      tags: recipe.tags,
      isSaved: recipe.isSaved,
      viewCount: recipe.viewCount,
      saveCount: recipe.saveCount,
    );
  }
}
