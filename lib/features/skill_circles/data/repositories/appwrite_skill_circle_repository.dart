import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:skill_circle_app/core/constants/appwrite_storage_config.dart';
import 'package:skill_circle_app/features/skill_circles/domain/entities/skill_circle.dart';
import 'package:skill_circle_app/features/skill_circles/domain/repositories/skill_circle_repository.dart';

class AppwriteSkillCircleRepository implements SkillCircleRepository {
  AppwriteSkillCircleRepository(
    this._databases,
    this._realtime,
    this._account,
    this._config,
  );

  final Databases _databases;
  final Realtime _realtime;
  final Account _account;
  final AppwriteStorageConfig _config;

  @override
  Stream<List<SkillCircle>> watchSkillCircles({int limit = 50}) {
    return _watchCircles(limit: limit, filter: (_) => true);
  }

  @override
  Future<PaginatedSkillCircles> fetchCirclesPage({required int limit, String? startAfterId}) async {
    final documents = await _listCircleDocuments(limit: limit, startAfterId: startAfterId);
    final circles = documents.map(_toCircle).toList(growable: false);
    final lastCursorId = documents.length == limit && documents.isNotEmpty ? documents.last.$id : null;
    return PaginatedSkillCircles(circles: circles, lastCursorId: lastCursorId);
  }

  @override
  Future<void> createCircle({
    required String name,
    required String description,
    String? imageUrl,
    String? bannerUrl,
  }) async {
    final userId = await _currentUserId();
    final circleName = name.trim();
    final normalizedName = circleName.toLowerCase();

    final existing = await _databases.listDocuments(
      databaseId: _config.databaseId,
      collectionId: _config.skillCirclesCollectionId,
      queries: [
        Query.equal('circle_name_lower', normalizedName),
        Query.limit(1),
      ],
    );

    if (existing.total > 0) {
      throw Exception('A circle with that name already exists.');
    }

    final now = DateTime.now().toUtc().toIso8601String();
    final circleId = ID.unique();
    final data = <String, dynamic>{
      'circle_id': circleId,
      'circle_name': circleName,
      'circle_name_lower': normalizedName,
      'description': description.trim(),
      'created_by': userId,
      'created_at': now,
      'member_count': 1,
      'members': [userId],
    };
    if (imageUrl != null) data['imageUrl'] = imageUrl;
    if (bannerUrl != null) data['bannerUrl'] = bannerUrl;

    await _databases.createDocument(
      databaseId: _config.databaseId,
      collectionId: _config.skillCirclesCollectionId,
      documentId: circleId,
      data: data,
      permissions: [
        Permission.read(Role.any()),
        Permission.update(Role.users()),
        Permission.delete(Role.users()),
      ],
    );

    await _addJoinedSkill(userId, circleName);
  }

  @override
  Future<void> saveSkillCircle(SkillCircle circle) async {
    await _databases.updateDocument(
      databaseId: _config.databaseId,
      collectionId: _config.skillCirclesCollectionId,
      documentId: circle.id,
      data: circle.toMap(),
    );
  }

  @override
  Future<void> joinCircle(String circleId, String userId) async {
    final circle = await _getCircle(circleId);
    if (circle == null) {
      throw Exception('Circle not found');
    }

    final members = List<String>.from(circle['members'] ?? const <String>[]);
    if (members.contains(userId)) {
      return;
    }

    final circleName = circle['circle_name'] as String? ?? circle['title'] as String? ?? '';
    members.add(userId);

    await _databases.updateDocument(
      databaseId: _config.databaseId,
      collectionId: _config.skillCirclesCollectionId,
      documentId: circleId,
      data: {
        'members': members,
        'member_count': members.length,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      },
    );

    await _addJoinedSkill(userId, circleName);
  }

