import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:recipe_planner/core/constants/app_constants.dart';
import 'package:recipe_planner/features/planner/domain/entities/meal_slot.dart';

/// MealSlotCard — shows a meal type header and its slots.
///
/// Each slot displays either a recipe card or quick note.
/// Includes "Add Recipe" and "Quick Note" action buttons.
/// Supports swipe-to-delete and long-press to reorder.
class MealSlotCard extends StatelessWidget {
  final MealType mealType;
  final List<dynamic> slots;
  final String? planId;
  final VoidCallback onAddRecipe;
  final VoidCallback onAddQuickNote;
  final ValueChanged<String> onRemoveSlot;

  const MealSlotCard({
    super.key,
    required this.mealType,
    required this.slots,
    this.planId,
    required this.onAddRecipe,
    required this.onAddQuickNote,
    required this.onRemoveSlot,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Meal type header
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Row(
            children: [
              Text(
                mealType.emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                mealType.displayName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Action buttons
              if (planId != null) ...[
                IconButton(
                  icon: const Icon(Icons.restaurant_menu, size: 20),
                  tooltip: 'Add Recipe',
                  onPressed: onAddRecipe,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.note_add, size: 20),
                  tooltip: 'Quick Note',
                  onPressed: onAddQuickNote,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Slots
        if (slots.isEmpty)
          _EmptySlotPlaceholder(
            planId: planId,
            onAddRecipe: onAddRecipe,
            onAddQuickNote: onAddQuickNote,
          )
        else
          ...slots.map((slot) {
            final mealSlot = slot as MealSlot;
            return Dismissible(
              key: Key(mealSlot.id),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) async {
                return await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Remove Meal'),
                    content: Text(
                      'Remove ${mealSlot.recipe?.title ?? mealSlot.quickNote ?? 'this meal'} from the plan?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Remove'),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (_) => onRemoveSlot(mealSlot.id),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                color: theme.colorScheme.error,
                child: Icon(
                  Icons.delete,
                  color: theme.colorScheme.onError,
                ),
              ),
              child: mealSlot.hasRecipe
                  ? _RecipeSlotTile(slot: mealSlot)
                  : _QuickNoteSlotTile(slot: mealSlot),
            );
          }),

        const Divider(height: 1),
      ],
    );
  }
}

class _EmptySlotPlaceholder extends StatelessWidget {
  final String? planId;
  final VoidCallback onAddRecipe;
  final VoidCallback onAddQuickNote;

  const _EmptySlotPlaceholder({
    this.planId,
    required this.onAddRecipe,
    required this.onAddQuickNote,
  });

  @override
  Widget build(BuildContext context) {
    if (planId == null) {
      return const SizedBox(height: 8);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton.icon(
            onPressed: onAddRecipe,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Recipe'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: onAddQuickNote,
            icon: const Icon(Icons.edit_note, size: 16),
            label: const Text('Quick Note'),
          ),
        ],
      ),
    );
  }
}

class _RecipeSlotTile extends StatelessWidget {
  final MealSlot slot;

  const _RecipeSlotTile({required this.slot});

  @override
  Widget build(BuildContext context) {
    final recipe = slot.recipe!;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Navigate to recipe detail
        },
        child: Row(
          children: [
            // Recipe image
            SizedBox(
              width: 80,
              height: 80,
              child: recipe.coverImageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: recipe.coverImageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.restaurant),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.restaurant),
                      ),
                    )
                  : Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.restaurant),
                    ),
            ),
            // Recipe info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.cookingTimeMinutes} min',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        if (recipe.calories != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.local_fire_department_outlined,
                            size: 14,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${recipe.calories} cal',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${slot.servings} servings',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickNoteSlotTile extends StatelessWidget {
  final MealSlot slot;

  const _QuickNoteSlotTile({required this.slot});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.sticky_note_2_outlined,
          color: theme.colorScheme.tertiary,
        ),
        title: Text(
          slot.quickNote ?? '',
          style: theme.textTheme.bodyMedium,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.outline,
        ),
      ),
    );
  }
}
