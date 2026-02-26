import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:recipe_planner/features/grocery/domain/entities/grocery_item.dart';
import 'package:recipe_planner/features/grocery/domain/usecases/add_manual_grocery_item.dart';
import 'package:recipe_planner/features/grocery/domain/usecases/clear_completed_items.dart';
import 'package:recipe_planner/features/grocery/domain/usecases/delete_grocery_item.dart';
import 'package:recipe_planner/features/grocery/domain/usecases/get_grocery_list.dart';
import 'package:recipe_planner/features/grocery/domain/usecases/toggle_grocery_item_check.dart';

part 'grocery_event.dart';
part 'grocery_state.dart';

/// BLoC for the Grocery feature — grocery list management.
class GroceryBloc extends Bloc<GroceryEvent, GroceryState> {
  final GetGroceryList getGroceryList;
  final AddManualGroceryItem addManualGroceryItem;
  final ToggleGroceryItemCheck toggleGroceryItemCheck;
  final DeleteGroceryItem deleteGroceryItem;
  final ClearCompletedItems clearCompletedItems;

  GroceryBloc({
    required this.getGroceryList,
    required this.addManualGroceryItem,
    required this.toggleGroceryItemCheck,
    required this.deleteGroceryItem,
    required this.clearCompletedItems,
  }) : super(const GroceryInitial()) {
    on<LoadGroceryList>(_onLoadGroceryList);
    on<ToggleItem>(_onToggleItem);
    on<ClearCompleted>(_onClearCompleted);
    on<AddManualItem>(_onAddManualItem);
    on<DeleteItem>(_onDeleteItem);
    on<ShareList>(_onShareList);
    on<RegenerateList>(_onRegenerateList);
  }

  /// Get the current week's Monday in YYYY-MM-DD format.
  String _getCurrentWeekStart() {
    final now = DateTime.now();
    final weekday = now.weekday; // 1=Mon, 7=Sun
    final monday = now.subtract(Duration(days: weekday - 1));
    return DateFormat('yyyy-MM-dd').format(monday);
  }

  Future<void> _onLoadGroceryList(
    LoadGroceryList event,
    Emitter<GroceryState> emit,
  ) async {
    emit(const GroceryLoading());

    final weekStart = event.weekStart ?? _getCurrentWeekStart();

    final result = await getGroceryList(GetGroceryListParams(
      weekStart: weekStart,
    ));

    result.fold(
      (failure) {
        // Show empty state if user is not authenticated (401)
        if (failure.message.contains('401')) {
          emit(GroceryEmpty(weekStart: weekStart));
        } else {
          emit(GroceryError(message: failure.message));
        }
      },
      (data) {
        if (data.categories.isEmpty ||
            data.summary.totalItems == 0) {
          emit(GroceryEmpty(weekStart: weekStart));
        } else {
          emit(GroceryLoaded(
            categories: data.categories,
            summary: data.summary,
            weekStart: weekStart,
          ));
        }
      },
    );
  }

  Future<void> _onToggleItem(
    ToggleItem event,
    Emitter<GroceryState> emit,
  ) async {
    if (state is! GroceryLoaded) return;
    final currentState = state as GroceryLoaded;

    // Optimistic update
    final updatedCategories = currentState.categories.map((category) {
      final updatedItems = category.items.map((item) {
        if (item.id == event.id) {
          return item.copyWith(isChecked: !item.isChecked);
        }
        return item;
      }).toList();
      return GroceryCategoryGroup(
        name: category.name,
        emoji: category.emoji,
        items: updatedItems,
      );
    }).toList();

    // Recalculate summary
    int total = 0;
    int checked = 0;
    for (final cat in updatedCategories) {
      for (final item in cat.items) {
        total++;
        if (item.isChecked) checked++;
      }
    }

    emit(currentState.copyWith(
      categories: updatedCategories,
      summary: GrocerySummary(
        totalItems: total,
        checkedItems: checked,
        remainingItems: total - checked,
      ),
    ));

    // Find the current checked state for the item
    final targetItem = currentState.categories
        .expand((c) => c.items)
        .firstWhere((i) => i.id == event.id);

    // Sync to backend
    await toggleGroceryItemCheck(ToggleGroceryItemCheckParams(
      id: event.id,
      isChecked: !targetItem.isChecked,
    ));
  }

