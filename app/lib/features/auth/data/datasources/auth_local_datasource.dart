import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recipe_planner/features/auth/data/models/user_model.dart';

/// Abstract data source for auth local operations.
abstract class AuthLocalDataSource {
  /// Cache the current user info.
  Future<void> cacheUser(UserModel user);

  /// Get cached user info.
  Future<UserModel?> getCachedUser();

  /// Clear cached user.
  Future<void> clearCachedUser();

  /// Check if in guest mode.
  Future<bool> isGuestMode();

  /// Set guest mode flag.
  Future<void> setGuestMode(bool isGuest);
}

/// Implementation using SharedPreferences.
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _cachedUserKey = 'CACHED_USER';
  static const _guestModeKey = 'GUEST_MODE';

  @override
  Future<void> cacheUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedUserKey, jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_cachedUserKey);
    if (userJson == null) return null;

    try {
      return UserModel.fromJson(
          jsonDecode(userJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cachedUserKey);
  }

  @override
  Future<bool> isGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_guestModeKey) ?? true; // Default to guest
  }

  @override
  Future<void> setGuestMode(bool isGuest) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestModeKey, isGuest);
  }
}
