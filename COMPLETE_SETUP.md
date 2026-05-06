# SkillCircle App - Complete Setup Guide

## Overview
SkillCircle is a production-ready Flutter application featuring Firebase backend integration with real-time updates, user authentication, community circles, posts, comments, file uploads, and push notifications.

## What's Implemented

### 1. **Authentication & User Profiles**
- ✅ Firebase Authentication (Email/Password, Google Sign-In)
- ✅ User profile management with image uploads
- ✅ User registration and login with validation
- ✅ Auth state persistence and guards

### 2. **Core Features**
- ✅ **Skill Circles** - Browse, search, join/leave circles
- ✅ **Posts** - Create posts with file attachments, view feed
- ✅ **Comments** - Add comments on posts (scaffolded with full CRUD)
- ✅ **Upvotes** - Vote/unvote posts with transaction safety
- ✅ **File Uploads** - Upload PDF/images to Firebase Storage (10MB images, 50MB PDFs)

### 3. **Real-Time & Pagination**
- ✅ Real-time Firestore listeners for posts, comments, votes
- ✅ Lazy-load pagination with "Load more"
- ✅ Optimistic UI updates for fast feedback
- ✅ Network retry logic (exponential backoff)

### 4. **Push Notifications**
- ✅ Firebase Cloud Messaging (FCM)
- ✅ Foreground notifications via local notifications
- ✅ Background message handling
- ✅ Notification deduplication (avoid spam)
- ✅ Topic-based subscriptions (circles, posts)
- ✅ Automatic FCM token refresh and storage
- ✅ Notification tap routing (deep linking ready)

### 5. **UI/Navigation**
- ✅ Bottom navigation bar (Circles, Feed, Profile)
- ✅ GoRouter for navigation management
- ✅ Theme & color tokens
- ✅ Responsive layouts

### 6. **Architecture**
- ✅ Clean Architecture (Domain/Data/Presentation layers)
- ✅ Riverpod state management
- ✅ Repository pattern for data access
- ✅ Firestore best practices (FieldValue.increment, transactions)

---

## Project Structure

```
lib/
├── core/
│   ├── constants/        # Routes, app config
│   ├── providers/        # Global providers
│   ├── services/         # Firebase init, router
│   ├── theme/            # App theme & colors
│   └── presentation/
│       └── widgets/      # MainShellPage (navbar)
├── features/
│   ├── auth/             # Login, register, auth logic
│   ├── profile/          # User profile management
│   ├── skill_circles/    # Circles feature
│   ├── posts/            # Posts & upvotes
│   ├── comments/         # Comments (basic CRUD)
│   ├── notifications/    # FCM, local notifications
│   └── storage/          # File uploads to Firebase Storage
└── main.dart             # App entry point
```

---

## Quick Start

### 1. Prerequisites
- Flutter 3.6.0+
- Dart 3.x
- Firebase project with:
  - Firestore enabled
  - Authentication (Email + Google)
  - Storage bucket
  - Cloud Messaging
  - Cloud Functions (optional, for sending notifications)

### 2. Setup Environment
```bash
# Clone repo and navigate to project
cd skill_circle_app

# Get dependencies
flutter pub get

# Configure Firebase
# - Copy google-services.json to android/app/
# - Copy GoogleService-Info.plist to ios/Runner/
```

### 3. Configure Android (for FCM)
The Android build has been configured with:
- Core library desugaring enabled (required for flutter_local_notifications)
- Min SDK 23
- Target SDK 34

### 4. Run the App
```bash
# Debug on connected device
flutter run

# Release build (after proper signing)
flutter build apk --release
flutter build ipa --release
```

---

## Key Features Explained

### Circles
- Browse all skill circles
- Search circles by name
- Join/leave circles with Firestore transactions
- Real-time member count

### Posts
- Create posts with optional file attachments (images/PDFs)
- Real-time post feed with pagination
- Upvote/downvote posts
- Optimistic UI for instant feedback
- Cooldown to prevent spam (30 seconds between posts)

### Comments
- Add comments to posts
- Real-time comment updates
- Pagination support for large threads

### Notifications
- Receive notifications for:
  - New posts in joined circles
  - New comments on your posts