  @override
  Future<void> leaveCircle(String circleId, String userId) async {
    final circle = await _getCircle(circleId);
    if (circle == null) {
      throw Exception('Circle not found');
    }

    final members = List<String>.from(circle['members'] ?? const <String>[]);
    if (!members.contains(userId)) {
      return;
    }

    final circleName = circle['circle_name'] as String? ?? circle['title'] as String? ?? '';
    members.remove(userId);

    await _databases.updateDocument(
      databaseId: _config.databaseId,
      collectionId: _config.skillCirclesCollectionId,
      documentId: circleId,
      data: {
        'members': members,
        'member_count': members.length,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      },
    );

    await _removeJoinedSkill(userId, circleName);
  }

  @override
  Stream<List<SkillCircle>> watchJoinedCircles(String userId, {int limit = 50}) {
    return _watchCircles(
      limit: limit,
      filter: (circle) => circle.members.contains(userId),
    );
  }

  Stream<List<SkillCircle>> _watchCircles({
    required int limit,
    required bool Function(SkillCircle circle) filter,
  }) {
    final controller = StreamController<List<SkillCircle>>.broadcast();
    StreamSubscription? subscription;

    Future<void> refresh() async {
      try {
        final documents = await _listCircleDocuments(limit: limit);
        final circles = documents.map(_toCircle).where(filter).take(limit).toList(growable: false);
        if (!controller.isClosed) {
          controller.add(circles);
        }
      } catch (error, stackTrace) {
        if (!controller.isClosed) {
          controller.addError(error, stackTrace);
        }
      }
    }

    RealtimeSubscription? _sub;
    controller.onListen = () async {
      await refresh();
      _sub = _realtime.subscribe([
        'databases.${_config.databaseId}.collections.${_config.skillCirclesCollectionId}.documents',
      ]);
      subscription = _sub?.stream.listen((_) => refresh());
    };

    controller.onCancel = () async {
      await subscription?.cancel();
      await controller.close();
    };

    return controller.stream;
  }

  Future<List<dynamic>> _listCircleDocuments({int limit = 50, String? startAfterId}) async {
    final queries = <String>[
      Query.orderDesc('created_at'),
      Query.limit(limit),
      if (startAfterId != null) Query.cursorAfter(startAfterId),
    ];

    final response = await _databases.listDocuments(
      databaseId: _config.databaseId,
      collectionId: _config.skillCirclesCollectionId,
      queries: queries,
    );

    return response.documents;
  }

  SkillCircle _toCircle(dynamic document) {
    final data = Map<String, dynamic>.from(document.data as Map);
    return SkillCircle.fromMap(document.$id as String, data);
  }

  Future<Map<String, dynamic>?> _getCircle(String circleId) async {
    try {
      final document = await _databases.getDocument(
        databaseId: _config.databaseId,
        collectionId: _config.skillCirclesCollectionId,
        documentId: circleId,
      );
      return Map<String, dynamic>.from(document.data as Map);
    } catch (_) {
      return null;
    }
  }

  Future<String> _currentUserId() async {
    final user = await _account.get();
    return user.$id;
  }

  Future<void> _addJoinedSkill(String userId, String circleName) async {
    if (circleName.trim().isEmpty) return;

    final profile = await _databases.getDocument(
      databaseId: _config.databaseId,
      collectionId: _config.usersCollectionId,
      documentId: userId,
    );
    final joinedSkills = List<String>.from((profile.data as Map)['joinedSkills'] ?? const <String>[]);
    if (!joinedSkills.contains(circleName)) {
      joinedSkills.add(circleName);
    }

    await _databases.updateDocument(
      databaseId: _config.databaseId,
      collectionId: _config.usersCollectionId,
      documentId: userId,
      data: {
        'joinedSkills': joinedSkills,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      },
    );
  }

  Future<void> _removeJoinedSkill(String userId, String circleName) async {
    if (circleName.trim().isEmpty) return;

    final profile = await _databases.getDocument(
      databaseId: _config.databaseId,
      collectionId: _config.usersCollectionId,
      documentId: userId,
    );
    final joinedSkills = List<String>.from((profile.data as Map)['joinedSkills'] ?? const <String>[]);
    joinedSkills.remove(circleName);

    await _databases.updateDocument(
      databaseId: _config.databaseId,
      collectionId: _config.usersCollectionId,
      documentId: userId,
      data: {
        'joinedSkills': joinedSkills,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      },
    );
  }
}