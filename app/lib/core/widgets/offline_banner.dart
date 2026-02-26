import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_planner/core/sync/sync_bloc.dart';
import 'package:recipe_planner/core/theme/app_colors.dart';

/// Persistent banner shown when the app is offline.
///
/// Displays connectivity status and sync state from SyncBloc.
/// Per FR-035: user should always know connectivity status.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncBloc, SyncState>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType,
      builder: (context, state) {
        if (state is SyncIdle) {
          return const SizedBox.shrink();
        }

        return AnimatedSlide(
          offset: _isVisible(state) ? Offset.zero : const Offset(0, -1),
          duration: const Duration(milliseconds: 300),
          child: Material(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: _backgroundColor(state),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    Icon(
                      _icon(state),
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _message(state),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (state is SyncSyncing)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isVisible(SyncState state) {
    return state is! SyncIdle;
  }

  Color _backgroundColor(SyncState state) {
    if (state is SyncError) return AppColors.error;
    if (state is SyncSyncing) return AppColors.warning;
    if (state is SyncCompleted) return AppColors.success;
    if (state is SyncOffline) return Colors.grey.shade700;
    return Colors.grey.shade700;
  }

  IconData _icon(SyncState state) {
    if (state is SyncError) return Icons.cloud_off;
    if (state is SyncSyncing) return Icons.sync;
    if (state is SyncCompleted) return Icons.cloud_done;
    if (state is SyncOffline) return Icons.wifi_off;
    return Icons.wifi_off;
  }

  String _message(SyncState state) {
    if (state is SyncError) return 'Sync error. Changes saved locally.';
    if (state is SyncSyncing) return 'Syncing your changes...';
    if (state is SyncCompleted) return 'All changes synced';
    if (state is SyncOffline) return 'You are offline. Changes saved locally.';
    return 'No internet connection';
  }
}
