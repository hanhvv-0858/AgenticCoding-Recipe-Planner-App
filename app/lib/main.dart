import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:recipe_planner/config/di/injection_container.dart';
import 'package:recipe_planner/config/routes/app_router.dart';
import 'package:recipe_planner/core/theme/app_theme.dart';

/// Global BLoC observer for logging.
class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    debugPrint('${bloc.runtimeType} | $event');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    debugPrint('${bloc.runtimeType} | ERROR: $error');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint('${bloc.runtimeType} | ${transition.currentState} → ${transition.nextState}');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://ldbqztnpwajelkrrivab.supabase.co',
    ),
    anonKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxkYnF6dG5wd2FqZWxrcnJpdmFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIxMTQ0MjQsImV4cCI6MjA4NzY5MDQyNH0.d2JwhBk9suvr7a6XSSsYsmCsThc-LcrG4-HX8AvIbig',
    ),
  );

  // Initialize dependency injection
  await initDI();

  // Setup BLoC observer
  Bloc.observer = AppBlocObserver();

  runApp(const RecipePlannerApp());
}

class RecipePlannerApp extends StatelessWidget {
  const RecipePlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Recipe Planner',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
