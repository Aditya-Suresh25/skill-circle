import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:skill_circle_app/core/constants/appwrite_storage_config.dart';
import 'package:skill_circle_app/core/utils/appwrite_file_url.dart';
import 'package:skill_circle_app/features/posts/domain/entities/post.dart';
import 'package:skill_circle_app/features/posts/domain/repositories/post_repository.dart';

class AppwritePostRepository implements PostRepository {
  AppwritePostRepository(
    this._databases,
    this._realtime,
    this._config,
  );

  final Databases _databases;
  final Realtime _realtime;
  final AppwriteStorageConfig _config;

  @override
  Stream<List<Post>> watchPosts(String circleId, {int limit = 50}) {
    return _watchPosts(circleId, limit: limit);
  }

  @override
  Future<PaginatedPosts> fetchPostsPage({required String circleId, required int limit, String? startAfterId}) async {
    final documents = await _listPostDocuments(circleId: circleId, limit: limit, startAfterId: startAfterId);
    final posts = documents.map(_toPost).toList(growable: false);
    final lastCursorId = documents.length == limit && documents.isNotEmpty ? documents.last.$id : null;
    return PaginatedPosts(posts: posts, lastCursorId: lastCursorId);
  }

  @override
  Future<void> createPost(Post post) async {
    await _databases.createDocument(
      databaseId: _config.databaseId,
      collectionId: _config.postsCollectionId,
      documentId: post.id.isEmpty ? ID.unique() : post.id,
      data: {
        ...post.toMap(),
      },
      permissions: [
        Permission.read(Role.any()),
        Permission.update(Role.users()),
        Permission.delete(Role.users()),
      ],
    );
  }

  @override
  Stream<List<String>> watchUserVotes(String userId) {
    return _watchUserVotes(userId);
  }

  @override
  Future<bool> toggleUpvote({required String postId, required String userId, required bool currentlyUpvoted}) async {
    final document = await _databases.getDocument(
      databaseId: _config.databaseId,
      collectionId: _config.postsCollectionId,
      documentId: postId,
    );

    final data = Map<String, dynamic>.from(document.data as Map);
    final upvotedBy = List<String>.from(data['upvotedBy'] ?? const <String>[]);

    if (upvotedBy.contains(userId)) {
      upvotedBy.remove(userId);
    } else {
      upvotedBy.add(userId);
    }

    await _databases.updateDocument(
      databaseId: _config.databaseId,
      collectionId: _config.postsCollectionId,
      documentId: postId,
      data: {
        'upvotedBy': upvotedBy,
        'upvotes': upvotedBy.length,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      },
    );

    return upvotedBy.contains(userId);
  }

  Stream<List<Post>> _watchPosts(String circleId, {required int limit}) {
    final controller = StreamController<List<Post>>.broadcast();
    StreamSubscription? subscription;

    Future<void> refresh() async {
      try {
        final documents = await _listPostDocuments(circleId: circleId, limit: limit);
        final posts = documents.map(_toPost).toList(growable: false);
        if (!controller.isClosed) {
          controller.add(posts);
        }
      } catch (error, stackTrace) {
        if (!controller.isClosed) {
          controller.addError(error, stackTrace);
        }
      }
    }

    controller.onListen = () {
      refresh();
      subscription = _realtime.subscribe([
        'databases.${_config.databaseId}.collections.${_config.postsCollectionId}.documents',
      ]).stream.listen((_) => refresh());
    };

    controller.onCancel = () async {
      await subscription?.cancel();
      await controller.close();
    };

    return controller.stream;
  }

  Stream<List<String>> _watchUserVotes(String userId) {
    final controller = StreamController<List<String>>.broadcast();
    StreamSubscription? subscription;

    Future<void> refresh() async {
      try {
        final documents = await _listPostDocuments(limit: 200);
        final votes = documents
            .map((document) => Map<String, dynamic>.from(document.data as Map))
            .where((data) => List<String>.from(data['upvotedBy'] ?? const <String>[]).contains(userId))
            .map((data) => data['postId'] as String? ?? data['post_id'] as String? ?? '')
            .where((id) => id.isNotEmpty)
            .toList(growable: false);
        if (!controller.isClosed) {
          controller.add(votes);
        }
      } catch (error, stackTrace) {
        if (!controller.isClosed) {
          controller.addError(error, stackTrace);
        }
      }
    }

    controller.onListen = () {
      refresh();
      subscription = _realtime.subscribe([
        'databases.${_config.databaseId}.collections.${_config.postsCollectionId}.documents',
      ]).stream.listen((_) => refresh());
    };

    controller.onCancel = () async {
      await subscription?.cancel();
      await controller.close();
    };

    return controller.stream;
  }

  Future<List<dynamic>> _listPostDocuments({
    String? circleId,
    required int limit,
    String? startAfterId,
  }) async {
    final queries = <String>[
      if (circleId != null) Query.equal('circle_id', circleId),
      Query.orderDesc('timestamp'),
      Query.limit(limit),
      if (startAfterId != null) Query.cursorAfter(startAfterId),
    ];

    final response = await _databases.listDocuments(
      databaseId: _config.databaseId,
      collectionId: _config.postsCollectionId,
      queries: queries,
    );

    return response.documents;
  }

  Post _toPost(dynamic document) {
    final data = Map<String, dynamic>.from(document.data as Map);
    return Post.fromMap(
      document.$id as String,
      data,
      attachmentUrlBuilder: (fileId) => buildAppwriteFileViewUrl(
        endpoint: _config.endpoint,
        bucketId: _config.bucketId,
        projectId: _config.projectId,
        fileId: fileId,
      ),
    );
  }
}
