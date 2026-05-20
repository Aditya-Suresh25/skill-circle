import 'dart:async';
import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:skill_circle_app/core/constants/appwrite_storage_config.dart';
import 'package:skill_circle_app/features/profile/domain/entities/profile.dart';
import 'package:skill_circle_app/features/profile/domain/exceptions/profile_failure.dart';
import 'package:skill_circle_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:skill_circle_app/features/storage/domain/storage_service.dart';

class AppwriteProfileRepository implements ProfileRepository {
  AppwriteProfileRepository(
    this._databases,
    this._realtime,
    this._storageService,
    this._config,
  );

  final Databases _databases;
  final Realtime _realtime;
  final StorageService _storageService;
  final AppwriteStorageConfig _config;

  @override
  Future<Profile> getUserProfile(String userId) async {
    try {
      final document = await _databases.getDocument(
        databaseId: _config.databaseId,
        collectionId: _config.usersCollectionId,
        documentId: userId,
      );
      return Profile.fromMap(Map<String, dynamic>.from(document.data as Map));
    } on AppwriteException catch (error) {
      throw _handleError('Failed to fetch profile', error);
    }
  }

  @override
  Future<void> createUserProfile(Profile profile) async {
    try {
      await _databases.createDocument(
        databaseId: _config.databaseId,
        collectionId: _config.usersCollectionId,
        documentId: profile.id,
        data: profile.toMap(),
        permissions: [
          Permission.read(Role.any()),
          Permission.update(Role.user(profile.id)),
          Permission.delete(Role.user(profile.id)),
        ],
      );
    } on AppwriteException catch (error) {
      if (error.code == 409) {
        await saveProfile(profile);
        return;
      }
      throw _handleError('Failed to create profile', error);
    }
  }

  @override
  Stream<Profile?> watchProfile(String userId) {
    final controller = StreamController<Profile?>.broadcast();
    StreamSubscription? subscription;

    Future<void> refresh() async {
      try {
        final profile = await getUserProfile(userId);
        if (!controller.isClosed) {
          controller.add(profile);
        }
      } catch (_) {
        if (!controller.isClosed) {
          controller.add(null);
        }
      }
    }

    controller.onListen = () {
      refresh();
      subscription = _realtime.subscribe([
        'databases.${_config.databaseId}.collections.${_config.usersCollectionId}.documents',
      ]).stream.listen((_) => refresh());
    };

    controller.onCancel = () async {
      await subscription?.cancel();
      await controller.close();
    };

    return controller.stream;
  }

  @override
  Future<void> saveProfile(Profile profile) async {
    try {
      await _databases.updateDocument(
        databaseId: _config.databaseId,
        collectionId: _config.usersCollectionId,
        documentId: profile.id,
        data: profile.toMap(),
      );
    } on AppwriteException catch (error) {
      throw _handleError('Failed to save profile', error);
    }
  }

  @override
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = DateTime.now().toUtc().toIso8601String();
      await _databases.updateDocument(
        databaseId: _config.databaseId,
        collectionId: _config.usersCollectionId,
        documentId: userId,
        data: updates,
      );
    } on AppwriteException catch (error) {
      throw _handleError('Failed to update profile', error);
    }
  }

  @override
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = _imageExtension(imageFile.path);
      final filename = '${userId}_$timestamp$extension';
      final contentType = _imageContentType(extension);

      final uploaded = await _storageService.uploadFile(
        bytes: await imageFile.readAsBytes(),
        filename: filename,
        contentType: contentType,
        ownerId: userId,
      );

      final downloadUrl = uploaded.url;
      await updateUserProfile(userId, {'photoUrl': downloadUrl});
      return downloadUrl;
    } catch (error) {
      throw _handleError('Failed to upload profile image', error);
    }
  }

  @override
  Future<void> deleteProfileImage(String userId) async {
    try {
      final profile = await getUserProfile(userId);
      if (profile.photoUrl == null || profile.photoUrl!.isEmpty) {
        return;
      }

      final fileId = _extractFileIdFromUrl(profile.photoUrl!);
      if (fileId != null) {
        await _storageService.deleteFile(fileId: fileId);
      }

      await updateUserProfile(userId, {'photoUrl': null});
    } catch (error) {
      throw _handleError('Failed to delete profile image', error);
    }
  }

  Exception _handleError(String message, dynamic error) {
    if (error is AppwriteException) {
      switch (error.code) {
        case 404:
          return ProfileFailure('Profile not found', code: 'not-found');
        case 401:
        case 403:
          return ProfileFailure('You do not have permission to access this profile', code: 'forbidden');
        case 503:
          return ProfileFailure('Service unavailable. Please try again later', code: 'unavailable');
        case 408:
          return ProfileFailure('Network error. Please check your connection', code: 'timeout');
        default:
          return ProfileFailure('$message: ${error.message}', code: error.type);
      }
    }

    if (error is SocketException) {
      return ProfileFailure('Network error. Please check your connection', code: 'network');
    }

    if (error is TimeoutException) {
      return ProfileFailure('Operation timed out. Please try again', code: 'timeout');
    }

    return ProfileFailure('$message: ${error.toString()}');
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
}
