import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_circle_app/features/posts/domain/entities/post.dart';
import 'package:skill_circle_app/features/posts/domain/repositories/post_repository.dart';

class FirebasePostRepository implements PostRepository {
  FirebasePostRepository(this._firestore);

  final FirebaseFirestore _firestore;

  static const String _postsCollection = 'posts';

  @override
  Stream<List<Post>> watchPosts(String circleId, {int limit = 50}) {
    // Some posts in DB may have been written with different field naming
    // (e.g. 'circleId' vs 'circle_id'). Firestore cannot OR across fields
    // easily, so as a fallback we listen to recent posts and filter client-side
    // to catch posts regardless of field naming. We still limit to `limit`.
    final q = _firestore.collection(_postsCollection).orderBy('timestamp', descending: true).limit(limit);
    return q.snapshots().map((snap) {
      final all = snap.docs.map((d) => Post.fromMap(d.id, d.data())).toList();
      final filtered = all.where((p) => p.circleId == circleId).toList(growable: false);
      return filtered;
    }).handleError((e) => throw _handleError('Failed to watch posts', e));
  }

  @override
  Future<PaginatedPosts> fetchPostsPage({required String circleId, required int limit, DocumentSnapshot<Map<String, dynamic>>? startAfter}) async {
    try {
      Query<Map<String, dynamic>> q = _firestore.collection(_postsCollection).orderBy('timestamp', descending: true).limit(limit);

      if (startAfter != null) {
        q = q.startAfterDocument(startAfter);
      }

      final snap = await q.get();
      final posts = snap.docs.map((d) => Post.fromMap(d.id, d.data())).where((p) => p.circleId == circleId).toList(growable: false);
      final last = snap.docs.isNotEmpty ? snap.docs.last as DocumentSnapshot<Map<String, dynamic>> : null;

      return PaginatedPosts(posts: posts, lastDocument: last);
    } catch (e) {
      throw _handleError('Failed to fetch posts', e);
    }
  }

  @override
  Future<void> createPost(Post post) async {
    // Basic retry logic with exponential backoff
    const maxAttempts = 3;
    var attempt = 0;
    while (true) {
      try {
        final ref = _firestore.collection(_postsCollection).doc();
        await ref.set(post.toMap());
        return;
      } catch (e) {
        attempt++;
        if (attempt >= maxAttempts) {
          throw _handleError('Failed to create post', e);
        }
        await Future.delayed(Duration(milliseconds: 200 * (1 << attempt)));
      }
    }
  }

  @override
  Stream<List<String>> watchUserVotes(String userId) {
    final votesCollection = _firestore.collection('postVotes');
    return votesCollection
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()['post_id'] as String).toList())
        .handleError((e) => throw _handleError('Failed to watch user votes', e));
  }

  @override
  Future<bool> toggleUpvote({required String postId, required String userId, required bool currentlyUpvoted}) async {
    final voteDocId = '${postId}_$userId';
    final postRef = _firestore.collection(_postsCollection).doc(postId);
    final voteRef = _firestore.collection('postVotes').doc(voteDocId);

    try {
      return _firestore.runTransaction<bool>((tx) async {
        final voteSnap = await tx.get(voteRef);

        final exists = voteSnap.exists;

        if (exists && !currentlyUpvoted) {
          // Inconsistent state: vote exists but client thought not upvoted -> keep it
          return true;
        }

        if (!exists && currentlyUpvoted) {
          // Inconsistent: client thought upvoted but vote missing -> create
          tx.set(voteRef, {'user_id': userId, 'post_id': postId, 'createdAt': FieldValue.serverTimestamp()});
          tx.update(postRef, {'upvotes': FieldValue.increment(1)});
          return true;
        }

        if (exists) {
          // remove vote
          tx.delete(voteRef);
          tx.update(postRef, {'upvotes': FieldValue.increment(-1)});
          return false;
        } else {
          // create vote
          tx.set(voteRef, {'user_id': userId, 'post_id': postId, 'createdAt': FieldValue.serverTimestamp()});
          tx.update(postRef, {'upvotes': FieldValue.increment(1)});
          return true;
        }
      });
    } catch (e) {
      throw _handleError('Failed to toggle upvote', e);
    }
  }

  Exception _handleError(String message, dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return Exception('You do not have permission to write posts');
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

