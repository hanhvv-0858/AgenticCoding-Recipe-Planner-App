import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_planner/core/theme/app_colors.dart';
import 'package:recipe_planner/features/auth/presentation/bloc/auth_bloc.dart';

/// Profile page — user settings and account management.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            context.go('/login');
          }
        },
        builder: (context, state) {
          if (state is Authenticated) {
            return _AuthenticatedProfile(user: state.user);
          }

          if (state is GuestMode) {
            return _GuestProfile();
          }

          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Default: show guest profile
          return _GuestProfile();
        },
      ),
    );
  }
}

class _AuthenticatedProfile extends StatelessWidget {
  final dynamic user;

  const _AuthenticatedProfile({required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),

          // Avatar
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null
                ? Text(
                    _getInitials(user.displayName),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),

          // Display name
          Text(
            user.displayName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),

          // Settings section
          _buildSectionTitle(context, 'Account'),
          _buildSettingsTile(
            context,
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              // TODO: Navigate to edit profile
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {
              // TODO: Navigate to notifications settings
            },
          ),

          const SizedBox(height: 16),
          _buildSectionTitle(context, 'Preferences'),
          _buildSettingsTile(
            context,
            icon: Icons.palette_outlined,
            title: 'Theme',
            subtitle: 'Light',
            onTap: () {
              // TODO: Theme toggle
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            onTap: () {
              // TODO: Language selection
            },
          ),

          const SizedBox(height: 16),
          _buildSectionTitle(context, 'About'),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: '1.0.0',
            onTap: null,
          ),
          _buildSettingsTile(
            context,
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {
              // TODO: Open terms
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              // TODO: Open privacy
            },
          ),

          const SizedBox(height: 32),

          // Sign out button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Sign Out'),
                    content:
                        const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          context
                              .read<AuthBloc>()
                              .add(const LogoutRequested());
                        },
                        child: Text(
                          'Sign Out',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(Icons.logout, color: AppColors.error),
              label: Text(
                'Sign Out',
                style: TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class _GuestProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 80,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'Guest Mode',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to sync your recipes, meal plans,\nand grocery lists across devices.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),

            // Sign in button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => context.go('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Create account button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => context.go('/register'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildSectionTitle(BuildContext context, String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
      ),
    ),
  );
}

Widget _buildSettingsTile(
  BuildContext context, {
  required IconData icon,
  required String title,
  String? subtitle,
  VoidCallback? onTap,
}) {
  return ListTile(
    leading: Icon(icon, color: AppColors.primary),
    title: Text(title),
    subtitle: subtitle != null ? Text(subtitle) : null,
    trailing: onTap != null
        ? const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant)
        : null,
    onTap: onTap,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}
