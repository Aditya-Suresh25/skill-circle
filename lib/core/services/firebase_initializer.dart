import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:skill_circle_app/firebase_options.dart';

class FirebaseInitializer {
  const FirebaseInitializer._();

  static Future<FirebaseApp> initialize() async {
    final app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    try {
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
      await FirebaseMessaging.instance.requestPermission();
    } catch (_) {
      // Non-fatal during startup.
    }

    return app;
  }
}