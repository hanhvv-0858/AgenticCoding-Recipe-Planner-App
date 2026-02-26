import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:recipe_planner/features/planner/presentation/widgets/calendar_strip.dart';

void main() {
  // Fixed Monday for deterministic tests
  final tMonday = DateTime(2025, 1, 6);

  Widget buildWidget({
    DateTime? weekStart,
    DateTime? selectedDate,
    ValueChanged<DateTime>? onDateSelected,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CalendarStrip(
          weekStart: weekStart ?? tMonday,
          selectedDate: selectedDate ?? tMonday,
          onDateSelected: onDateSelected ?? (_) {},
        ),
      ),
    );
  }

  group('CalendarStrip', () {
    testWidgets('renders 7 day cards', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Verify 7 day names are rendered (Mon-Sun)
      for (int i = 0; i < 7; i++) {
        final date = tMonday.add(Duration(days: i));
        final dayName = DateFormat.E().format(date);
        expect(find.text(dayName), findsOneWidget);
      }
    });

    testWidgets('renders correct date numbers for the week', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Jan 6-12, 2025 → date numbers 6,7,8,9,10,11,12
      for (int i = 6; i <= 12; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });

    testWidgets('tapping a different day triggers onDateSelected',
        (tester) async {
      DateTime? selectedDate;
      await tester.pumpWidget(buildWidget(
        onDateSelected: (date) => selectedDate = date,
      ));

      // Tap Wednesday (Jan 8)
      final wednesdayNumber = find.text('8');
      await tester.tap(wednesdayNumber);
      await tester.pump();

      expect(selectedDate, isNotNull);
      expect(selectedDate!.day, 8);
      expect(selectedDate!.month, 1);
      expect(selectedDate!.year, 2025);
    });

    testWidgets('tapping another day calls callback with correct date',
        (tester) async {
      DateTime? tappedDate;
      await tester.pumpWidget(buildWidget(
        onDateSelected: (date) => tappedDate = date,
      ));

      // Tap Sunday (Jan 12)
      await tester.tap(find.text('12'));
      await tester.pump();

      expect(tappedDate, DateTime(2025, 1, 12));
    });

    testWidgets('displays different month correctly', (tester) async {
      // Use week starting Feb 3, 2025 (Monday)
      final febMonday = DateTime(2025, 2, 3);
      await tester.pumpWidget(buildWidget(weekStart: febMonday));

      // Should show 3,4,5,6,7,8,9
      for (int i = 3; i <= 9; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });
  });
}
