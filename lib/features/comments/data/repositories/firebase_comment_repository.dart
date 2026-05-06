import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_circle_app/features/comments/domain/entities/comment.dart';
import 'package:skill_circle_app/features/comments/domain/repositories/comment_repository.dart';

class FirebaseCommentRepository implements CommentRepository {
  FirebaseCommentRepository(this._firestore);

  final FirebaseFirestore _firestore;

  static const String _commentsCollection = 'comments';

  @override
  Stream<List<Comment>> watchComments(String postId, {int limit = 50}) {
    return _firestore
        .collection(_commentsCollection)
        .where('post_id', isEqualTo: postId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Comment.fromMap(d.id, d.data())).toList())
        .handleError((e) => throw _handleError('Failed to watch comments', e));
  }

  @override
  Future<PaginatedComments> fetchCommentsPage({required String postId, required int limit, DocumentSnapshot<Map<String, dynamic>>? startAfter}) async {
    try {
      Query<Map<String, dynamic>> q = _firestore
          .collection(_commentsCollection)
          .where('post_id', isEqualTo: postId)
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (startAfter != null) q = q.startAfterDocument(startAfter);

      final snap = await q.get();
      final comments = snap.docs.map((d) => Comment.fromMap(d.id, d.data())).toList();
      final last = snap.docs.isNotEmpty ? snap.docs.last as DocumentSnapshot<Map<String, dynamic>> : null;
      return PaginatedComments(comments: comments, lastDocument: last);
    } catch (e) {
      throw _handleError('Failed to fetch comments', e);
    }
  }

  @override
  Future<void> createComment(Comment comment) async {
    if (comment.text.trim().isEmpty) throw Exception('Comment cannot be empty');
    try {
      final ref = _firestore.collection(_commentsCollection).doc();
      await ref.set(comment.toMap());
    } catch (e) {
      throw _handleError('Failed to create comment', e);
    }
  }

  Exception _handleError(String message, dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return Exception('You do not have permission to access comments');
        case 'unavailable':
          return Exception('Service unavailable. Please try again later');
        case 'network-request-failed':
          return Exception('Network error. Please check your connection');
        default:
          return Exception('$message: ${error.message}');
      }
    }

    return Exception('$message: ${error.toString()}');
  }
}
