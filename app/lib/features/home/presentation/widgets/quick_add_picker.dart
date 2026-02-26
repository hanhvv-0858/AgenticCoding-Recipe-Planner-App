import 'package:flutter/material.dart';
import 'package:recipe_planner/core/constants/app_constants.dart';

/// Bottom sheet for quick-adding a recipe to a meal slot.
class QuickAddPicker extends StatefulWidget {
  final String recipeId;
  final String recipeTitle;
  final void Function(DateTime date, MealType mealType)? onConfirm;

  const QuickAddPicker({
    super.key,
    required this.recipeId,
    required this.recipeTitle,
    this.onConfirm,
  });

  /// Show the quick-add picker as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required String recipeId,
    required String recipeTitle,
    void Function(DateTime date, MealType mealType)? onConfirm,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => QuickAddPicker(
        recipeId: recipeId,
        recipeTitle: recipeTitle,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<QuickAddPicker> createState() => _QuickAddPickerState();
}

class _QuickAddPickerState extends State<QuickAddPicker> {
  late DateTime _selectedDate;
  MealType _selectedMealType = MealType.lunch;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    // Auto-detect meal type based on current time
    final hour = DateTime.now().hour;
    if (hour < 10) {
      _selectedMealType = MealType.breakfast;
    } else if (hour < 14) {
      _selectedMealType = MealType.lunch;
    } else if (hour < 18) {
      _selectedMealType = MealType.snack;
    } else {
      _selectedMealType = MealType.dinner;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add to Meal Plan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.recipeTitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 20),

          // Date selector
          Text(
            'Date',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index));
                final isSelected = _selectedDate.day == date.day &&
                    _selectedDate.month == date.month;
                final dayNames = [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun',
                ];

                return ChoiceChip(
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dayNames[date.weekday - 1],
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedDate = date);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Meal type selector
          Text(
            'Meal Type',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: MealType.values.map((type) {
              final isSelected = _selectedMealType == type;
              return ChoiceChip(
                label: Text('${type.emoji} ${type.displayName}'),
                selected: isSelected,
                labelStyle: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurface,
                ),
                onSelected: (_) {
                  setState(() => _selectedMealType = type);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Confirm button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                widget.onConfirm?.call(_selectedDate, _selectedMealType);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Added "${widget.recipeTitle}" to '
                      '${_selectedMealType.displayName}',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Add to Plan'),
            ),
          ),
        ],
      ),
    );
  }
}
