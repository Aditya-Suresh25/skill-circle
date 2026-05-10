import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_circle_app/features/skill_circles/domain/entities/skill_circle.dart';

class PaginatedCircleModels {
  PaginatedCircleModels({required this.circles, this.lastDocument});

  final List<SkillCircle> circles;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
}

class CircleAlreadyExistsException implements Exception {
  CircleAlreadyExistsException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class CircleRemoteDataSource {
  Stream<List<SkillCircle>> watchCircles({int limit = 50});

  Future<PaginatedCircleModels> fetchCirclesPage({
    required int limit,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  });

  Future<void> createCircle({
    required String name,
    required String description,
    required String userId,
  });

  Future<void> joinCircle(String circleId, String userId);

  Future<void> leaveCircle(String circleId, String userId);

  Stream<List<SkillCircle>> watchJoinedCircles(String userId, {int limit = 50});
}

class FirebaseCircleRemoteDataSource implements CircleRemoteDataSource {
  FirebaseCircleRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection => _firestore.collection('SkillCircles');

  CollectionReference<Map<String, dynamic>> get _usersCollection => _firestore.collection('users');

  @override
  Stream<List<SkillCircle>> watchCircles({int limit = 50}) {
    return _collection.snapshots().map((snapshot) {
      final circles = snapshot.docs
          .map((doc) => SkillCircle.fromMap(doc.id, doc.data()))
          .toList(growable: false)
        ..sort((a, b) => b.id.compareTo(a.id));

      return circles.take(limit).toList(growable: false);
    });
  }

  @override
  Future<PaginatedCircleModels> fetchCirclesPage({
    required int limit,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    final snapshot = await _collection.get();
    final allCircles = snapshot.docs
        .map((doc) => SkillCircle.fromMap(doc.id, doc.data()))
        .toList(growable: false)
      ..sort((a, b) => b.id.compareTo(a.id));

    var startIndex = 0;
    if (startAfter != null) {
      final index = snapshot.docs.indexWhere((doc) => doc.id == startAfter.id);
      if (index >= 0) {
        startIndex = index + 1;
      }
    }

    final pageCircles = allCircles.skip(startIndex).take(limit).toList(growable: false);
    final lastDocument = pageCircles.isEmpty || startIndex + pageCircles.length >= allCircles.length
        ? null
        : snapshot.docs.firstWhere((doc) => doc.id == pageCircles.last.id);

    return PaginatedCircleModels(circles: pageCircles, lastDocument: lastDocument);
  }

  @override
  Future<void> createCircle({
    required String name,
    required String description,
    required String userId,
  }) async {
    final circleName = name.trim();
    final normalizedName = circleName.toLowerCase();
    final existing = await _collection
        .where('circle_name_lower', isEqualTo: normalizedName)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw CircleAlreadyExistsException('A circle with that name already exists.');
    }

    final circleRef = _collection.doc();
    final circle = SkillCircle(
      id: circleRef.id,
      title: circleName,
      description: description.trim(),
      memberCount: 1,
      members: [userId],
      createdBy: userId,
    );

    final batch = _firestore.batch();
    batch.set(circleRef, {
      'circle_id': circle.id,
      'circleId': circle.id,
      'circle_name': circle.title,
      'circleName': circle.title,
      'title': circle.title,
      'description': circle.description,
      'created_by': circle.createdBy,
      'createdBy': circle.createdBy,
      'created_at': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'member_count': circle.memberCount,
      'memberCount': circle.memberCount,
      'members': circle.members,
      'circle_name_lower': circle.title.trim().toLowerCase(),
      'circleNameLower': circle.title.trim().toLowerCase(),
    });
    batch.set(
      _usersCollection.doc(userId),
      {
        'joinedSkills': FieldValue.arrayUnion([circleName]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  @override
  Future<void> joinCircle(String circleId, String userId) async {
    final ref = _collection.doc(circleId);
    await _firestore.runTransaction((tx) async {
      final snapshot = await tx.get(ref);
      if (!snapshot.exists) {
        throw Exception('Circle not found');
      }

      final data = snapshot.data() ?? <String, dynamic>{};
      final members = List<String>.from(data['members'] ?? const <String>[]);
      if (members.contains(userId)) {
        return;
      }

      final circleName = (data['circle_name'] as String?) ?? (data['title'] as String?) ?? '';

      tx.update(ref, {
        'members': FieldValue.arrayUnion([userId]),
        'member_count': FieldValue.increment(1),
      });
      tx.set(
        _usersCollection.doc(userId),
        {
          'joinedSkills': FieldValue.arrayUnion([circleName]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  @override
  Future<void> leaveCircle(String circleId, String userId) async {
    final ref = _collection.doc(circleId);
    await _firestore.runTransaction((tx) async {
      final snapshot = await tx.get(ref);
      if (!snapshot.exists) {
        throw Exception('Circle not found');
      }

      final data = snapshot.data() ?? <String, dynamic>{};
      final members = List<String>.from(data['members'] ?? const <String>[]);
      if (!members.contains(userId)) {
        return;
      }

      final circleName = (data['circle_name'] as String?) ?? (data['title'] as String?) ?? '';

      tx.update(ref, {
        'members': FieldValue.arrayRemove([userId]),
        'member_count': FieldValue.increment(-1),
      });
      tx.set(
        _usersCollection.doc(userId),
        {
          'joinedSkills': FieldValue.arrayRemove([circleName]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  @override
  Stream<List<SkillCircle>> watchJoinedCircles(String userId, {int limit = 50}) {
    return _collection
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          final circles = snapshot.docs
              .map((doc) => SkillCircle.fromMap(doc.id, doc.data()))
              .toList(growable: false)
            ..sort((a, b) => b.id.compareTo(a.id));
          return circles.take(limit).toList(growable: false);
        });
  }
}