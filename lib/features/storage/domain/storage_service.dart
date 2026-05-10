import 'dart:typed_data';
import 'package:skill_circle_app/features/posts/domain/entities/post.dart';

abstract class StorageService {
  /// Upload raw bytes and return an Attachment record.
  Future<Attachment> uploadFile({
    required Uint8List bytes,
    required String filename,
    required String contentType,
    required String ownerId,
  });

  /// Delete an uploaded file by its Appwrite file ID.
  Future<void> deleteFile({required String fileId});
}
