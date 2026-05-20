import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/features/comments/domain/entities/comment.dart';
import 'package:skill_circle_app/features/comments/domain/repositories/comment_repository.dart';

class CommentsState {
  const CommentsState({
    required this.comments,
    this.lastCursorId,
    this.isLoading = false,
    this.hasMore = true,
  });

  final List<Comment> comments;
  final String? lastCursorId;
  final bool isLoading;
  final bool hasMore;

  CommentsState copyWith({
    List<Comment>? comments,
    String? lastCursorId,
    bool? isLoading,
    bool? hasMore,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      lastCursorId: lastCursorId ?? this.lastCursorId,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class CommentsController extends StateNotifier<CommentsState> {
  CommentsController(this._repository) : super(const CommentsState(comments: []));

  final CommentRepository _repository;
  StreamSubscription<List<Comment>>? _sub;

  void watchComments(String postId, {int limit = 50}) {
    _sub?.cancel();
    _sub = _repository.watchComments(postId, limit: limit).listen((incoming) {
      state = state.copyWith(comments: incoming);
    }, onError: (e) => throw e);
  }

  Future<void> loadMore(String postId, {int limit = 30}) async {
    if (!state.hasMore || state.isLoading) return;
    state = state.copyWith(isLoading: true);
    try {
      final page = await _repository.fetchCommentsPage(postId: postId, limit: limit, startAfterId: state.lastCursorId);
      final combined = List<Comment>.from(state.comments)..addAll(page.comments);
      state = state.copyWith(comments: combined, lastCursorId: page.lastCursorId, isLoading: false, hasMore: page.lastCursorId != null);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> addComment(Comment comment) async {
    if (comment.text.trim().isEmpty) throw Exception('Comment cannot be empty');
    try {
      await _repository.createComment(comment);
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
