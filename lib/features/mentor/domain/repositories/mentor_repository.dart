import 'dart:async';

import 'package:skill_circle_app/features/mentor/domain/entities/mentor.dart';
import 'package:skill_circle_app/features/mentor/domain/entities/task.dart';
import 'package:skill_circle_app/features/mentor/domain/entities/submission.dart';

abstract class MentorRepository {
  Future<void> createMentor(Mentor mentor);
  Future<Mentor?> getMentorByUserId(String userId);

  Future<void> createTask(MentorTask task);
  Future<void> updateTask(MentorTask task);
  Future<void> deleteTask(String taskId);
  Stream<List<MentorTask>> watchTasksForCircle(String circleId);

  Future<void> createSubmission(TaskSubmission submission);
  Stream<List<TaskSubmission>> watchSubmissionsForTask(String taskId);
  Future<void> gradeSubmission(String submissionId, String grade, String feedback);

  Future<Map<String, dynamic>> fetchUserProgress(String userId, String circleId);
  Future<void> markTaskCompleted(String userId, String circleId, String taskId);
}
