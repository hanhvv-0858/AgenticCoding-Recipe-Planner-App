import 'package:equatable/equatable.dart';
import 'package:recipe_planner/features/home/domain/entities/ingredient.dart';
import 'package:recipe_planner/features/home/domain/entities/cooking_step.dart';
import 'package:recipe_planner/features/home/domain/entities/tag.dart';

/// Recipe domain entity.
class Recipe extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? coverImageUrl;
  final int cookingTimeMinutes;
  final int? calories;
  final double? proteinGrams;
  final double? carbsGrams;
  final double? rating;
  final int defaultServings;
  final List<Ingredient> ingredients;
  final List<CookingStep> steps;
  final List<Tag> tags;
  final bool isSaved;
  final int viewCount;
  final int saveCount;

  const Recipe({
    required this.id,
    required this.title,
    this.description,
    this.coverImageUrl,
    required this.cookingTimeMinutes,
    this.calories,
    this.proteinGrams,
    this.carbsGrams,
    this.rating,
    this.defaultServings = 2,
    this.ingredients = const [],
    this.steps = const [],
    this.tags = const [],
    this.isSaved = false,
    this.viewCount = 0,
    this.saveCount = 0,
  });

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    String? coverImageUrl,
    int? cookingTimeMinutes,
    int? calories,
    double? proteinGrams,
    double? carbsGrams,
    double? rating,
    int? defaultServings,
    List<Ingredient>? ingredients,
    List<CookingStep>? steps,
    List<Tag>? tags,
    bool? isSaved,
    int? viewCount,
    int? saveCount,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      cookingTimeMinutes: cookingTimeMinutes ?? this.cookingTimeMinutes,
      calories: calories ?? this.calories,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      rating: rating ?? this.rating,
      defaultServings: defaultServings ?? this.defaultServings,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      tags: tags ?? this.tags,
      isSaved: isSaved ?? this.isSaved,
      viewCount: viewCount ?? this.viewCount,
      saveCount: saveCount ?? this.saveCount,
    );
  }

  @override
  List<Object?> get props => [id];
}
