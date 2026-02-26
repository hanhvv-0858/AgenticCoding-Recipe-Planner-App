import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:recipe_planner/core/theme/app_colors.dart';
import 'package:recipe_planner/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:recipe_planner/features/grocery/presentation/widgets/grocery_item_tile.dart';
import 'package:recipe_planner/features/grocery/presentation/widgets/add_grocery_item_dialog.dart';

/// Grocery page — shopping list.
class GroceryPage extends StatelessWidget {
  const GroceryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroceryBloc, GroceryState>(
      listener: (context, state) {
        if (state is GroceryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Grocery List'),
            actions: _buildActions(context, state),
          ),
          body: _buildBody(context, state),
          floatingActionButton: _buildFab(context, state),
        );
      },
    );
  }

  List<Widget> _buildActions(BuildContext context, GroceryState state) {
    if (state is! GroceryLoaded) return [];
    return [
      // Share
      IconButton(
        icon: const Icon(Icons.share),
        tooltip: 'Share List',
        onPressed: () {
          final text = context.read<GroceryBloc>().formatShareText();
          if (text.isNotEmpty) {
            SharePlus.instance.share(ShareParams(text: text));
          }
        },
      ),
      // More actions menu
      PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'regenerate':
              context
                  .read<GroceryBloc>()
                  .add(RegenerateList(weekStart: state.weekStart));
              break;
            case 'clear_completed':
              _confirmClearCompleted(context);
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'regenerate',
            child: ListTile(
              leading: Icon(Icons.refresh),
              title: Text('Regenerate from Plan'),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          if (state.summary.checkedItems > 0)
            const PopupMenuItem(
              value: 'clear_completed',
              child: ListTile(
                leading: Icon(Icons.delete_sweep),
                title: Text('Clear Completed'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
    ];
  }

  Widget _buildBody(BuildContext context, GroceryState state) {
    return switch (state) {
      GroceryInitial() => const Center(
          child: Text('Loading grocery list...'),
        ),
      GroceryLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
      GroceryError(:final message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<GroceryBloc>().add(const LoadGroceryList());
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      GroceryEmpty() => _buildEmptyState(context),
      GroceryLoaded() => _buildLoadedContent(context, state),
    };
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No grocery items yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add items from your meal plan or manually add your own.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                context
                    .read<GroceryBloc>()
                    .add(const RegenerateList());
              },
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('Generate from Meal Plan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, GroceryLoaded state) {
    return Column(
      children: [
        // Progress indicator
        _buildProgressBar(context, state),

        // Category list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              final category = state.categories[index];
              return _buildCategorySection(context, category);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, GroceryLoaded state) {
    final progress = state.summary.totalItems > 0
        ? state.summary.checkedItems / state.summary.totalItems
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.summary.checkedItems} of ${state.summary.totalItems} items',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              Text(
                '${state.summary.remainingItems} remaining',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.surfaceVariant,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
      BuildContext context, dynamic category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(
                category.emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                category.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${category.items.length})',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),

        // Items
        ...category.items.map<Widget>(
          (item) => GroceryItemTile(
            item: item,
            onToggle: () {
              context.read<GroceryBloc>().add(ToggleItem(id: item.id));
            },
            onDelete: () {
              context.read<GroceryBloc>().add(DeleteItem(id: item.id));
            },
          ),
        ),
      ],
    );
  }

  Widget? _buildFab(BuildContext context, GroceryState state) {
    if (state is GroceryLoaded || state is GroceryEmpty) {
      return FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add),
      );
    }
    return null;
  }

  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AddGroceryItemDialog(
        onAdd: (name, quantity, unit, category) {
          context.read<GroceryBloc>().add(AddManualItem(
                name: name,
                quantity: quantity,
                unit: unit,
                category: category,
              ));
        },
      ),
    );
  }

  void _confirmClearCompleted(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Completed Items'),
        content: const Text(
          'Remove all checked items from the list? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<GroceryBloc>().add(const ClearCompleted());
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
