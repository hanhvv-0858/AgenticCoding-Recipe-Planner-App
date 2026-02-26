import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_planner/features/shell/presentation/pages/main_shell.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('MainShell', () {
    testWidgets('renders 5 bottom navigation tabs', (tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return MainShell(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/home',
                    builder: (context, state) =>
                        const Center(child: Text('Home')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/cookbook',
                    builder: (context, state) =>
                        const Center(child: Text('Cookbook')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/planner',
                    builder: (context, state) =>
                        const Center(child: Text('Planner')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/grocery',
                    builder: (context, state) =>
                        const Center(child: Text('Grocery')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/profile',
                    builder: (context, state) =>
                        const Center(child: Text('Profile')),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: router),
      );
      await tester.pumpAndSettle();

      // Verify 5 tab labels
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Cookbook'), findsWidgets);
      expect(find.text('Planner'), findsWidgets);
      expect(find.text('Grocery'), findsWidgets);
      expect(find.text('Profile'), findsWidgets);

      // Verify bottom navigation bar exists
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('tapping tabs switches content', (tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return MainShell(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/home',
                    builder: (context, state) =>
                        const Center(child: Text('Home Content')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/cookbook',
                    builder: (context, state) =>
                        const Center(child: Text('Cookbook Content')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/planner',
                    builder: (context, state) =>
                        const Center(child: Text('Planner Content')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/grocery',
                    builder: (context, state) =>
                        const Center(child: Text('Grocery Content')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/profile',
                    builder: (context, state) =>
                        const Center(child: Text('Profile Content')),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: router),
      );
      await tester.pumpAndSettle();

      // Initially on home
      expect(find.text('Home Content'), findsOneWidget);

      // Tap Cookbook tab
      await tester.tap(find.byIcon(Icons.menu_book_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Cookbook Content'), findsOneWidget);

      // Tap Planner tab
      await tester.tap(find.byIcon(Icons.calendar_today_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Planner Content'), findsOneWidget);
    });
  });
}
