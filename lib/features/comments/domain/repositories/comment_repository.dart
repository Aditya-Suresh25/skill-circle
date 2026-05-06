import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/comment.dart';

class PaginatedComments {
  PaginatedComments({required this.comments, this.lastDocument});

  final List<Comment> comments;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
}

abstract class CommentRepository {
  /// Real-time stream of comments for a post (newest first)
  Stream<List<Comment>> watchComments(String postId, {int limit = 50});

  /// Fetch a page of comments for pagination
  Future<PaginatedComments> fetchCommentsPage({required String postId, required int limit, DocumentSnapshot<Map<String, dynamic>>? startAfter});

  /// Create a new comment
  Future<void> createComment(Comment comment);
}