  Future<void> _onClearCompleted(
    ClearCompleted event,
    Emitter<GroceryState> emit,
  ) async {
    if (state is! GroceryLoaded) return;
    final currentState = state as GroceryLoaded;

    final result = await clearCompletedItems(
      ClearCompletedItemsParams(weekStart: currentState.weekStart),
    );

    result.fold(
      (failure) {
        if (!failure.message.contains('401')) {
          emit(GroceryError(message: failure.message));
        }
      },
      (data) {
        // Reload the list to get fresh data
        add(LoadGroceryList(weekStart: currentState.weekStart));
      },
    );
  }

  Future<void> _onAddManualItem(
    AddManualItem event,
    Emitter<GroceryState> emit,
  ) async {
    final weekStart = state is GroceryLoaded
        ? (state as GroceryLoaded).weekStart
        : state is GroceryEmpty
            ? (state as GroceryEmpty).weekStart
            : _getCurrentWeekStart();

    final result = await addManualGroceryItem(AddManualGroceryItemParams(
      name: event.name,
      quantity: event.quantity,
      unit: event.unit,
      category: event.category,
      weekStart: weekStart,
    ));

    result.fold(
      (failure) {
        if (!failure.message.contains('401')) {
          emit(GroceryError(message: failure.message));
        }
      },
      (item) {
        // Reload to get proper grouping
        add(LoadGroceryList(weekStart: weekStart));
      },
    );
  }

  Future<void> _onDeleteItem(
    DeleteItem event,
    Emitter<GroceryState> emit,
  ) async {
    if (state is! GroceryLoaded) return;
    final currentState = state as GroceryLoaded;

    final result = await deleteGroceryItem(
      DeleteGroceryItemParams(id: event.id),
    );

    result.fold(
      (failure) {
        if (!failure.message.contains('401')) {
          emit(GroceryError(message: failure.message));
        }
      },
      (_) {
        add(LoadGroceryList(weekStart: currentState.weekStart));
      },
    );
  }

  void _onShareList(
    ShareList event,
    Emitter<GroceryState> emit,
  ) {
    // Share formatting is handled in the presentation layer
    // This event just signals that the share action was triggered
    // The page listens and formats + shares using share_plus
  }

  Future<void> _onRegenerateList(
    RegenerateList event,
    Emitter<GroceryState> emit,
  ) async {
    emit(const GroceryLoading());

    final weekStart = event.weekStart ?? _getCurrentWeekStart();

    final result = await getGroceryList(GetGroceryListParams(
      weekStart: weekStart,
      regenerate: true,
    ));

    result.fold(
      (failure) {
        // Show empty state if user is not authenticated (401)
        if (failure.message.contains('401')) {
          emit(GroceryEmpty(weekStart: weekStart));
        } else {
          emit(GroceryError(message: failure.message));
        }
      },
      (data) {
        if (data.categories.isEmpty || data.summary.totalItems == 0) {
          emit(GroceryEmpty(weekStart: weekStart));
        } else {
          emit(GroceryLoaded(
            categories: data.categories,
            summary: data.summary,
            weekStart: weekStart,
          ));
        }
      },
    );
  }

  /// Format the grocery list for sharing via native share sheet.
  /// per contracts/grocery.md share format.
  String formatShareText() {
    if (state is! GroceryLoaded) return '';
    final currentState = state as GroceryLoaded;

    final buffer = StringBuffer();

    // Parse week start for display
    final weekDate = DateTime.parse(currentState.weekStart);
    final formattedDate = DateFormat('MMM d').format(weekDate);
    buffer.writeln('🛒 Grocery List — Week of $formattedDate');
    buffer.writeln();

    for (final category in currentState.categories) {
      // Only include unchecked items in share
      final uncheckedItems =
          category.items.where((i) => !i.isChecked).toList();
      if (uncheckedItems.isEmpty) continue;

      buffer.writeln('${category.emoji} ${category.name}');
      for (final item in uncheckedItems) {
        final qty = item.quantity == item.quantity.roundToDouble()
            ? item.quantity.toInt().toString()
            : item.quantity.toStringAsFixed(1);
        buffer.writeln('  □ ${item.name} — $qty ${item.unit}');
      }
      buffer.writeln();
    }

    // Total unchecked
    final totalUnchecked = currentState.summary.remainingItems;
    buffer.writeln('Total: $totalUnchecked items');

    return buffer.toString();
  }
}
