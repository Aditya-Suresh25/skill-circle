import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart' as fb;
import 'package:skill_circle_app/features/posts/domain/entities/post.dart';
import 'package:skill_circle_app/features/storage/domain/storage_service.dart';

class FirebaseStorageService implements StorageService {
  FirebaseStorageService(this._storage);

  final fb.FirebaseStorage _storage;

  static const int maxImageBytes = 10 * 1024 * 1024; // 10 MB
  static const int maxPdfBytes = 50 * 1024 * 1024; // 50 MB

  @override
  Future<Attachment> uploadFile({required Uint8List bytes, required String filename, required String contentType, required String ownerId}) async {
    // Basic validations
    final lower = filename.toLowerCase();
    final isPdf = lower.endsWith('.pdf') || contentType == 'application/pdf';
    final isImage = contentType.startsWith('image/') || lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.gif');

    if (!isPdf && !isImage) {
      throw Exception('Unsupported file type');
    }

    if (isImage && bytes.lengthInBytes > maxImageBytes) {
      throw Exception('Image too large (max 10MB)');
    }

    if (isPdf && bytes.lengthInBytes > maxPdfBytes) {
      throw Exception('PDF too large (max 50MB)');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storagePath = 'posts/$ownerId/${timestamp}_$filename';
    final ref = _storage.ref().child(storagePath);

    const maxAttempts = 3;
    var attempt = 0;
    while (true) {
      try {
        await ref.putData(bytes, fb.SettableMetadata(contentType: contentType));
        final url = await ref.getDownloadURL();
        return Attachment(url: url, name: filename, size: bytes.lengthInBytes, contentType: contentType, storagePath: storagePath);
      } catch (e) {
        attempt++;
        if (attempt >= maxAttempts) {
          rethrow;
        }
        await Future.delayed(Duration(milliseconds: 200 * (1 << attempt)));
      }
    }
  }
}