- Handle foreground (local) & background notifications
- Subscribe to topics on join, unsubscribe on leave

### File Uploads
- Pick and upload files (images/PDFs)
- Validation: type checking, size limits
- Retry logic for failed uploads
- Preview images inline, PDFs as attachments

---

## Cloud Functions (Backend)

For notifications to work, you need Cloud Functions triggers. Example:

```javascript
// Trigger when a new post is created
exports.onPostCreated = functions.firestore
  .document('posts/{postId}')
  .onCreate(async (snap, context) => {
    const post = snap.data();
    const message = {
      notification: {
        title: 'New Post',
        body: post.post_content.substring(0, 100)
      },
      data: {
        type: 'post',
        targetId: post.circle_id
      },
      topic: `circle_${post.circle_id}_posts`
    };
    await admin.messaging().send(message);
  });
```

See `FCM_SETUP.md` for detailed Cloud Functions examples.

---

## Firestore Rules (Security)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User profiles
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }

    // Circles
    match /circles/{circleId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == resource.data.createdBy;
      
      // Members
      match /members/{memberId} {
        allow read, write: if request.auth.uid == memberId || request.auth.uid == get(/databases/$(database)/documents/circles/$(circleId)).data.createdBy;
      }
    }

    // Posts
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth.uid == resource.data.userId;
      
      // Post votes
      match /postVotes/{voteId} {
        allow read: if request.auth != null;
        allow create, delete: if request.auth.uid == request.resource.data.userId;
      }
    }

    // Comments
    match /comments/{commentId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow delete: if request.auth.uid == resource.data.userId;
    }

    // Device tokens for notifications
    match /userDevices/{deviceId} {
      allow read, write: if request.auth.uid == resource.data.user_id;
      allow create: if request.auth != null;
    }
  }
}
```

---

## Known Limitations & Future Work

### Current Limitations
- Comments UI is scaffolded (no threaded UI yet)
- Notification routing not fully wired (extend `_handleNotificationTap`)
- No offline mode (Firestore offline persistence can be added)
- No user blocking/reporting

### Future Enhancements
- Threaded comment UI
- Direct messaging between users
- Badge/achievement system
- Analytics integration
- Advanced search & filters
- Admin dashboard for circle moderation

---

## Troubleshooting

### Build Issues
- **Android desugaring error**: Ensure `coreLibraryDesugaring` is enabled in `android/app/build.gradle`
- **FCM token is null**: Check permissions, Google Play Services on device

### Runtime Issues
- **Notifications not showing**: Verify permissions granted, check Firebase Console
- **Can't upload files**: Check Firebase Storage rules and file size limits
- **Comments not loading**: Verify Firestore read permissions

---

## Dependencies

Key packages:
- **firebase_core, firebase_auth, cloud_firestore**: Backend
- **firebase_storage**: File uploads
- **firebase_messaging**: Push notifications
- **flutter_local_notifications**: Foreground notifications
- **flutter_riverpod**: State management
- **go_router**: Navigation
- **file_picker**: File selection
- **image_picker**: Image selection

See `pubspec.yaml` for full dependency list.

---

## Environment Configuration

Create `.env.dev` and `.env.prod` files in `assets/env/`:

```
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-bucket.appspot.com
FIREBASE_MESSAGING_SENDER_ID=your-sender-id
```

The app loads these via `flutter_dotenv`.

---

## Testing

To test locally without Cloud Functions:
1. Use Firebase Console > Cloud Messaging > Send test message
2. Send to topic (e.g., `circle_test_posts`)
3. Verify notification appears in app

---

## Deployment

### Android
```bash
# Create key
keytool -genkey -v -keystore ~/keystore.jks -keyalias skillcircle -keyalg RSA -keysize 2048 -validity 10000

# Build release APK
flutter build apk --release

# Or app bundle (for Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Set up signing in Xcode
flutter build ios --release

# Create archive for TestFlight/App Store
```

---

## Support & Documentation

- [Firebase Docs](https://firebase.google.com/docs)
- [Flutter Docs](https://flutter.dev/docs)
- [Riverpod Docs](https://riverpod.dev)
- [GoRouter Docs](https://pub.dev/packages/go_router)

---

## License

This project is provided as-is for educational and commercial use.
