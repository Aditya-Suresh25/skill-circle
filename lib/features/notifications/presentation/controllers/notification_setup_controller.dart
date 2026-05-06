import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/features/notifications/data/device_token_service.dart';
import 'package:skill_circle_app/features/notifications/domain/notification_service.dart';

class NotificationSetupController extends StateNotifier<AsyncValue<void>> {
  NotificationSetupController(this._notificationService, this._deviceTokenService) : super(const AsyncValue.data(null));

  final NotificationService _notificationService;
  final DeviceTokenService _deviceTokenService;
  StreamSubscription<String>? _tokenRefreshSub;

  /// Initialize notifications and set up token refresh listener.
  Future<void> initialize({required String userId}) async {
    state = const AsyncValue.loading();
    try {
      // Get initial token and save it
      final token = await _notificationService.getToken();
      if (token != null) {
        await _deviceTokenService.saveDeviceToken(userId: userId, token: token);
      }

      // Listen to token refreshes and update whenever token changes
      _tokenRefreshSub = _notificationService.tokenRefreshStream.listen((newToken) {
        _handleTokenRefresh(userId, newToken);
      });

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void _handleTokenRefresh(String userId, String newToken) {
    _deviceTokenService.saveDeviceToken(userId: userId, token: newToken).catchError((e) {
      print('Error updating token on refresh: $e');
    });
  }

  /// Subscribe to a circle's notifications.
  Future<void> subscribeToCircle(String circleId) async {
    try {
      await _deviceTokenService.subscribeToCirlceNotifications(circleId: circleId, notificationService: _notificationService);
    } catch (e) {
      print('Error subscribing to circle: $e');
      rethrow;
    }
  }

  /// Unsubscribe from a circle's notifications.
  Future<void> unsubscribeFromCircle(String circleId) async {
    try {
      await _deviceTokenService.unsubscribeFromCircleNotifications(circleId: circleId, notificationService: _notificationService);
    } catch (e) {
      print('Error unsubscribing from circle: $e');
    }
  }

  /// Clean up on logout.
  Future<void> cleanup({required String userId}) async {
    _tokenRefreshSub?.cancel();
    await _deviceTokenService.deleteDeviceToken(userId: userId);
  }

  @override
  void dispose() {
    _tokenRefreshSub?.cancel();
    super.dispose();
  }
}
