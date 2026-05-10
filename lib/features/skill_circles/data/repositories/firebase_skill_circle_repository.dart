import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skill_circle_app/features/skill_circles/data/datasources/circle_remote_data_source.dart';
import 'package:skill_circle_app/features/skill_circles/domain/entities/skill_circle.dart';
import 'package:skill_circle_app/features/skill_circles/domain/repositories/skill_circle_repository.dart';

class FirebaseSkillCircleRepository implements SkillCircleRepository {
  FirebaseSkillCircleRepository(this._firestore)
      : _remoteDataSource = FirebaseCircleRemoteDataSource(_firestore);

  final FirebaseFirestore _firestore;
  final CircleRemoteDataSource _remoteDataSource;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('SkillCircles');

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  Stream<List<SkillCircle>> watchSkillCircles({int limit = 50}) {
    return _remoteDataSource.watchCircles(limit: limit).map(
          (circles) => circles
              .map(
                (circle) => SkillCircle(
                  id: circle.id,
                  title: circle.title,
                  description: circle.description,
                  memberCount: circle.memberCount,
                  members: circle.members,
                  createdBy: circle.createdBy,
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Future<PaginatedSkillCircles> fetchCirclesPage({required int limit, DocumentSnapshot<Map<String, dynamic>>? startAfter}) async {
    final page = await _remoteDataSource.fetchCirclesPage(limit: limit, startAfter: startAfter);
    final circles = page.circles
        .map(
          (circle) => SkillCircle(
            id: circle.id,
            title: circle.title,
            description: circle.description,
            memberCount: circle.memberCount,
            members: circle.members,
            createdBy: circle.createdBy,
          ),
        )
        .toList(growable: false);
    return PaginatedSkillCircles(circles: circles, lastDocument: page.lastDocument);
  }

  @override
  Future<void> createCircle(String name, String description) async {
    final user = _currentUser;
    if (user == null) {
      throw StateError('You must be signed in to create a circle.');
    }

    await _remoteDataSource.createCircle(
      name: name,
      description: description,
      userId: user.uid,
    );
  }

  @override
  Future<void> saveSkillCircle(SkillCircle circle) {
    return _collection.doc(circle.id).set(circle.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> joinCircle(String circleId, String userId) async {
    await _remoteDataSource.joinCircle(circleId, userId);
  }

  @override
  Future<void> leaveCircle(String circleId, String userId) async {
    await _remoteDataSource.leaveCircle(circleId, userId);
  }

  @override
  Stream<List<SkillCircle>> watchJoinedCircles(String userId, {int limit = 50}) {
    return _remoteDataSource.watchJoinedCircles(userId, limit: limit).map(
          (circles) => circles
              .map(
                (circle) => SkillCircle(
                  id: circle.id,
                  title: circle.title,
                  description: circle.description,
                  memberCount: circle.memberCount,
                  members: circle.members,
                  createdBy: circle.createdBy,
                ),
              )
              .toList(growable: false),
        );
  }
}