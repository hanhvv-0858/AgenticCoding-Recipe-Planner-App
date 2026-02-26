import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_planner/core/constants/app_constants.dart';
import 'package:recipe_planner/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:recipe_planner/features/planner/presentation/widgets/calendar_strip.dart';
import 'package:recipe_planner/features/planner/presentation/widgets/meal_slot_card.dart';
import 'package:recipe_planner/features/planner/presentation/widgets/nutrition_banner.dart';

/// Planner page — weekly meal planning.
class PlannerPage extends StatelessWidget {
  const PlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlannerBloc, PlannerState>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType ||
          current is PlannerLoaded,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Meal Planner'),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, PlannerState state) {
    return switch (state) {
      PlannerInitial() => const Center(
          child: Text('Loading planner...'),
        ),
      PlannerLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
      PlannerError(:final message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<PlannerBloc>().add(
                        LoadWeek(startDate: DateTime.now()),
                      );
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      PlannerLoaded() => _buildLoadedContent(context, state),
    };
  }

  Widget _buildLoadedContent(BuildContext context, PlannerLoaded state) {
    final plan = state.selectedDayPlan;
    final slots = plan?.slots ?? [];

    // Group slots by meal type
    final groupedSlots = <MealType, List<dynamic>>{};
    for (final type in MealType.values) {
      groupedSlots[type] = slots.where((s) => s.mealType == type).toList();
    }

    return Column(
      children: [
        // Calendar strip
        CalendarStrip(
          weekStart: state.weekStart,
          selectedDate: state.selectedDate,
          onDateSelected: (date) {
            context.read<PlannerBloc>().add(SelectDay(date: date));
          },
        ),

        // Nutrition banner
        NutritionBanner(
          nutritionSummary: state.nutritionSummary,
        ),

        // Meal slots list
        Expanded(
          child: slots.isEmpty
              ? _buildEmptyState(context, state)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: MealType.values.length,
                  itemBuilder: (context, index) {
                    final mealType = MealType.values[index];
                    final typeSlots = groupedSlots[mealType] ?? [];

                    return MealSlotCard(
                      mealType: mealType,
                      slots: typeSlots,
                      planId: plan?.id,
                      onAddRecipe: () => _showRecipePicker(
                        context,
                        plan?.id,
                        mealType,
                      ),
                      onAddQuickNote: () => _showQuickNoteDialog(
                        context,
                        plan?.id,
                        mealType,
                      ),
                      onRemoveSlot: (slotId) {
                        if (plan?.id != null) {
                          context.read<PlannerBloc>().add(
                                RemoveSlot(
                                  planId: plan!.id!,
                                  slotId: slotId,
                                ),
                              );
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, PlannerLoaded state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No meals planned for this day',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to start planning',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 24),
          if (state.selectedDayPlan?.id == null)
            FilledButton.icon(
              onPressed: () {
                context.read<PlannerBloc>().add(
                      CreatePlan(date: state.selectedDate),
                    );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Plan'),
            ),
        ],
      ),
    );
  }

  void _showRecipePicker(
    BuildContext context,
    String? planId,
    MealType mealType,
  ) {
    if (planId == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => RecipePickerSheet(
        planId: planId,
        mealType: mealType,
      ),
    );
  }

  void _showQuickNoteDialog(
    BuildContext context,
    String? planId,
    MealType mealType,
  ) {
    if (planId == null) return;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Quick Note — ${mealType.displayName}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'e.g., "Eat out", "Leftovers"',
            border: OutlineInputBorder(),
          ),
          maxLength: 200,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final note = controller.text.trim();
              if (note.isNotEmpty) {
                context.read<PlannerBloc>().add(
                      AddQuickNote(
                        planId: planId,
                        mealType: mealType,
                        note: note,
                      ),
                    );
              }
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

/// Recipe picker bottom sheet — search and select a recipe for a slot.
class RecipePickerSheet extends StatelessWidget {
  final String planId;
  final MealType mealType;

  const RecipePickerSheet({
    super.key,
    required this.planId,
    required this.mealType,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select Recipe for ${mealType.displayName}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search recipes...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Placeholder list
              Expanded(
                child: Center(
                  child: Text(
                    'Recipe search results will appear here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
