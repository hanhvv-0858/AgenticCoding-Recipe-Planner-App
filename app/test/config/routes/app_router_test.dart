import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_planner/config/routes/app_router.dart';

void main() {
  group('AppRouter', () {
    testWidgets('initial route renders Home', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(routerConfig: appRouter),
      );
      await tester.pumpAndSettle();

      // Home page should be the initial route
      expect(find.text('Recipe Planner'), findsOneWidget);
    });

    testWidgets('bottom navigation has 5 tabs', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(routerConfig: appRouter),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      final bottomNav =
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNav.items.length, 5);
    });
  });
}
