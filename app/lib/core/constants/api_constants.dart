import 'dart:io' show Platform;

/// API endpoint constants.
class ApiConstants {
  ApiConstants._();

  // On Android emulator, localhost refers to the emulator itself.
  // Use 10.0.2.2 to reach the host machine's localhost.
  static String get _defaultHost =>
      Platform.isAndroid ? '10.0.2.2' : 'localhost';

  // Will be loaded from .env or fall back to platform-aware default
  static final String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
  ).isEmpty
      ? 'http://$_defaultHost:3000/api'
      : const String.fromEnvironment('API_BASE_URL');

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';

  // Recipes
  static const String recipes = '/recipes';
  static const String recipeTrending = '/recipes/trending';
  static const String recipeDetail = '/recipes'; // + /:id
  static const String tags = '/tags';

  // Cookbook
  static const String cookbook = '/cookbook';

  // Meal Plans
  static const String mealPlans = '/meal-plans';

  // Grocery
  static const String grocery = '/grocery';
  static const String groceryClear = '/grocery/clear';

  // Users
  static const String userProfile = '/users/profile';
}
