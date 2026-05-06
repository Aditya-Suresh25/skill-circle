import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return _current;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return _current;
    }
  }

  static FirebaseOptions get _current {
    return FirebaseOptions(
      apiKey: _required('FIREBASE_API_KEY'),
      appId: _required('FIREBASE_APP_ID'),
      messagingSenderId: _required('FIREBASE_MESSAGING_SENDER_ID'),
      projectId: _required('FIREBASE_PROJECT_ID'),
      authDomain: _optional('FIREBASE_AUTH_DOMAIN'),
      storageBucket: _optional('FIREBASE_STORAGE_BUCKET'),
      measurementId: _optional('FIREBASE_MEASUREMENT_ID'),
      databaseURL: _optional('FIREBASE_DATABASE_URL'),
      androidClientId: _optional('FIREBASE_ANDROID_CLIENT_ID'),
      iosClientId: _optional('FIREBASE_IOS_CLIENT_ID'),
      iosBundleId: _optional('FIREBASE_IOS_BUNDLE_ID'),
    );
  }

  static String _required(String key) {
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty || value == 'replace_me') {
      throw StateError('Missing Firebase configuration value for $key.');
    }
    return value;
  }

  static String? _optional(String key) {
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty || value == 'replace_me') {
      return null;
    }
    return value;
  }
}