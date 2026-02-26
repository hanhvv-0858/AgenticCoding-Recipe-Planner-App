import 'package:recipe_planner/core/constants/app_constants.dart';
import 'package:recipe_planner/features/home/domain/entities/cooking_step.dart';

/// CookingStep model with JSON serialization.
class CookingStepModel extends CookingStep {
  const CookingStepModel({
    required super.id,
    required super.stepNumber,
    required super.instruction,
    super.mediaUrl,
    super.mediaType,
  });

  factory CookingStepModel.fromJson(Map<String, dynamic> json) {
    return CookingStepModel(
      id: json['id'] as String,
      stepNumber: json['step_number'] as int,
      instruction: json['instruction'] as String,
      mediaUrl: json['media_url'] as String?,
      mediaType: _parseMediaType(json['media_type'] as String?),
    );
  }

  static MediaType? _parseMediaType(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'image':
        return MediaType.image;
      case 'video':
        return MediaType.video;
      default:
        return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'step_number': stepNumber,
      'instruction': instruction,
      'media_url': mediaUrl,
      'media_type': mediaType?.name,
    };
  }
}
