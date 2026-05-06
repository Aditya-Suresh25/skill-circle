import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/post.dart';

class PaginatedPosts {
  PaginatedPosts({required this.posts, this.lastDocument});

  final List<Post> posts;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
}

abstract class PostRepository {
  /// Real-time stream of posts for a circle (newest first)
  Stream<List<Post>> watchPosts(String circleId, {int limit = 50});

  /// Fetch a page of posts for lazy loading (oldest after `startAfter`)
  Future<PaginatedPosts> fetchPostsPage({required String circleId, required int limit, DocumentSnapshot<Map<String, dynamic>>? startAfter});

  /// Create a new post
  Future<void> createPost(Post post);

  /// Stream of post ids the user has upvoted
  Stream<List<String>> watchUserVotes(String userId);

  /// Toggle upvote for a post by a user. Pass current state to allow server
  /// to resolve and return the new state (true = upvoted).
  Future<bool> toggleUpvote({required String postId, required String userId, required bool currentlyUpvoted});
}
