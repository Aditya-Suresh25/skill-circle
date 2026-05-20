import '../entities/comment.dart';

class PaginatedComments {
  PaginatedComments({required this.comments, this.lastCursorId});

  final List<Comment> comments;
  final String? lastCursorId;
}

abstract class CommentRepository {
  /// Real-time stream of comments for a post (newest first)
  Stream<List<Comment>> watchComments(String postId, {int limit = 50});

  /// Fetch a page of comments for pagination
  Future<PaginatedComments> fetchCommentsPage({required String postId, required int limit, String? startAfterId});

  /// Create a new comment
  Future<void> createComment(Comment comment);
}
