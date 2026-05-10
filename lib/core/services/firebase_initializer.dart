import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:skill_circle_app/firebase_options.dart';

class FirebaseInitializer {
  const FirebaseInitializer._();

  static Future<FirebaseApp> initialize() async {
    final app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
    try {
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
      await FirebaseMessaging.instance.requestPermission();
    } catch (_) {
      // Non-fatal during startup.
    }
    FirebaseAuth.instance.setLanguageCode('en');

    return app;
  }
}