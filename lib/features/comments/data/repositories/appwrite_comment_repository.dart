import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:skill_circle_app/core/constants/appwrite_storage_config.dart';
import 'package:skill_circle_app/features/comments/domain/entities/comment.dart';
import 'package:skill_circle_app/features/comments/domain/repositories/comment_repository.dart';

class AppwriteCommentRepository implements CommentRepository {
  AppwriteCommentRepository(
    this._databases,
    this._realtime,
    this._config,
  );

  final Databases _databases;
  final Realtime _realtime;
  final AppwriteStorageConfig _config;

  @override
  Stream<List<Comment>> watchComments(String postId, {int limit = 50}) {
    return _watchComments(postId, limit: limit);
  }

  @override
  Future<PaginatedComments> fetchCommentsPage({required String postId, required int limit, String? startAfterId}) async {
    final documents = await _listCommentDocuments(postId: postId, limit: limit, startAfterId: startAfterId);
    final comments = documents.map(_toComment).toList(growable: false);
    final lastCursorId = documents.length == limit && documents.isNotEmpty ? documents.last.$id : null;
    return PaginatedComments(comments: comments, lastCursorId: lastCursorId);
  }

  @override
  Future<void> createComment(Comment comment) async {
    if (comment.text.trim().isEmpty) {
      throw Exception('Comment cannot be empty');
    }

    await _databases.createDocument(
      databaseId: _config.databaseId,
      collectionId: _config.commentsCollectionId,
      documentId: comment.id.isEmpty ? ID.unique() : comment.id,
      data: comment.toMap(),
      permissions: [
        Permission.read(Role.any()),
        Permission.update(Role.users()),
        Permission.delete(Role.users()),
      ],
    );
  }

  Stream<List<Comment>> _watchComments(String postId, {required int limit}) {
    final controller = StreamController<List<Comment>>.broadcast();
    StreamSubscription? subscription;

    Future<void> refresh() async {
      try {
        final documents = await _listCommentDocuments(postId: postId, limit: limit);
        final comments = documents.map(_toComment).toList(growable: false);
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
      subscription = _realtime.subscribe([
        'databases.${_config.databaseId}.collections.${_config.commentsCollectionId}.documents',
      ]).stream.listen((_) => refresh());
    };

    controller.onCancel = () async {
      await subscription?.cancel();
      await controller.close();
    };

    return controller.stream;
  }

  Future<List<dynamic>> _listCommentDocuments({
    required String postId,
    required int limit,
    String? startAfterId,
  }) async {
    final queries = <String>[
      Query.equal('post_id', postId),
      Query.orderDesc('timestamp'),
      Query.limit(limit),
      if (startAfterId != null) Query.cursorAfter(startAfterId),
    ];

    final response = await _databases.listDocuments(
      databaseId: _config.databaseId,
      collectionId: _config.commentsCollectionId,
      queries: queries,
    );

    return response.documents;
  }

  Comment _toComment(dynamic document) {
    final data = Map<String, dynamic>.from(document.data as Map);
    return Comment.fromMap(document.$id as String, data);
  }
}
