import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_planner/features/home/presentation/bloc/home_bloc.dart';
import 'package:recipe_planner/features/home/presentation/widgets/next_meal_card.dart';
import 'package:recipe_planner/features/home/presentation/widgets/quick_add_picker.dart';
import 'package:recipe_planner/features/home/presentation/widgets/recipe_card.dart';
import 'package:recipe_planner/features/home/presentation/widgets/search_bar_widget.dart';
import 'package:recipe_planner/features/home/presentation/widgets/tag_row.dart';

/// Home page with search, tags, trending recipes, and next meal card.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const LoadHome());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) =>
            previous.runtimeType != current.runtimeType ||
            current is HomeLoaded,
        builder: (context, state) {
          return switch (state) {
            HomeInitial() => const SizedBox.shrink(),
            HomeLoading() => const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            HomeError(message: final msg) => _buildError(context, msg),
            HomeLoaded() => _buildLoaded(context, state),
          };
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () =>
                context.read<HomeBloc>().add(const LoadHome()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, HomeLoaded state) {
    final recipes = state.searchResults ?? state.trendingRecipes;

    return CustomScrollView(
      slivers: [
        // App bar with search
        SliverAppBar(
          floating: true,
          title: const Text('Recipe Planner'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: RecipeSearchBar(
              onSearch: (query) {
                if (query.isEmpty) {
                  context.read<HomeBloc>().add(const ClearSearch());
                } else {
                  context.read<HomeBloc>().add(
                        SearchRecipes(query: query),
                      );
                }
              },
              onFilterTap: () => _showFilterSheet(context),
            ),
          ),
        ),

        // Next meal card
        SliverToBoxAdapter(
          child: NextMealCard(
            nextMeal: state.nextMealSlot,
            onStartCooking: () {
              if (state.nextMealSlot != null) {
                context.push(
                  '/recipe/${state.nextMealSlot!.id}/cooking',
                );
              }
            },
            onPlanMeal: () => context.go('/planner'),
          ),
        ),

        // Tag row
        if (state.searchResults == null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: TagRow(
                tags: state.tags,
                selectedTagSlug: state.selectedTag,
                onTagSelected: (slug) {
                  context.read<HomeBloc>().add(FilterByTag(tagSlug: slug));
                },
              ),
            ),
          ),

        // Section header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  state.searchResults != null
                      ? 'Search Results (${state.searchResults!.length})'
                      : 'Trending Recipes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (state.searchResults != null)
                  TextButton(
                    onPressed: () =>
                        context.read<HomeBloc>().add(const ClearSearch()),
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ),
        ),

        // Loading indicator during search
        if (state.isSearching)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator.adaptive()),
            ),
          ),

        // Empty state
        if (!state.isSearching && recipes.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 48,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No recipes found',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Recipe grid
        if (!state.isSearching && recipes.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final recipe = recipes[index];
                  return RecipeCard(
                    recipe: recipe,
                    onQuickAdd: () {
                      QuickAddPicker.show(
                        context,
                        recipeId: recipe.id,
                        recipeTitle: recipe.title,
                        onConfirm: (date, mealType) {
                          // Will be wired to PlannerBloc later
                        },
                      );
                    },
                  );
                },
                childCount: recipes.length,
              ),
            ),
          ),
      ],
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _FilterSheet(),
    ).then((filters) {
      if (filters != null && mounted) {
        context.read<HomeBloc>().add(SearchRecipes(
              ingredient: filters['ingredient'] as String?,
              maxTime: filters['max_time'] as int?,
              maxCalories: filters['max_calories'] as int?,
            ));
      }
    });
  }
}

class _FilterSheet extends StatefulWidget {
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
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
              Text('Filter Recipes',
                  style: Theme.of(context).textTheme.titleLarge),
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
            'Max Cooking Time: ${_maxTime?.toInt() ?? "Any"} min',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Slider(
            value: _maxTime ?? 0,
            min: 0,
            max: 120,
            divisions: 24,
            label: _maxTime?.toInt().toString() ?? 'Any',
            onChanged: (v) => setState(() => _maxTime = v == 0 ? null : v),
          ),
          const SizedBox(height: 8),
          Text(
            'Max Calories: ${_maxCalories?.toInt() ?? "Any"} kcal',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Slider(
            value: _maxCalories ?? 0,
            min: 0,
            max: 1000,
            divisions: 20,
            label: _maxCalories?.toInt().toString() ?? 'Any',
            onChanged: (v) =>
                setState(() => _maxCalories = v == 0 ? null : v),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context, {
                'ingredient': _ingredientController.text.isEmpty
                    ? null
                    : _ingredientController.text,
                'max_time': _maxTime?.toInt(),
                'max_calories': _maxCalories?.toInt(),
              }),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
