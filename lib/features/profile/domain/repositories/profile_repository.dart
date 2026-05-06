import 'dart:io';

import '../entities/profile.dart';

abstract class ProfileRepository {
  /// Fetch user profile from Firestore
  Future<Profile> getUserProfile(String userId);

  /// Create initial user profile after signup
  Future<void> createUserProfile(Profile profile);

  /// Watch user profile changes in real-time
  Stream<Profile?> watchProfile(String userId);

  /// Save/update user profile
  Future<void> saveProfile(Profile profile);

  /// Update specific profile fields
  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates);

  /// Upload profile image to Firebase Storage
  /// Returns the download URL
  Future<String> uploadProfileImage(String userId, File imageFile);

  /// Delete profile image from Firebase Storage
  Future<void> deleteProfileImage(String userId);
}