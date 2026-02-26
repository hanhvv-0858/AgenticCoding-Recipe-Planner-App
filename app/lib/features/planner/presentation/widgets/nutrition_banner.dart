import 'package:flutter/material.dart';
import 'package:recipe_planner/features/planner/domain/entities/meal_plan.dart';

/// NutritionBanner — row showing day's total Calories, Protein, Carbs.
///
/// Computed from assigned recipes in the selected day's meal plan.
class NutritionBanner extends StatelessWidget {
  final NutritionSummary nutritionSummary;

  const NutritionBanner({
    super.key,
    required this.nutritionSummary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NutritionItem(
            icon: Icons.local_fire_department,
            label: 'Calories',
            value: '${nutritionSummary.calories}',
            unit: 'kcal',
            color: Colors.orange,
          ),
          _NutritionItem(
            icon: Icons.fitness_center,
            label: 'Protein',
            value: nutritionSummary.proteinGrams.toStringAsFixed(1),
            unit: 'g',
            color: Colors.blue,
          ),
          _NutritionItem(
            icon: Icons.grain,
            label: 'Carbs',
            value: nutritionSummary.carbsGrams.toStringAsFixed(1),
            unit: 'g',
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}

class _NutritionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _NutritionItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
