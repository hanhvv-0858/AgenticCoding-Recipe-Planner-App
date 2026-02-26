import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';

/// Recipe card with full-bleed image, title overlay, and quick-add button.
class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onQuickAdd;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.onQuickAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: InkWell(
        onTap: () => context.push('/recipe/${recipe.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  recipe.coverImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: recipe.coverImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: const Center(
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: const Center(
                              child: Icon(Icons.restaurant, size: 40),
                            ),
                          ),
                        )
                      : Container(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: const Center(
                            child: Icon(Icons.restaurant, size: 40),
                          ),
                        ),
                  // Quick-add FAB
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: FloatingActionButton.small(
                        heroTag: 'quick_add_${recipe.id}',
                        onPressed: onQuickAdd,
                        child: const Icon(Icons.add, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: Theme.of(context).textTheme.titleSmall,
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
                      const SizedBox(width: 2),
                      Text(
                        '${recipe.cookingTimeMinutes}m',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      if (recipe.calories != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.local_fire_department_outlined,
                          size: 14,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${recipe.calories} cal',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                      if (recipe.rating != null) ...[
                        const Spacer(),
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          recipe.rating!.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
