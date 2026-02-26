import 'package:flutter/material.dart';
import 'package:recipe_planner/features/home/domain/entities/ingredient.dart';

/// Ingredients tab with servings dropdown and checkable ingredient list.
class IngredientsTab extends StatelessWidget {
  final List<Ingredient> ingredients;
  final int defaultServings;
  final int currentServings;
  final Set<String> checkedIngredients;
  final ValueChanged<int>? onServingsChanged;
  final ValueChanged<String>? onIngredientToggle;

  const IngredientsTab({
    super.key,
    required this.ingredients,
    required this.defaultServings,
    required this.currentServings,
    this.checkedIngredients = const {},
    this.onServingsChanged,
    this.onIngredientToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Servings selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Servings',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: currentServings,
                    items: List.generate(50, (i) => i + 1)
                        .map((v) => DropdownMenuItem(
                              value: v,
                              child: Text('$v'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) onServingsChanged?.call(value);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // Ingredients list
        ...ingredients.map((ingredient) {
          final adjusted =
              ingredient.adjustForServings(defaultServings, currentServings);
          final isChecked = checkedIngredients.contains(ingredient.id);

          return ListTile(
            leading: Checkbox(
              value: isChecked,
              onChanged: (_) => onIngredientToggle?.call(ingredient.id),
            ),
            title: Text(
              _formatQuantity(adjusted.quantity, adjusted.unit, adjusted.name),
              style: isChecked
                  ? TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Theme.of(context).colorScheme.outline,
                    )
                  : null,
            ),
            subtitle: Text(
              adjusted.category,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }),
      ],
    );
  }

  String _formatQuantity(double quantity, String unit, String name) {
    final qStr = quantity == quantity.roundToDouble()
        ? quantity.toInt().toString()
        : quantity.toStringAsFixed(1);
    return '$qStr $unit $name';
  }
}
