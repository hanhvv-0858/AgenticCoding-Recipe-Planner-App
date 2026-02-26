import 'package:flutter/material.dart';
import 'package:recipe_planner/core/theme/app_colors.dart';
import 'package:recipe_planner/features/grocery/domain/entities/grocery_item.dart';

/// A single grocery item tile with checkbox, name, quantity, and swipe-to-delete.
class GroceryItemTile extends StatelessWidget {
  final GroceryItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const GroceryItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: AppColors.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete Item'),
                content: Text('Remove "${item.name}" from the list?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Checkbox
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: item.isChecked,
                  onChanged: (_) => onToggle(),
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name and source
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            decoration: item.isChecked
                                ? TextDecoration.lineThrough
                                : null,
                            color: item.isChecked
                                ? AppColors.onSurfaceVariant
                                : AppColors.onSurface,
                          ),
                    ),
                    if (item.sourceRecipes.isNotEmpty)
                      Text(
                        item.sourceRecipes.join(', '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Quantity and unit
              Text(
                _formatQuantity(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: item.isChecked
                          ? AppColors.onSurfaceVariant
                          : AppColors.onSurface,
                      decoration:
                          item.isChecked ? TextDecoration.lineThrough : null,
                    ),
              ),

              // Manual item indicator
              if (item.isManual) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.edit_note,
                  size: 16,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatQuantity() {
    final qty = item.quantity == item.quantity.roundToDouble()
        ? item.quantity.toInt().toString()
        : item.quantity.toStringAsFixed(1);
    return '$qty ${item.unit}';
  }
}
