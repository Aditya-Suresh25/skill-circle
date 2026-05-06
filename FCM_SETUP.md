# Firebase Cloud Messaging (FCM) Setup Guide

## Overview
This document explains how to set up Firebase Cloud Messaging for sending push notifications in the SkillCircle app. The app supports:
- Foreground notifications (via local notifications)
- Background notifications (FCM handled)
- Notification taps for deep linking
- Topic-based subscriptions for circles and posts
- Automatic token refresh and storage

## Prerequisites
- Firebase project with Cloud Messaging enabled
- Android app configured in Firebase Console
- iOS app configured in Firebase Console (with APNs certificate)
- `google-services.json` in `android/app/`
- `GoogleService-Info.plist` in `ios/Runner/`

## Configuration Steps

### 1. Android Setup

#### Add APK Signing (Required for FCM)
Edit `android/app/build.gradle`:
```gradle
android {
  ...
  signingConfigs {
    release {
      storeFile file(System.getenv("KEYSTORE_FILE") ?: "debug.keystore")
      storePassword System.getenv("KEYSTORE_PASSWORD")
      keyAlias System.getenv("KEY_ALIAS")
      keyPassword System.getenv("KEY_PASSWORD")
    }
  }
  buildTypes {
    release {
      signingConfig signingConfigs.release
    }
  }
}
```

#### Notification Channel (Android 8+)
The app automatically creates a notification channel:
- ID: `skill_circle_channel`
- Importance: High
- Sound & Vibration: Enabled

### 2. iOS Setup

#### Add Capabilities
In Xcode (Runner.xcworkspace):
1. Target > Runner > Signing & Capabilities
2. Add "+ Capability" > Push Notifications
3. Add "+ Capability" > Background Modes
4. In Background Modes, enable: Remote notifications

#### APNs Certificate
1. Go to [Apple Developer Console](https://developer.apple.com/account)
2. Create an APNs certificate for your app ID
3. Download and upload to Firebase Console > Project Settings > Cloud Messaging

### 3. Firebase Console Configuration

#### Enable Cloud Messaging
1. Go to Firebase Console > Project Settings
2. Ensure Cloud Messaging tab is visible
3. Upload APNs certificate (iOS)
4. Ensure Android app is registered

#### Create Topics
Send notifications to subscribed users:
- `circle_{circleId}`: All members of a circle
- `circle_{circleId}_posts`: New posts in a circle
- `post_{postId}_comments`: New comments on a post

### 4. Notification Payload Format

When sending notifications via Cloud Functions or REST API:

```json
{
  "notification": {
    "title": "New post in Flutter Circle",
    "body": "Check out the latest post"
  },
  "data": {
    "type": "post",
    "targetId": "post_12345",
    "timestamp": "2026-05-05T10:30:00Z"
  },
  "webpush": {
    "ttl": "3600s"
  },
  "android": {
    "priority": "high",
    "ttl": "3600s"
  },
  "apns": {
    "headers": {
      "apns-priority": "10"
    }
  }
}
```

### 5. Dart Code Usage

#### Get FCM Token
```dart
final token = await FirebaseMessaging.instance.getToken();
// Send this token to your backend for user device tracking
```

#### Subscribe to Circle Notifications
```dart
final controller = ref.read(notificationSetupControllerProvider.notifier);
await controller.subscribeToCircle('circle_12345');
```

#### Handle Notification Taps
The app automatically handles navigation based on the `type` and `targetId` in the notification payload. Extend `_handleNotificationTap` in `firebase_notification_service.dart` to add custom navigation logic.

## Backend (Cloud Functions) Example

```javascript
// Trigger when a new post is created
exports.onPostCreated = functions.firestore
  .document('posts/{postId}')
  .onCreate(async (snap, context) => {
    const post = snap.data();
    const circleId = post.circle_id;
    
    const message = {
      notification: {
        title: 'New Post',
        body: post.post_content.substring(0, 100)
      },
      data: {
        type: 'post',
        targetId: circleId,
        timestamp: new Date().toISOString()
      },
      topic: `circle_${circleId}_posts`
    };
    
    try {
      await admin.messaging().send(message);
    } catch (error) {
      console.error('Error sending notification:', error);
    }
  });

// Trigger when a new comment is added
exports.onCommentCreated = functions.firestore
  .document('comments/{commentId}')
  .onCreate(async (snap, context) => {
    const comment = snap.data();
    const postId = comment.post_id;
    
    const message = {
      notification: {
        title: 'New Comment',
        body: comment.comment_text.substring(0, 100)
      },
      data: {
        type: 'comment',
        targetId: postId,
        timestamp: new Date().toISOString()
      },
      topic: `post_${postId}_comments`
    };
    
    try {
      await admin.messaging().send(message);
    } catch (error) {
      console.error('Error sending notification:', error);
    }
  });
```

## Testing

### Manual Testing via Firebase Console
1. Firebase Console > Cloud Messaging > Send your first message
2. Select "Send to a topic"
3. Enter topic name (e.g., `circle_123_posts`)
4. Send test notification

### Debug Logs
The app logs FCM tokens and notification events to the console:
```
FCM Token: eqhN...
Background message received: abc123
Notifications initialized for user: user_123
```

## Troubleshooting

### Token is null
- Ensure permissions are granted on the device
- Check that the device has Google Play Services installed
- On iOS, verify APNs certificate is uploaded to Firebase

### Notifications not received
- Verify topic subscription (check the logs)
- Ensure user has granted notification permissions
- Check Firebase Console > Cloud Messaging for message status

### Foreground notifications not showing
- Ensure `NotificationSetupWidget` is wrapping the MaterialApp
- Verify notification channel is created (Android 8+)
- Check that sound/vibration permissions are granted

## Security Rules

### Firestore Rules for Device Tokens
```
match /userDevices/{document=**} {
  allow read, write: if request.auth.uid == resource.data.user_id;
  allow create: if request.auth.uid != null;
}
```

### Cloud Functions Security
- Validate token sender is authenticated
- Use Firebase Admin SDK only in Cloud Functions
- Never expose service account keys

## Additional Resources
- [Firebase Cloud Messaging Docs](https://firebase.google.com/docs/cloud-messaging)
- [FCM Message Types](https://firebase.google.com/docs/cloud-messaging/http-server-ref)
- [Flutter Firebase Messaging Plugin](https://pub.dev/packages/firebase_messaging)
