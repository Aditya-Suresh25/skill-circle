import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_circle_app/features/skill_circles/data/models/circle_model.dart';

class PaginatedCircleModels {
  PaginatedCircleModels({required this.circles, this.lastDocument});

  final List<CircleModel> circles;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
}

class CircleAlreadyExistsException implements Exception {
  CircleAlreadyExistsException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class CircleRemoteDataSource {
  Stream<List<CircleModel>> watchCircles({int limit = 50});

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

  Stream<List<CircleModel>> watchJoinedCircles(String userId, {int limit = 50});
}

class FirebaseCircleRemoteDataSource implements CircleRemoteDataSource {
  FirebaseCircleRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection => _firestore.collection('SkillCircles');

  CollectionReference<Map<String, dynamic>> get _usersCollection => _firestore.collection('users');

  @override
  Stream<List<CircleModel>> watchCircles({int limit = 50}) {
    return _collection
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CircleModel.fromJson(doc.id, doc.data()))
            .toList(growable: false));
  }

  @override
  Future<PaginatedCircleModels> fetchCirclesPage({
    required int limit,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _collection.orderBy('created_at', descending: true).limit(limit);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final circles = snapshot.docs
        .map((doc) => CircleModel.fromJson(doc.id, doc.data()))
        .toList(growable: false);
    final last = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    return PaginatedCircleModels(circles: circles, lastDocument: last);
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
    final circle = CircleModel(
      circleId: circleRef.id,
      circleName: circleName,
      description: description.trim(),
      createdBy: userId,
      createdAt: null,
      memberCount: 1,
      members: [userId],
      circleNameLower: normalizedName,
    );

    final batch = _firestore.batch();
    batch.set(circleRef, circle.toJson());
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
  Stream<List<CircleModel>> watchJoinedCircles(String userId, {int limit = 50}) {
    return _collection
        .where('members', arrayContains: userId)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CircleModel.fromJson(doc.id, doc.data()))
            .toList(growable: false));
  }
}