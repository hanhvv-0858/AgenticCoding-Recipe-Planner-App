/// Application-wide constants.
class AppConstants {
  AppConstants._();

  static const int minServings = 1;
  static const int maxServings = 50;
  static const int defaultServings = 2;

  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  static const int maxRetries = 3;
  static const Duration retryBaseDelay = Duration(seconds: 1);

  static const List<String> ingredientCategories = [
    'Vegetables',
    'Fruits',
    'Meat/Fish',
    'Dairy',
    'Spices',
    'Grains',
    'Canned',
    'Frozen',
    'Beverages',
    'Other',
  ];
}

/// Meal type enumeration.
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  String get emoji {
    switch (this) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '🍿';
    }
  }
}

/// Media type for cooking steps.
enum MediaType {
  image,
  video;
}
