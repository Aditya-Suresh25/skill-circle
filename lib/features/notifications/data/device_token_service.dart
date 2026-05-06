import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_circle_app/features/notifications/domain/notification_service.dart';

class DeviceTokenService {
  DeviceTokenService(this._firestore);

  final FirebaseFirestore _firestore;

  static const String _devicesCollection = 'userDevices';

  /// Store or update FCM token for the current user.
  Future<void> saveDeviceToken({required String userId, required String token}) async {
    try {
      await _firestore.collection(_devicesCollection).doc('${userId}_device').set(
        {
          'user_id': userId,
          'fcm_token': token,
          'updated_at': FieldValue.serverTimestamp(),
          'platform': 'flutter', // Could be ios/android at more granular level
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Error saving device token: $e');
      rethrow;
    }
  }

  /// Remove device token when user logs out.
  Future<void> deleteDeviceToken({required String userId}) async {
    try {
      await _firestore.collection(_devicesCollection).doc('${userId}_device').delete();
    } catch (e) {
      print('Error deleting device token: $e');
    }
  }

  /// Subscribe user to circle notifications.
  Future<void> subscribeToCirlceNotifications({required String circleId, required NotificationService notificationService}) async {
    try {
      await notificationService.subscribeToTopic('circle_$circleId');
      await notificationService.subscribeToTopic('circle_${circleId}_posts');
    } catch (e) {
      print('Error subscribing to circle: $e');
      rethrow;
    }
  }

  /// Unsubscribe user from circle notifications.
  Future<void> unsubscribeFromCircleNotifications({required String circleId, required NotificationService notificationService}) async {
    try {
      await notificationService.unsubscribeFromTopic('circle_$circleId');
      await notificationService.unsubscribeFromTopic('circle_${circleId}_posts');
    } catch (e) {
      print('Error unsubscribing from circle: $e');
    }
  }

  /// Get all tokens for a user (for analytics).
  Future<List<String>> getUserTokens({required String userId}) async {
    try {
      final doc = await _firestore.collection(_devicesCollection).doc('${userId}_device').get();
      if (doc.exists) {
        final token = doc.data()?['fcm_token'] as String?;
        return token != null ? [token] : [];
      }
      return [];
    } catch (e) {
      print('Error getting user tokens: $e');
      return [];
    }
  }
}
