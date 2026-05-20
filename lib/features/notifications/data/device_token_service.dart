import 'package:appwrite/appwrite.dart';
import 'package:skill_circle_app/core/constants/appwrite_storage_config.dart';
import 'package:skill_circle_app/features/notifications/domain/notification_service.dart';

class DeviceTokenService {
  DeviceTokenService(this._databases, this._config);

  final Databases _databases;
  final AppwriteStorageConfig _config;

  /// Store or update FCM token for the current user.
  Future<void> saveDeviceToken({required String userId, required String token}) async {
    try {
      await _databases.updateDocument(
        databaseId: _config.databaseId,
        collectionId: _config.usersCollectionId,
        documentId: userId,
        data: {'fcmToken': token},
      );
    } catch (e) {
      print('Error saving device token: $e');
    }
  }

  /// Remove device token when user logs out.
  Future<void> deleteDeviceToken({required String userId}) async {
    try {
      await _databases.updateDocument(
        databaseId: _config.databaseId,
        collectionId: _config.usersCollectionId,
        documentId: userId,
        data: {'fcmToken': null},
      );
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

  /// Get all tokens for a user.
  Future<List<String>> getUserTokens({required String userId}) async {
    try {
      final doc = await _databases.getDocument(
        databaseId: _config.databaseId,
        collectionId: _config.usersCollectionId,
        documentId: userId,
      );
      final token = doc.data['fcmToken'] as String?;
      return token != null && token.isNotEmpty ? [token] : [];
    } catch (e) {
      print('Error getting user tokens: $e');
      return [];
    }
  }
}
