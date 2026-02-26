import 'package:equatable/equatable.dart';
import 'package:recipe_planner/core/constants/app_constants.dart';

/// CookingStep domain entity.
class CookingStep extends Equatable {
  final String id;
  final int stepNumber;
  final String instruction;
  final String? mediaUrl;
  final MediaType? mediaType;

  const CookingStep({
    required this.id,
    required this.stepNumber,
    required this.instruction,
    this.mediaUrl,
    this.mediaType,
  });

  @override
  List<Object?> get props => [id];
}
