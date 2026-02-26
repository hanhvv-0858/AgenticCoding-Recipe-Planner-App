import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// SliverAppBar with parallax cover image, save and add-to-plan buttons.
class ParallaxHeader extends StatelessWidget {
  final String? imageUrl;
  final bool isSaved;
  final bool isSaving;
  final VoidCallback? onSaveToggle;
  final VoidCallback? onAddToPlan;

  const ParallaxHeader({
    super.key,
    this.imageUrl,
    this.isSaved = false,
    this.isSaving = false,
    this.onSaveToggle,
    this.onAddToPlan,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      actions: [
        IconButton(
          icon: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  isSaved ? Icons.favorite : Icons.favorite_border,
                  color: isSaved ? Colors.red : null,
                ),
          onPressed: isSaving ? null : onSaveToggle,
          tooltip: isSaved ? 'Remove from cookbook' : 'Save to cookbook',
        ),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: onAddToPlan,
          tooltip: 'Add to meal plan',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Center(
                    child: Icon(Icons.restaurant, size: 64),
                  ),
                ),
              )
            : Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Center(
                  child: Icon(Icons.restaurant, size: 64),
                ),
              ),
      ),
    );
  }
}
