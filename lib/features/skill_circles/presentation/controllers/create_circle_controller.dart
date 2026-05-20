import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/features/skill_circles/domain/repositories/skill_circle_repository.dart';
import 'package:skill_circle_app/features/storage/domain/storage_service.dart';

class CreateCircleController extends StateNotifier<AsyncValue<void>> {
  CreateCircleController(this._repository, this._storageService, this._ownerId)
      : super(const AsyncValue.data(null));

  final SkillCircleRepository _repository;
  final StorageService _storageService;
  final String _ownerId;

  Future<void> createCircle({
    required String name,
    required String description,
    PlatformFile? pfpFile,
    PlatformFile? bannerFile,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (_ownerId.isEmpty) {
        throw StateError('You must be signed in to create a skill circle');
      }

      String? imageUrl;
      String? bannerUrl;

      if (pfpFile != null && pfpFile.bytes != null) {
        final attachment = await _storageService.uploadFile(
          bytes: pfpFile.bytes!,
          filename: pfpFile.name,
          contentType: _contentTypeFromFileName(pfpFile.name),
          ownerId: _ownerId,
        );
        imageUrl = attachment.url;
      }

      if (bannerFile != null && bannerFile.bytes != null) {
        final attachment = await _storageService.uploadFile(
          bytes: bannerFile.bytes!,
          filename: bannerFile.name,
          contentType: _contentTypeFromFileName(bannerFile.name),
          ownerId: _ownerId,
        );
        bannerUrl = attachment.url;
      }

      await _repository.createCircle(
        name: name,
        description: description,
        imageUrl: imageUrl,
        bannerUrl: bannerUrl,
      );
    });
  }

  String _contentTypeFromFileName(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'application/octet-stream';
    }
  }
}