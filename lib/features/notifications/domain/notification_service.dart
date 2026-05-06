import 'package:flutter/material.dart';

class NotificationPayload {
  const NotificationPayload({
    required this.id,
    required this.title,
    required this.body,
    this.type,
    this.targetId,
    this.timestamp,
  });

  final String id;
  final String title;
  final String body;
  final String? type; // 'comment', 'post', etc.
  final String? targetId; // postId, circleId, etc.
  final DateTime? timestamp;

  factory NotificationPayload.fromMap(Map<String, dynamic> map) {
    return NotificationPayload(
      id: map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      type: map['type'] as String?,
      targetId: map['targetId'] as String?,
      timestamp: map['timestamp'] != null ? DateTime.tryParse(map['timestamp'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      if (type != null) 'type': type,
      if (targetId != null) 'targetId': targetId,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };
  }
}

abstract class NotificationService {
  /// Initialize notifications (request permissions, set up handlers).
  Future<void> initialize({required VoidCallback? onNotificationTap});

  /// Request notification permissions (iOS 13+).
  Future<bool> requestPermissions();

  /// Get the FCM token.
  Future<String?> getToken();

  /// Listen to FCM token refreshes.
  Stream<String> get tokenRefreshStream;

  /// Send a local (test) notification.
  Future<void> showLocalNotification(NotificationPayload payload);

  /// Subscribe to a topic.
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribe from a topic.
  Future<void> unsubscribeFromTopic(String topic);
}
