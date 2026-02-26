import 'package:flutter/material.dart';

/// Search bar with filter icon for recipe search.
class RecipeSearchBar extends StatefulWidget {
  final Function(String query)? onSearch;
  final VoidCallback? onFilterTap;
  final String? initialQuery;

  const RecipeSearchBar({
    super.key,
    this.onSearch,
    this.onFilterTap,
    this.initialQuery,
  });

  @override
  State<RecipeSearchBar> createState() => _RecipeSearchBarState();
}

class _RecipeSearchBarState extends State<RecipeSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search recipes...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    widget.onSearch?.call('');
                  },
                ),
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () => _showFilterSheet(context),
              ),
            ],
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (value) {
          setState(() {});
        },
        onSubmitted: widget.onSearch,
        textInputAction: TextInputAction.search,
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    if (widget.onFilterTap != null) {
      widget.onFilterTap!();
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const _FilterBottomSheet(),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet();

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  final _ingredientController = TextEditingController();
  double? _maxTime;
  double? _maxCalories;

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
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
                'Filter Recipes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ingredientController,
            decoration: const InputDecoration(
              labelText: 'Ingredient',
              hintText: 'e.g., chicken, tomato',
              prefixIcon: Icon(Icons.restaurant),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Max Cooking Time: ${_maxTime?.toInt() ?? 'Any'} min',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Slider(
            value: _maxTime ?? 0,
            min: 0,
            max: 120,
            divisions: 24,
            label: _maxTime?.toInt().toString() ?? 'Any',
            onChanged: (value) {
              setState(() {
                _maxTime = value == 0 ? null : value;
              });
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Max Calories: ${_maxCalories?.toInt() ?? 'Any'} kcal',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Slider(
            value: _maxCalories ?? 0,
            min: 0,
            max: 1000,
            divisions: 20,
            label: _maxCalories?.toInt().toString() ?? 'Any',
            onChanged: (value) {
              setState(() {
                _maxCalories = value == 0 ? null : value;
              });
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context, {
                  'ingredient': _ingredientController.text.isEmpty
                      ? null
                      : _ingredientController.text,
                  'max_time': _maxTime?.toInt(),
                  'max_calories': _maxCalories?.toInt(),
                });
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
