import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_planner/core/theme/app_colors.dart';
import 'package:recipe_planner/features/cookbook/presentation/bloc/cookbook_bloc.dart';
import 'package:recipe_planner/features/home/domain/entities/recipe.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Cookbook page — saved recipes grid.
class CookbookPage extends StatelessWidget {
  const CookbookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CookbookBloc, CookbookState>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType ||
          current is CookbookLoaded,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Cookbook'),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CookbookState state) {
    return switch (state) {
      CookbookInitial() => const Center(child: Text('Loading cookbook...')),
      CookbookLoading() => const Center(child: CircularProgressIndicator()),
      CookbookError(:final message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<CookbookBloc>().add(const LoadCookbook());
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      CookbookEmpty() => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bookmark_border,
                size: 80,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'No saved recipes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Save recipes from the detail screen\nto build your collection',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.explore),
                label: const Text('Explore Recipes'),
              ),
            ],
          ),
        ),
      CookbookLoaded() => _buildGrid(context, state),
    };
  }

  Widget _buildGrid(BuildContext context, CookbookLoaded state) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200 &&
            state.hasMore &&
            !state.isLoadingMore) {
          context.read<CookbookBloc>().add(const LoadMoreCookbook());
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: state.recipes.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.recipes.length) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildRecipeCard(context, state.recipes[index]);
        },
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
    return GestureDetector(
      onTap: () => context.push('/recipe/${recipe.id}'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  recipe.coverImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: recipe.coverImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.surfaceVariant,
                            child: const Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2)),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.surfaceVariant,
                            child: const Icon(Icons.restaurant,
                                size: 40, color: AppColors.onSurfaceVariant),
                          ),
                        )
                      : Container(
                          color: AppColors.surfaceVariant,
                          child: const Icon(Icons.restaurant,
                              size: 40, color: AppColors.onSurfaceVariant),
                        ),

                  // Unsave button
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.bookmark, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black26,
                      ),
                      onPressed: () {
                        context
                            .read<CookbookBloc>()
                            .add(UnsaveFromList(recipeId: recipe.id));
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 14, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.cookingTimeMinutes} min',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        if (recipe.calories != null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.local_fire_department_outlined,
                              size: 14, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 2),
                          Text(
                            '${recipe.calories} cal',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ],
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
