import 'dart:async';
import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_circle_app/models/user_model.dart' as shared_models;
import 'package:skill_circle_app/features/profile/domain/entities/profile.dart';
import 'package:skill_circle_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:skill_circle_app/features/storage/domain/storage_service.dart';

class AppwriteProfileRepository implements ProfileRepository {
  AppwriteProfileRepository(
    this._firestore,
    this._storageService,
  );

  final FirebaseFirestore _firestore;
  final StorageService _storageService;

  static const String _usersCollection = 'users';

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

      return _mapToEntity(shared_models.UserModel.fromMap(doc.id, doc.data() ?? <String, dynamic>{}));
    } catch (e) {
      throw _handleError('Failed to fetch profile', e);
    }
  }

  @override
  Future<void> createUserProfile(Profile profile) async {
    try {
      await _firestore.collection(_usersCollection).doc(profile.id).set(
            _mapToModel(profile).toMap(),
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

      return _mapToEntity(shared_models.UserModel.fromMap(doc.id, doc.data() ?? <String, dynamic>{}));
    }).handleError((e) {
      throw _handleError('Failed to watch profile', e);
    });
  }

  @override
  Future<void> saveProfile(Profile profile) async {
    try {
      await _firestore.collection(_usersCollection).doc(profile.id).set(
            _mapToModel(profile).toMap(),
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
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = _imageExtension(imageFile.path);
      final filename = '${userId}_$timestamp$extension';
      final contentType = _imageContentType(extension);

      final uploaded = await _storageService
          .uploadFile(
            bytes: await imageFile.readAsBytes(),
            filename: filename,
            contentType: contentType,
            ownerId: userId,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Profile image upload timed out');
            },
          );

      final downloadUrl = uploaded.url;

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

      final fileId = _extractFileIdFromUrl(profile.photoUrl!);
      if (fileId != null) {
        await _storageService.deleteFile(fileId: fileId);
      }

      // Update user profile to remove photo URL
      await updateUserProfile(userId, {'photoUrl': FieldValue.delete()});
    } catch (e) {
      throw _handleError('Failed to delete profile image', e);
    }
  }

  /// Handle various error types and return user-friendly messages
  Exception _handleError(String message, dynamic error) {
    if (error is AppwriteException) {
      switch (error.code) {
        case 404:
          return Exception('Profile not found');
        case 401:
        case 403:
          return Exception('You do not have permission to access this profile');
        case 503:
          return Exception('Service unavailable. Please try again later');
        case 408:
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

  String? _extractFileIdFromUrl(String url) {
    final match = RegExp(r'/storage/buckets/[^/]+/files/([^/]+)/').firstMatch(url);
    if (match == null) return null;
    return Uri.decodeComponent(match.group(1)!);
  }

  String _imageExtension(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return '.png';
    if (lower.endsWith('.webp')) return '.webp';
    if (lower.endsWith('.gif')) return '.gif';
    if (lower.endsWith('.jpeg')) return '.jpeg';
    return '.jpg';
  }

  String _imageContentType(String extension) {
    switch (extension) {
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.gif':
        return 'image/gif';
      case '.jpeg':
      case '.jpg':
      default:
        return 'image/jpeg';
    }
  }

  shared_models.UserModel _mapToModel(Profile profile) {
    return shared_models.UserModel(
      id: profile.id,
      displayName: profile.displayName,
      email: profile.email,
      photoUrl: profile.photoUrl,
      bio: profile.bio,
      joinedSkills: profile.joinedSkills,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );
  }

  Profile _mapToEntity(shared_models.UserModel model) {
    return Profile(
      id: model.id,
      displayName: model.displayName,
      email: model.email,
      bio: model.bio,
      photoUrl: model.photoUrl,
      joinedSkills: model.joinedSkills,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}