import 'package:flutter/material.dart';

/// Accessibility helper widgets and extensions.
///
/// Wraps interactive elements with Semantics for screen reader support.
/// Per constitution accessibility requirements.

/// Wrap a recipe card with proper semantic labels.
class SemanticRecipeCard extends StatelessWidget {
  final String recipeName;
  final int? cookingTimeMinutes;
  final int? calories;
  final bool? isSaved;
  final VoidCallback? onTap;
  final Widget child;

  const SemanticRecipeCard({
    super.key,
    required this.recipeName,
    this.cookingTimeMinutes,
    this.calories,
    this.isSaved,
    this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final buffer = StringBuffer('Recipe: $recipeName.');
    if (cookingTimeMinutes != null) {
      buffer.write(' $cookingTimeMinutes minutes.');
    }
    if (calories != null) {
      buffer.write(' $calories calories.');
    }
    if (isSaved == true) {
      buffer.write(' Saved to cookbook.');
    }

    return Semantics(
      label: buffer.toString(),
      button: onTap != null,
      child: child,
    );
  }
}

/// Wrap a grocery item with proper semantic labels.
class SemanticGroceryItem extends StatelessWidget {
  final String itemName;
  final double? quantity;
  final String? unit;
  final bool isChecked;
  final Widget child;

  const SemanticGroceryItem({
    super.key,
    required this.itemName,
    this.quantity,
    this.unit,
    required this.isChecked,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final buffer = StringBuffer();
    if (quantity != null) {
      buffer.write('$quantity ');
      if (unit != null) buffer.write('$unit ');
    }
    buffer.write(itemName);
    if (isChecked) {
      buffer.write(', checked off');
    }

    return Semantics(
      label: buffer.toString(),
      checked: isChecked,
      child: child,
    );
  }
}

/// Wrap a meal slot with proper semantic labels.
class SemanticMealSlot extends StatelessWidget {
  final String mealType;
  final String? recipeName;
  final String dayLabel;
  final Widget child;

  const SemanticMealSlot({
    super.key,
    required this.mealType,
    this.recipeName,
    required this.dayLabel,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final label = recipeName != null
        ? '$dayLabel $mealType: $recipeName'
        : '$dayLabel $mealType: empty slot, tap to add';

    return Semantics(
      label: label,
      button: true,
      child: child,
    );
  }
}

/// Extension to add quick semantic wrapping to widgets.
extension SemanticsExtension on Widget {
  Widget withSemantics({
    String? label,
    String? hint,
    bool? button,
    bool? enabled,
    bool? checked,
    bool? header,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: button,
      enabled: enabled,
      checked: checked,
      header: header,
      child: this,
    );
  }
}
