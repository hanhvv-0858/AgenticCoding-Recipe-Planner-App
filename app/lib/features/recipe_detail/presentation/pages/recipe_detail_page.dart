import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_planner/features/home/presentation/widgets/quick_add_picker.dart';
import 'package:recipe_planner/features/recipe_detail/presentation/bloc/recipe_detail_bloc.dart';
import 'package:recipe_planner/features/recipe_detail/presentation/widgets/ingredients_tab.dart';
import 'package:recipe_planner/features/recipe_detail/presentation/widgets/parallax_header.dart';
import 'package:recipe_planner/features/recipe_detail/presentation/widgets/quick_info_row.dart';
import 'package:recipe_planner/features/recipe_detail/presentation/widgets/steps_tab.dart';

/// Recipe detail page with parallax header, quick info, tabs, and cooking mode.
class RecipeDetailPage extends StatefulWidget {
  final String recipeId;

  const RecipeDetailPage({super.key, required this.recipeId});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context
        .read<RecipeDetailBloc>()
        .add(LoadRecipeDetail(id: widget.recipeId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<RecipeDetailBloc, RecipeDetailState>(
        buildWhen: (previous, current) =>
            previous.runtimeType != current.runtimeType ||
            current is RecipeDetailLoaded,
        builder: (context, state) {
          return switch (state) {
            RecipeDetailInitial() => const SizedBox.shrink(),
            RecipeDetailLoading() => const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            RecipeDetailError(message: final msg) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text(msg),
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: () => context
                          .read<RecipeDetailBloc>()
                          .add(LoadRecipeDetail(id: widget.recipeId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            RecipeDetailLoaded() => _buildLoaded(context, state),
          };
        },
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, RecipeDetailLoaded state) {
    final recipe = state.recipe;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        // Parallax header
        ParallaxHeader(
          imageUrl: recipe.coverImageUrl,
          isSaved: recipe.isSaved,
          isSaving: state.isSaving,
          onSaveToggle: () => context
              .read<RecipeDetailBloc>()
              .add(const SaveRecipeToggle()),
          onAddToPlan: () => QuickAddPicker.show(
            context,
            recipeId: recipe.id,
            recipeTitle: recipe.title,
          ),
        ),

        // Title + description
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (recipe.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    recipe.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Quick info row
        SliverToBoxAdapter(
          child: QuickInfoRow(
            cookingTimeMinutes: recipe.cookingTimeMinutes,
            calories: recipe.calories,
            rating: recipe.rating,
            defaultServings: state.currentServings,
          ),
        ),

        // Tab bar
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Ingredients'),
                Tab(text: 'Steps'),
              ],
            ),
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          // Ingredients tab
          SingleChildScrollView(
            child: IngredientsTab(
              ingredients: recipe.ingredients,
              defaultServings: recipe.defaultServings,
              currentServings: state.currentServings,
              checkedIngredients: state.checkedIngredients,
              onServingsChanged: (servings) => context
                  .read<RecipeDetailBloc>()
                  .add(AdjustServings(servings: servings)),
              onIngredientToggle: (id) => context
                  .read<RecipeDetailBloc>()
                  .add(ToggleIngredientCheck(ingredientId: id)),
            ),
          ),

          // Steps tab
          SingleChildScrollView(
            child: Column(
              children: [
                StepsTab(steps: recipe.steps),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        context.push(
                          '/recipe/${recipe.id}/cooking',
                        );
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Cooking'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Persistent header delegate for the tab bar.
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: overlapsContent ? 2 : 0,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}
