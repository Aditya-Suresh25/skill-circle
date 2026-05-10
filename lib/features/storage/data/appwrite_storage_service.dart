import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:skill_circle_app/features/posts/domain/entities/post.dart';
import 'package:skill_circle_app/features/storage/domain/storage_service.dart';

class AppwriteStorageService implements StorageService {
  AppwriteStorageService({
    required Storage storage,
    required String bucketId,
    required String endpoint,
    required String projectId,
  })  : _storage = storage,
        _bucketId = bucketId,
        _endpoint = endpoint,
        _projectId = projectId;

  final Storage _storage;
  final String _bucketId;
  final String _endpoint;
  final String _projectId;

  static const int maxImageBytes = 10 * 1024 * 1024; // 10 MB
  static const int maxVideoBytes = 200 * 1024 * 1024; // 200 MB
  static const int maxFileBytes = 50 * 1024 * 1024; // 50 MB

  @override
  Future<Attachment> uploadFile({
    required Uint8List bytes,
    required String filename,
    required String contentType,
    required String ownerId,
  }) async {
    final safeContentType =
        contentType.trim().isEmpty ? 'application/octet-stream' : contentType;

    final lowerContentType = safeContentType.toLowerCase();
    if (lowerContentType.startsWith('image/') &&
        bytes.lengthInBytes > maxImageBytes) {
      throw Exception('Image too large (max 10MB)');
    }

    if (lowerContentType.startsWith('video/') &&
        bytes.lengthInBytes > maxVideoBytes) {
      throw Exception('Video too large (max 200MB)');
    }

    if (!lowerContentType.startsWith('image/') &&
        !lowerContentType.startsWith('video/') &&
        bytes.lengthInBytes > maxFileBytes) {
      throw Exception('File too large (max 50MB)');
    }

    const maxAttempts = 3;
    var attempt = 0;
    while (true) {
      try {
        final file = await _storage.createFile(
          bucketId: _bucketId,
          fileId: ID.unique(),
          file: InputFile.fromBytes(
            bytes: bytes,
            filename: filename,
            contentType: safeContentType,
          ),
          permissions: [
            Permission.read(Role.any()),
          ],
        );

        final fileId = file.$id;
        final publicUrl = _buildFileViewUrl(fileId);
        return Attachment(
          fileId: fileId,
          url: publicUrl,
          name: filename,
          size: bytes.lengthInBytes,
          contentType: safeContentType,
          storagePath: '$ownerId/$fileId',
        );
      } catch (e) {
        attempt++;
        if (attempt >= maxAttempts) {
          rethrow;
        }
        await Future.delayed(Duration(milliseconds: 200 * (1 << attempt)));
      }
    }
  }

  String _buildFileViewUrl(String fileId) {
    final base = _endpoint.endsWith('/')
        ? _endpoint.substring(0, _endpoint.length - 1)
        : _endpoint;
    final encodedBucketId = Uri.encodeComponent(_bucketId);
    final encodedFileId = Uri.encodeComponent(fileId);
    final encodedProjectId = Uri.encodeQueryComponent(_projectId);

    return '$base/storage/buckets/$encodedBucketId/files/$encodedFileId/view?project=$encodedProjectId';
  }

  @override
  Future<void> deleteFile({required String fileId}) async {
    await _storage.deleteFile(
      bucketId: _bucketId,
      fileId: fileId,
    );
  }
}