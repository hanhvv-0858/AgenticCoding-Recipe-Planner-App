import 'package:flutter/material.dart';
import 'package:recipe_planner/core/theme/app_colors.dart';

/// Reusable empty state widget with illustration, title, subtitle, and CTA.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.ctaLabel,
    this.onCtaPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration placeholder
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),

            // CTA button
            if (ctaLabel != null && onCtaPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onCtaPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  ctaLabel!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Pre-built empty state for cookbook.
  factory EmptyState.cookbook({VoidCallback? onExplore}) {
    return EmptyState(
      icon: Icons.bookmark_outline,
      title: 'No Saved Recipes',
      subtitle: 'Save recipes you love to build your personal cookbook.',
      ctaLabel: 'Explore Recipes',
      onCtaPressed: onExplore,
    );
  }

  /// Pre-built empty state for planner.
  factory EmptyState.planner({VoidCallback? onCreatePlan}) {
    return EmptyState(
      icon: Icons.calendar_today_outlined,
      title: 'No Meal Plans Yet',
      subtitle: 'Plan your meals for the week to stay organized.',
      ctaLabel: 'Create Plan',
      onCtaPressed: onCreatePlan,
    );
  }

  /// Pre-built empty state for grocery.
  factory EmptyState.grocery({VoidCallback? onAddItems}) {
    return EmptyState(
      icon: Icons.shopping_cart_outlined,
      title: 'No Grocery Items',
      subtitle:
          'Add recipes to your meal plan to auto-generate a grocery list.',
      ctaLabel: 'Go to Planner',
      onCtaPressed: onAddItems,
    );
  }
}
