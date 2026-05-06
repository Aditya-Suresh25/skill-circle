import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/features/posts/domain/entities/post.dart';
import 'package:skill_circle_app/features/posts/domain/repositories/post_repository.dart';

class PostsState {
  const PostsState({
    required this.posts,
    this.lastDocument,
    this.isLoading = false,
    this.hasMore = true,
    this.upvotedPostIds = const {},
    this.pendingUpvoteIds = const {},
  });

  final List<Post> posts;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final bool isLoading;
  final bool hasMore;
  final Set<String> upvotedPostIds;
  final Set<String> pendingUpvoteIds;

  PostsState copyWith({
    List<Post>? posts,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
    bool? isLoading,
    bool? hasMore,
    Set<String>? upvotedPostIds,
    Set<String>? pendingUpvoteIds,
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      lastDocument: lastDocument ?? this.lastDocument,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      upvotedPostIds: upvotedPostIds ?? this.upvotedPostIds,
      pendingUpvoteIds: pendingUpvoteIds ?? this.pendingUpvoteIds,
    );
  }
}

class PostsController extends StateNotifier<PostsState> {
  PostsController(this._repository) : super(const PostsState(posts: []));

  final PostRepository _repository;
  StreamSubscription<List<Post>>? _sub;
  StreamSubscription<List<String>>? _votesSub;

  // Simple in-memory cooldown map per user id
  final Map<String, DateTime> _lastPostAt = {};
  static const Duration postCooldown = Duration(seconds: 30);

  void watchPosts(String circleId, {int limit = 30, String? userId}) {
    _sub?.cancel();
    _votesSub?.cancel();
    _sub = _repository.watchPosts(circleId, limit: limit).listen((incoming) {
      state = state.copyWith(posts: incoming);
    }, onError: (e) {
      // propagate error by rethrowing
      throw e;
    });

    if (userId != null) {
      _votesSub = _repository.watchUserVotes(userId).listen((ids) {
        state = state.copyWith(upvotedPostIds: ids.toSet());
      }, onError: (e) {
        // ignore vote watch errors for now
      });
    }
  }

  Future<void> loadMore(String circleId, {int limit = 20}) async {
    if (!state.hasMore || state.isLoading) return;
    state = state.copyWith(isLoading: true);
    try {
      final page = await _repository.fetchPostsPage(circleId: circleId, limit: limit, startAfter: state.lastDocument);
      final combined = List<Post>.from(state.posts)..addAll(page.posts);
      state = state.copyWith(
        posts: combined,
        lastDocument: page.lastDocument,
        isLoading: false,
        hasMore: page.lastDocument != null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> createPost(Post post) async {
    // Validate
    if (post.content.trim().isEmpty) {
      throw Exception('Post content cannot be empty');
    }

    final lastAt = _lastPostAt[post.userId];
    if (lastAt != null && DateTime.now().difference(lastAt) < postCooldown) {
      final remaining = postCooldown - DateTime.now().difference(lastAt);
      throw Exception('Please wait ${remaining.inSeconds}s before posting again');
    }

    try {
      await _repository.createPost(post);
      _lastPostAt[post.userId] = DateTime.now();
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle upvote with optimistic update.
  Future<void> toggleUpvote(String postId, String userId) async {
    final currentlyUpvoted = state.upvotedPostIds.contains(postId);

    // Prevent duplicate taps
    if (state.pendingUpvoteIds.contains(postId)) return;

    // Optimistic update: adjust local post list and upvoted set
    final updatedPosts = state.posts.map((p) {
      if (p.id == postId) {
        final newCount = currentlyUpvoted ? (p.upvotes - 1).clamp(0, 1 << 30) : p.upvotes + 1;
        return Post(id: p.id, userId: p.userId, circleId: p.circleId, content: p.content, timestamp: p.timestamp, upvotes: newCount, attachments: p.attachments);
      }
      return p;
    }).toList(growable: false);

    final newUpvoted = Set<String>.from(state.upvotedPostIds);
    if (currentlyUpvoted) {
      newUpvoted.remove(postId);
    } else {
      newUpvoted.add(postId);
    }

    final newPending = Set<String>.from(state.pendingUpvoteIds)..add(postId);

    state = state.copyWith(posts: updatedPosts, upvotedPostIds: newUpvoted, pendingUpvoteIds: newPending);

    try {
      await _repository.toggleUpvote(postId: postId, userId: userId, currentlyUpvoted: currentlyUpvoted);

      // Clear pending flag; server state result will be reflected by vote watcher eventually
      final clearedPending = Set<String>.from(state.pendingUpvoteIds)..remove(postId);
      state = state.copyWith(pendingUpvoteIds: clearedPending);
    } catch (e) {
      // Revert optimistic update on error
      final revertedPosts = state.posts.map((p) {
        if (p.id == postId) {
          final origCount = currentlyUpvoted ? p.upvotes + 1 : (p.upvotes - 1).clamp(0, 1 << 30);
          return Post(id: p.id, userId: p.userId, circleId: p.circleId, content: p.content, timestamp: p.timestamp, upvotes: origCount, attachments: p.attachments);
        }
        return p;
      }).toList(growable: false);

      final revertedUpvoted = Set<String>.from(state.upvotedPostIds);
      if (currentlyUpvoted) {
        revertedUpvoted.add(postId);
      } else {
        revertedUpvoted.remove(postId);
      }

      final clearedPending = Set<String>.from(state.pendingUpvoteIds)..remove(postId);
      state = state.copyWith(posts: revertedPosts, upvotedPostIds: revertedUpvoted, pendingUpvoteIds: clearedPending);
      rethrow;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _votesSub?.cancel();
    super.dispose();
  }
}
