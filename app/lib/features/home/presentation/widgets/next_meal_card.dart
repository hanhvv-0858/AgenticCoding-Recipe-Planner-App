import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';

/// Sticky card showing the next planned meal with "Start Cooking" button.
class NextMealCard extends StatelessWidget {
  final Recipe? nextMeal;
  final VoidCallback? onStartCooking;
  final VoidCallback? onPlanMeal;

  const NextMealCard({
    super.key,
    this.nextMeal,
    this.onStartCooking,
    this.onPlanMeal,
  });

  @override
  Widget build(BuildContext context) {
    if (nextMeal == null) {
      return _buildEmptyState(context);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        child: InkWell(
          onTap: onStartCooking,
          child: SizedBox(
            height: 120,
            child: Row(
              children: [
                // Recipe image
                SizedBox(
                  width: 120,
                  child: nextMeal!.coverImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: nextMeal!.coverImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: const Center(
                              child: Icon(Icons.restaurant, size: 32),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 32),
                            ),
                          ),
                        )
                      : Container(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: const Center(
                            child: Icon(Icons.restaurant, size: 32),
                          ),
                        ),
                ),
                // Recipe info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Next Meal',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nextMeal!.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${nextMeal!.cookingTimeMinutes} min',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Start cooking button
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: FilledButton.tonal(
                    onPressed: onStartCooking,
                    child: const Text('Cook'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: InkWell(
          onTap: onPlanMeal,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plan your first meal',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap to add a recipe to your meal plan',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
