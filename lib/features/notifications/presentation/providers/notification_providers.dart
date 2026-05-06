import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/features/notifications/data/device_token_service.dart';
import 'package:skill_circle_app/features/notifications/data/firebase_notification_service.dart';
import 'package:skill_circle_app/features/notifications/domain/notification_service.dart';
import 'package:skill_circle_app/features/notifications/presentation/controllers/notification_setup_controller.dart';

final firebaseMessagingProvider = Provider((ref) => FirebaseMessaging.instance);

final localNotificationsProvider = Provider((ref) => FlutterLocalNotificationsPlugin());

final firebaseFirestoreProvider = Provider((ref) => FirebaseFirestore.instance);

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final messaging = ref.read(firebaseMessagingProvider);
  final localNotifications = ref.read(localNotificationsProvider);
  return FirebaseNotificationService(messaging, localNotifications);
});

final deviceTokenServiceProvider = Provider((ref) {
  final firestore = ref.read(firebaseFirestoreProvider);
  return DeviceTokenService(firestore);
});

final notificationSetupControllerProvider = StateNotifierProvider<NotificationSetupController, AsyncValue<void>>((ref) {
  final notificationService = ref.read(notificationServiceProvider);
  final deviceTokenService = ref.read(deviceTokenServiceProvider);
  return NotificationSetupController(notificationService, deviceTokenService);
});

final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  return service.getToken();
});

final tokenRefreshProvider = StreamProvider<String>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return service.tokenRefreshStream;
});
