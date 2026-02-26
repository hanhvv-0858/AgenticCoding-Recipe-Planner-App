import 'package:recipe_planner/features/home/domain/entities/tag.dart';

/// Tag model with JSON serialization.
class TagModel extends Tag {
  const TagModel({
    required super.id,
    required super.name,
    required super.slug,
    super.displayOrder,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'display_order': displayOrder,
    };
  }

  factory TagModel.fromEntity(Tag tag) {
    return TagModel(
      id: tag.id,
      name: tag.name,
      slug: tag.slug,
      displayOrder: tag.displayOrder,
    );
  }
}
