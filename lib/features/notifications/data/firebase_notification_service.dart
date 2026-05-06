import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:skill_circle_app/features/notifications/domain/notification_service.dart';

class FirebaseNotificationService implements NotificationService {
  FirebaseNotificationService(this._messaging, this._localNotifications);

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  final _tokenRefreshStreamController = StreamController<String>.broadcast();
  final Set<String> _recentNotificationIds = {}; // Dedupe notifications

  static const Duration _dedupeWindow = Duration(seconds: 5);

  @override
  Future<void> initialize({required VoidCallback? onNotificationTap}) async {
    // Configure local notifications (Android)
    const androidSettings = AndroidInitializationSettings('app_icon');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (response) {
        _handleNotificationTap(response.payload, onNotificationTap);
      },
    );

    // Create notification channel for Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'skill_circle_channel',
            'Skill Circle Notifications',
            description: 'Notifications for posts, comments, and activities',
            importance: Importance.high,
            enableVibration: true,
            showBadge: true,
          ),
        );

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      _handleForegroundMessage(message);
    });

    // Listen to background message taps
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationTap(message.data['targetId'], onNotificationTap);
    });

    // Listen to token refreshes
    _messaging.onTokenRefresh.listen((token) {
      _tokenRefreshStreamController.add(token);
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final id = message.messageId ?? DateTime.now().toString();

    // Dedupe: skip if we saw this notification recently
    if (_recentNotificationIds.contains(id)) return;
    _recentNotificationIds.add(id);
    Future.delayed(_dedupeWindow, () => _recentNotificationIds.remove(id));

    final data = message.data;
    final notification = message.notification;

    if (notification == null) return;

    final payload = NotificationPayload(
      id: id,
      title: notification.title ?? 'Skill Circle',
      body: notification.body ?? '',
      type: data['type'],
      targetId: data['targetId'],
      timestamp: DateTime.now(),
    );

    showLocalNotification(payload);
  }

  void _handleNotificationTap(String? targetId, VoidCallback? onNotificationTap) {
    // This would navigate based on targetId type (postId, circleId, etc.)
    // For now, we just invoke the callback
    onNotificationTap?.call();
  }

  @override
  Future<bool> requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized || settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  @override
  Future<String?> getToken() async {
    return _messaging.getToken();
  }

  @override
  Stream<String> get tokenRefreshStream => _tokenRefreshStreamController.stream;

  @override
  Future<void> showLocalNotification(NotificationPayload payload) async {
    final androidDetails = const AndroidNotificationDetails(
      'skill_circle_channel',
      'Skill Circle Notifications',
      channelDescription: 'Notifications for posts, comments, and activities',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _localNotifications.show(
      payload.id.hashCode,
      payload.title,
      payload.body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload.id,
    );
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  void dispose() {
    _tokenRefreshStreamController.close();
  }
}
