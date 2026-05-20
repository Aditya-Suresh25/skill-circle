import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/features/skill_circles/domain/entities/skill_circle.dart';
import 'package:skill_circle_app/features/skill_circles/domain/repositories/skill_circle_repository.dart';

class SkillCirclesState {
  const SkillCirclesState({
    required this.circles,
    this.lastCursorId,
    this.isLoading = false,
    this.hasMore = true,
    this.query = '',
  });

  final List<SkillCircle> circles;
  final String? lastCursorId;
  final bool isLoading;
  final bool hasMore;
  final String query;

  SkillCirclesState copyWith({
    List<SkillCircle>? circles,
    String? lastCursorId,
    bool? isLoading,
    bool? hasMore,
    String? query,
  }) {
    return SkillCirclesState(
      circles: circles ?? this.circles,
      lastCursorId: lastCursorId ?? this.lastCursorId,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      query: query ?? this.query,
    );
  }
}

class SkillCirclesController extends StateNotifier<SkillCirclesState> {
  SkillCirclesController(this._repository)
      : super(const SkillCirclesState(circles: []));

  final SkillCircleRepository _repository;

  Future<void> loadInitial({int limit = 20}) async {
    state = state.copyWith(isLoading: true);
    try {
      final page = await _repository.fetchCirclesPage(limit: limit);
      state = state.copyWith(
        circles: page.circles,
        lastCursorId: page.lastCursorId,
        isLoading: false,
        hasMore: page.lastCursorId != null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> loadMore({int limit = 20}) async {
    if (!state.hasMore || state.isLoading) return;
    state = state.copyWith(isLoading: true);
    try {
      final page = await _repository.fetchCirclesPage(limit: limit, startAfterId: state.lastCursorId);
      final combined = List<SkillCircle>.from(state.circles)..addAll(page.circles);
      state = state.copyWith(
        circles: combined,
        lastCursorId: page.lastCursorId,
        isLoading: false,
        hasMore: page.lastCursorId != null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> refresh({int limit = 20}) async {
    await loadInitial(limit: limit);
  }

  Future<void> joinCircle(String circleId, String userId) async {
    try {
      await _repository.joinCircle(circleId, userId);
      // optimistic update locally
      state = state.copyWith(
        circles: state.circles.map((c) {
          if (c.id == circleId) {
            return SkillCircle(
              id: c.id,
              title: c.title,
              description: c.description,
              memberCount: c.memberCount + 1,
            );
          }
          return c;
        }).toList(growable: false),
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<void> leaveCircle(String circleId, String userId) async {
    try {
      await _repository.leaveCircle(circleId, userId);
      state = state.copyWith(
        circles: state.circles.map((c) {
          if (c.id == circleId) {
            return SkillCircle(
              id: c.id,
              title: c.title,
              description: c.description,
              memberCount: (c.memberCount - 1).clamp(0, 1 << 30),
            );
          }
          return c;
        }).toList(growable: false),
      );
    } catch (_) {
      rethrow;
    }
  }

  void updateQuery(String q) {
    state = state.copyWith(query: q);
  }
}
