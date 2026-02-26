import 'package:flutter/material.dart';
import 'package:recipe_planner/features/home/domain/entities/tag.dart';

/// Horizontally scrollable row of filter chips for tag filtering.
class TagRow extends StatelessWidget {
  final List<Tag> tags;
  final String? selectedTagSlug;
  final ValueChanged<String?>? onTagSelected;

  const TagRow({
    super.key,
    required this.tags,
    this.selectedTagSlug,
    this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tags.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tag = tags[index];
          final isSelected = tag.slug == selectedTagSlug;

          return FilterChip(
            label: Text(tag.name),
            selected: isSelected,
            onSelected: (_) {
              onTagSelected?.call(isSelected ? null : tag.slug);
            },
            showCheckmark: false,
            labelStyle: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            selectedColor: Theme.of(context).colorScheme.primaryContainer,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          );
        },
      ),
    );
  }
}
