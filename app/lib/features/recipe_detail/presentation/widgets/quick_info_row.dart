import 'package:flutter/material.dart';

/// Row with cooking time, calories, and rating icons.
class QuickInfoRow extends StatelessWidget {
  final int cookingTimeMinutes;
  final int? calories;
  final double? rating;
  final int defaultServings;

  const QuickInfoRow({
    super.key,
    required this.cookingTimeMinutes,
    this.calories,
    this.rating,
    this.defaultServings = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _InfoChip(
            icon: Icons.timer_outlined,
            label: '$cookingTimeMinutes min',
            color: Theme.of(context).colorScheme.primary,
          ),
          _InfoChip(
            icon: Icons.local_fire_department_outlined,
            label: calories != null ? '$calories cal' : 'N/A',
            color: Colors.orange,
          ),
          if (rating != null)
            _InfoChip(
              icon: Icons.star,
              label: rating!.toStringAsFixed(1),
              color: Colors.amber.shade700,
            ),
          _InfoChip(
            icon: Icons.people_outline,
            label: '$defaultServings servings',
            color: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
