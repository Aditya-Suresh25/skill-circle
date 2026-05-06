import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:skill_circle_app/features/profile/domain/entities/profile.dart';
import 'package:skill_circle_app/features/profile/domain/repositories/profile_repository.dart';

class FirebaseProfileRepository implements ProfileRepository {
  FirebaseProfileRepository(
    this._firestore,
    this._storage,
  );

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  static const String _usersCollection = 'users';
  static const String _profileImagesPath = 'profile_images';

  @override
  Future<Profile> getUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        throw StateError('User profile not found');
      }

      return Profile.fromFirestore(doc);
    } catch (e) {
      throw _handleError('Failed to fetch profile', e);
    }
  }

  @override
  Future<void> createUserProfile(Profile profile) async {
    try {
      await _firestore.collection(_usersCollection).doc(profile.id).set(
            profile.toFirestore(),
          );
    } catch (e) {
      throw _handleError('Failed to create profile', e);
    }
  }

  @override
  Stream<Profile?> watchProfile(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return null;
      }

      return Profile.fromFirestore(doc);
    }).handleError((e) {
      throw _handleError('Failed to watch profile', e);
    });
  }

  @override
  Future<void> saveProfile(Profile profile) async {
    try {
      await _firestore.collection(_usersCollection).doc(profile.id).set(
            profile.toFirestore(),
            SetOptions(merge: true),
          );
    } catch (e) {
      throw _handleError('Failed to save profile', e);
    }
  }

  @override
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Add updatedAt timestamp
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update(updates);
    } catch (e) {
      throw _handleError('Failed to update profile', e);
    }
  }

  @override
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      // Create a unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = '${userId}_$timestamp.jpg';

      final ref = _storage.ref().child(_profileImagesPath).child(filename);

      // Upload with timeout
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'userId': userId},
        ),
      );

      await uploadTask.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          uploadTask.cancel();
          throw TimeoutException('Profile image upload timed out');
        },
      );

      // Get and return download URL
      final downloadUrl = await ref.getDownloadURL();

      // Update user profile with new photo URL
      await updateUserProfile(userId, {'photoUrl': downloadUrl});

      return downloadUrl;
    } catch (e) {
      throw _handleError('Failed to upload profile image', e);
    }
  }

  @override
  Future<void> deleteProfileImage(String userId) async {
    try {
      final profile = await getUserProfile(userId);

      if (profile.photoUrl == null) {
        return; // No image to delete
      }

      // Extract the path from the download URL
      final ref = _storage.refFromURL(profile.photoUrl!);
      await ref.delete();

      // Update user profile to remove photo URL
      await updateUserProfile(userId, {'photoUrl': FieldValue.delete()});
    } catch (e) {
      throw _handleError('Failed to delete profile image', e);
    }
  }

  /// Handle various error types and return user-friendly messages
  Exception _handleError(String message, dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'not-found':
          return Exception('Profile not found');
        case 'permission-denied':
          return Exception('You do not have permission to access this profile');
        case 'unavailable':
          return Exception('Service unavailable. Please try again later');
        case 'network-request-failed':
          return Exception('Network error. Please check your connection');
        default:
          return Exception('$message: ${error.message}');
      }
    }

    if (error is SocketException) {
      return Exception('Network error. Please check your connection');
    }

    if (error is TimeoutException) {
      return Exception('Operation timed out. Please try again');
    }

    return Exception('$message: ${error.toString()}');
  }
}