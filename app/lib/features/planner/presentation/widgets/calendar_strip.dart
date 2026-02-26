import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// CalendarStrip — horizontal scrollable row of 7 day cards.
///
/// Shows day name + date number. Today is highlighted with accent color.
/// Selected day has a border. Tapping changes selected day.
class CalendarStrip extends StatelessWidget {
  final DateTime weekStart;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const CalendarStrip({
    super.key,
    required this.weekStart,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(
      7,
      (i) => weekStart.add(Duration(days: i)),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: days.map((date) {
          final isToday = _isSameDay(date, today);
          final isSelected = _isSameDay(date, selectedDate);

          return _DayCard(
            date: date,
            isToday: isToday,
            isSelected: isSelected,
            onTap: () => onDateSelected(date),
          );
        }).toList(),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayCard extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayCard({
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayName = DateFormat.E().format(date); // Mon, Tue, etc.
    final dayNumber = date.day.toString();

    Color backgroundColor;
    Color textColor;
    BoxBorder? border;

    if (isSelected) {
      backgroundColor = theme.colorScheme.primary;
      textColor = theme.colorScheme.onPrimary;
      border = null;
    } else if (isToday) {
      backgroundColor = theme.colorScheme.primaryContainer;
      textColor = theme.colorScheme.onPrimaryContainer;
      border = Border.all(
        color: theme.colorScheme.primary,
        width: 2,
      );
    } else {
      backgroundColor = Colors.transparent;
      textColor = theme.colorScheme.onSurface;
      border = null;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: border,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dayName,
              style: theme.textTheme.labelSmall?.copyWith(
                color: textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayNumber,
              style: theme.textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
