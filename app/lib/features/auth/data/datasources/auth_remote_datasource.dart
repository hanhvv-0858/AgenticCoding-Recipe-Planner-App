import 'package:recipe_planner/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Abstract data source for auth remote operations.
abstract class AuthRemoteDataSource {
  /// Register a new user.
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
  });

  /// Sign in with email and password.
  Future<UserModel> login({
    required String email,
    required String password,
  });

  /// Get the current user.
  Future<UserModel?> getCurrentUser();

  /// Sign out.
  Future<void> logout();

  /// Check if authenticated.
  Future<bool> isAuthenticated();
}

/// Implementation using supabase_flutter.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  sb.SupabaseClient get _supabase => sb.Supabase.instance.client;

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': displayName},
    );

    if (response.user == null) {
      throw Exception('Registration failed');
    }

    // Create user profile row in the users table.
    // After signUp, the session is active, so auth.uid() matches the new user's
    // id, which satisfies the RLS INSERT policy.
    try {
      await _supabase.from('users').upsert({
        'id': response.user!.id,
        'display_name': displayName,
      });
    } catch (e) {
      // Profile creation failure is non-fatal — the user can still use the app.
      // The login flow will also attempt to read/create the profile.
      // ignore: avoid_print
      print('Warning: Could not create user profile: $e');
    }

    return UserModel(
      id: response.user!.id,
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Invalid email or password');
    }

    // Fetch profile
    final profile = await _supabase
        .from('users')
        .select()
        .eq('id', response.user!.id)
        .maybeSingle();

    if (profile != null) {
      // Inject email from auth user since users table has no email column
      final enriched = Map<String, dynamic>.from(profile);
      enriched['email'] = response.user!.email ?? email;
      return UserModel.fromJson(enriched);
    }

    // Profile doesn't exist — create it now (handles users registered before
    // the profile-creation fix was added).
    final displayName =
        response.user!.userMetadata?['display_name'] as String? ?? 'User';
    try {
      await _supabase.from('users').upsert({
        'id': response.user!.id,
        'display_name': displayName,
      });
    } catch (_) {
      // ignore — fall through to return a model from auth metadata
    }

    return UserModel(
      id: response.user!.id,
      email: response.user!.email ?? email,
      displayName:
          response.user!.userMetadata?['display_name'] as String? ?? 'User',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return null;

    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final profile = await _supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (profile != null) {
      // Inject email from auth user since users table has no email column
      final enriched = Map<String, dynamic>.from(profile);
      enriched['email'] = user.email ?? '';
      return UserModel.fromJson(enriched);
    }

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['display_name'] as String? ?? 'User',
    );
  }

  @override
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  @override
  Future<bool> isAuthenticated() async {
    return _supabase.auth.currentSession != null;
  }
}
