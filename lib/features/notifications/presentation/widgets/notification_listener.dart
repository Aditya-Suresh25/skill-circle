import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/services/app_router.dart';
import 'package:skill_circle_app/features/notifications/presentation/providers/notification_providers.dart';

/// Widget that handles notification setup lifecycle.
/// Initializes notifications when user logs in, cleans up on logout.
class NotificationSetupWidget extends ConsumerStatefulWidget {
  const NotificationSetupWidget({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NotificationSetupWidget> createState() => _NotificationSetupWidgetState();
}

class _NotificationSetupWidgetState extends ConsumerState<NotificationSetupWidget> {

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (previous, next) {
      final user = next.valueOrNull;
      final prevUser = previous?.valueOrNull;

      if (user != null && prevUser == null) {
        // User logged in
        _initializeNotifications(user.id);
      } else if (user == null && prevUser != null) {
        // User logged out
        _cleanupNotifications(prevUser.id);
      }
    });

    return widget.child;
  }

  Future<void> _initializeNotifications(String userId) async {
    try {
      final controller = ref.read(notificationSetupControllerProvider.notifier);
      await controller.initialize(userId: userId);
      print('Notifications initialized for user: $userId');
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  Future<void> _cleanupNotifications(String userId) async {
    try {
      final controller = ref.read(notificationSetupControllerProvider.notifier);
      await controller.cleanup(userId: userId);
      print('Notifications cleaned up for user: $userId');
    } catch (e) {
      print('Error cleaning up notifications: $e');
    }
  }
}
