import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:skill_circle_app/core/constants/appwrite_storage_config.dart';
import 'package:skill_circle_app/features/mentor/domain/entities/mentor.dart';
import 'package:skill_circle_app/features/mentor/domain/entities/task.dart';
import 'package:skill_circle_app/features/mentor/domain/entities/submission.dart';
import 'package:skill_circle_app/features/mentor/domain/repositories/mentor_repository.dart';
// appwrite_file_url is available in core/utils for building file view URLs if needed

class AppwriteMentorRepository implements MentorRepository {
  AppwriteMentorRepository(this._databases, this._realtime, this._config);

  final Databases _databases;
  final Realtime _realtime;
  final AppwriteStorageConfig _config;

  @override
  Future<void> createMentor(Mentor mentor) async {
    await _databases.createDocument(
      databaseId: _config.databaseId,
      collectionId: _config.usersCollectionId, // reuse users collection or create mentors collection
      documentId: mentor.id.isEmpty ? ID.unique() : mentor.id,
      data: mentor.toMap(),
    );
  }

  @override
  Future<Mentor?> getMentorByUserId(String userId) async {
    final res = await _databases.listDocuments(
      databaseId: _config.databaseId,
      collectionId: _config.usersCollectionId,
      queries: [Query.equal('user_id', userId), Query.limit(1)],
    );
    if (res.documents.isEmpty) return null;
    final doc = res.documents.first;
    return Mentor.fromMap(doc.$id, Map<String, dynamic>.from(doc.data as Map));
  }

  // Minimal implementations; flesh out as needed.
  @override
  Future<void> createTask(MentorTask task) async {
    await _databases.createDocument(
      databaseId: _config.databaseId,
      collectionId: _config.postsCollectionId, // choose tasks collection id in config
      documentId: task.id.isEmpty ? ID.unique() : task.id,
      data: task.toMap(),
      permissions: [
        Permission.read(Role.any()),
        Permission.update(Role.users()),
        Permission.delete(Role.users()),
      ],
    );
  }

  @override
  Future<void> updateTask(MentorTask task) async {
    await _databases.updateDocument(
      databaseId: _config.databaseId,
      collectionId: _config.postsCollectionId,
      documentId: task.id,
      data: task.toMap(),
    );
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _databases.deleteDocument(
      databaseId: _config.databaseId,
      collectionId: _config.postsCollectionId,
      documentId: taskId,
    );
  }

  @override
  Stream<List<MentorTask>> watchTasksForCircle(String circleId) {
    final controller = StreamController<List<MentorTask>>.broadcast();
    StreamSubscription? sub;

    Future<void> refresh() async {
      final response = await _databases.listDocuments(
        databaseId: _config.databaseId,
        collectionId: _config.postsCollectionId,
        queries: [Query.equal('circle_id', circleId), Query.orderAsc('order_index')],
      );
      final tasks = response.documents
          .map((d) => MentorTask.fromMap(d.$id, Map<String, dynamic>.from(d.data as Map)))
          .toList(growable: false);
      if (!controller.isClosed) controller.add(tasks);
    }

    controller.onListen = () {
      refresh();
      sub = _realtime
          .subscribe(['databases.${_config.databaseId}.collections.${_config.postsCollectionId}.documents']).stream
          .listen((_) => refresh());
    };

    controller.onCancel = () async {
      await sub?.cancel();
      await controller.close();
    };

    return controller.stream;
  }

  @override
  Future<void> createSubmission(TaskSubmission submission) async {
    await _databases.createDocument(
      databaseId: _config.databaseId,
      collectionId: _config.commentsCollectionId, // reuse or create submissions collection
      documentId: submission.id.isEmpty ? ID.unique() : submission.id,
      data: submission.toMap(),
    );
  }

  @override
  Stream<List<TaskSubmission>> watchSubmissionsForTask(String taskId) {
    final controller = StreamController<List<TaskSubmission>>.broadcast();
    StreamSubscription? sub;

    Future<void> refresh() async {
      final response = await _databases.listDocuments(
        databaseId: _config.databaseId,
        collectionId: _config.commentsCollectionId,
        queries: [Query.equal('task_id', taskId), Query.orderDesc('submitted_at')],
      );
      final items = response.documents
          .map((d) => TaskSubmission.fromMap(d.$id, Map<String, dynamic>.from(d.data as Map)))
          .toList(growable: false);
      if (!controller.isClosed) controller.add(items);
    }

    controller.onListen = () {
      refresh();
      sub = _realtime
          .subscribe(['databases.${_config.databaseId}.collections.${_config.commentsCollectionId}.documents']).stream
          .listen((_) => refresh());
    };

    controller.onCancel = () async {
      await sub?.cancel();
      await controller.close();
    };

    return controller.stream;
  }

  @override
  Future<void> gradeSubmission(String submissionId, String grade, String feedback) async {
    await _databases.updateDocument(
      databaseId: _config.databaseId,
      collectionId: _config.commentsCollectionId,
      documentId: submissionId,
      data: {'grade': grade, 'feedback': feedback, 'status': 'graded', 'graded_at': DateTime.now().toUtc().toIso8601String()},
    );
  }

  @override
  Future<Map<String, dynamic>> fetchUserProgress(String userId, String circleId) async {
    // Minimal placeholder: caller should implement progress aggregation logic
    return {};
  }

  @override
  Future<void> markTaskCompleted(String userId, String circleId, String taskId) async {
    // Minimal placeholder: implement progress document updates
    return;
  }
}
