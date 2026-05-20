import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/providers/appwrite_storage_providers.dart';
import 'package:skill_circle_app/features/comments/data/repositories/appwrite_comment_repository.dart';
import 'package:skill_circle_app/models/comment_model.dart' as shared_models;
import 'package:skill_circle_app/features/comments/domain/repositories/comment_repository.dart';

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return AppwriteCommentRepository(
    ref.read(appwriteDatabasesProvider),
    ref.read(appwriteRealtimeProvider),
    ref.read(appwriteStorageConfigProvider),
  );
});

final recentCommentsProvider = StreamProvider<List<shared_models.CommentModel>>((ref) {
  final databases = ref.watch(appwriteDatabasesProvider);
  final realtime = ref.watch(appwriteRealtimeProvider);
  final config = ref.watch(appwriteStorageConfigProvider);

  final controller = StreamController<List<shared_models.CommentModel>>.broadcast();
  StreamSubscription? subscription;

  Future<void> refresh() async {
    try {
      final response = await databases.listDocuments(
        databaseId: config.databaseId,
        collectionId: config.commentsCollectionId,
        queries: [
          Query.orderDesc('timestamp'),
          Query.limit(50),
        ],
      );
      
      final comments = response.documents
          .map((document) => shared_models.CommentModel.fromMap(document.$id, Map<String, dynamic>.from(document.data as Map)))
          .toList(growable: false);
      
      if (!controller.isClosed) {
        controller.add(comments);
      }
    } catch (error, stackTrace) {
      if (!controller.isClosed) {
        controller.addError(error, stackTrace);
      }
    }
  }

  controller.onListen = () {
    refresh();
    subscription = realtime.subscribe([
      'databases.${config.databaseId}.collections.${config.commentsCollectionId}.documents',
    ]).stream.listen((_) => refresh());
  };

  controller.onCancel = () async {
    await subscription?.cancel();
    await controller.close();
  };

  ref.onDispose(() {
    subscription?.cancel();
    controller.close();
  });

  return controller.stream;
});
