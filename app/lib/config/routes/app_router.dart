import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_planner/features/shell/presentation/pages/main_shell.dart';
import 'package:recipe_planner/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:recipe_planner/features/auth/presentation/pages/login_page.dart';
import 'package:recipe_planner/features/auth/presentation/pages/register_page.dart';
import 'package:recipe_planner/features/home/presentation/bloc/home_bloc.dart';
import 'package:recipe_planner/features/home/presentation/pages/home_page.dart';
import 'package:recipe_planner/features/cookbook/presentation/pages/cookbook_page.dart';
import 'package:recipe_planner/features/planner/presentation/pages/planner_page.dart';
import 'package:recipe_planner/features/grocery/presentation/pages/grocery_page.dart';
import 'package:recipe_planner/features/profile/presentation/pages/profile_page.dart';
import 'package:recipe_planner/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:recipe_planner/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:recipe_planner/features/cookbook/presentation/bloc/cookbook_bloc.dart';
import 'package:recipe_planner/features/recipe_detail/presentation/bloc/recipe_detail_bloc.dart';

import 'package:recipe_planner/features/recipe_detail/presentation/pages/recipe_detail_page.dart';
import 'package:recipe_planner/features/recipe_detail/presentation/pages/cooking_mode_page.dart';

// Navigation keys for each branch
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _cookbookNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'cookbook');
final _plannerNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'planner');
final _groceryNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'grocery');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

/// App router configuration using go_router.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    // Bottom navigation shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // Home tab
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => BlocProvider(
                create: (_) => GetIt.I<HomeBloc>(),
                child: const HomePage(),
              ),
            ),
          ],
        ),

        // Cookbook tab
        StatefulShellBranch(
          navigatorKey: _cookbookNavigatorKey,
          routes: [
            GoRoute(
              path: '/cookbook',
              builder: (context, state) => BlocProvider(
                create: (_) => GetIt.I<CookbookBloc>()
                  ..add(const LoadCookbook()),
                child: const CookbookPage(),
              ),
            ),
          ],
        ),

        // Planner tab
        StatefulShellBranch(
          navigatorKey: _plannerNavigatorKey,
          routes: [
            GoRoute(
              path: '/planner',
              builder: (context, state) => BlocProvider(
                create: (_) => GetIt.I<PlannerBloc>()
                  ..add(LoadWeek(startDate: DateTime.now())),
                child: const PlannerPage(),
              ),
            ),
          ],
        ),

        // Grocery tab
        StatefulShellBranch(
          navigatorKey: _groceryNavigatorKey,
          routes: [
            GoRoute(
              path: '/grocery',
              builder: (context, state) => BlocProvider(
                create: (_) => GetIt.I<GroceryBloc>()
                  ..add(const LoadGroceryList()),
                child: const GroceryPage(),
              ),
            ),
          ],
        ),

        // Profile tab
        StatefulShellBranch(
          navigatorKey: _profileNavigatorKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => BlocProvider(
                create: (_) => GetIt.I<AuthBloc>()
                  ..add(const CheckAuthStatus()),
                child: const ProfilePage(),
              ),
            ),
          ],
        ),
      ],
    ),

    // Full-screen routes (no bottom nav)
    GoRoute(
      path: '/recipe/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final recipeId = state.pathParameters['id']!;
        return BlocProvider(
          create: (_) => GetIt.I<RecipeDetailBloc>()
            ..add(LoadRecipeDetail(id: recipeId)),
          child: RecipeDetailPage(recipeId: recipeId),
        );
      },
    ),

    GoRoute(
      path: '/recipe/:id/cooking',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final recipeId = state.pathParameters['id']!;
        return BlocProvider(
          create: (_) => GetIt.I<RecipeDetailBloc>()
            ..add(LoadRecipeDetail(id: recipeId)),
          child: const CookingModePage(recipeTitle: '', steps: []),
        );
      },
    ),

    GoRoute(
      path: '/login',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => BlocProvider(
        create: (_) => GetIt.I<AuthBloc>(),
        child: const LoginPage(),
      ),
    ),

    GoRoute(
      path: '/register',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => BlocProvider(
        create: (_) => GetIt.I<AuthBloc>(),
        child: const RegisterPage(),
      ),
    ),
  ],
);
