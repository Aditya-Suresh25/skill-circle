import 'package:firebase_messaging/firebase_messaging.dart';

/// Top-level background message handler.
/// This is called when a message is received while the app is in the background or terminated.
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // You can perform work here, but be aware of the 30-second limit.
  // For simplicity, we just log; in production, you might save to local storage for later retrieval.
  print('Background message received: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
}
