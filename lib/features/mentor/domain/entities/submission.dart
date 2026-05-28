import 'package:skill_circle_app/features/posts/domain/entities/post.dart';

class TaskSubmission {
  const TaskSubmission({
    required this.id,
    required this.taskId,
    required this.userId,
    this.content,
    this.attachments = const [],
    required this.submittedAt,
    this.status = 'pending',
    this.grade,
    this.feedback,
  });

  final String id;
  final String taskId;
  final String userId;
  final String? content;
  final List<Attachment> attachments;
  final DateTime submittedAt;
  final String status;
  final String? grade;
  final String? feedback;

  factory TaskSubmission.fromMap(String id, Map<String, dynamic> data) {
    return TaskSubmission(
      id: id,
      taskId: data['task_id'] as String? ?? '',
      userId: data['user_id'] as String? ?? '',
      content: data['content'] as String?,
      attachments: Attachment.fromDynamicList(data['attachments']),
      submittedAt: DateTime.tryParse(data['submitted_at'] as String? ?? '') ?? DateTime.now(),
      status: data['status'] as String? ?? 'pending',
      grade: data['grade'] as String?,
      feedback: data['feedback'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'task_id': taskId,
      'user_id': userId,
      if (content != null) 'content': content,
      'attachments': attachments.map((a) => a.toEncodedString()).toList(growable: false),
      'submitted_at': submittedAt.toUtc().toIso8601String(),
      'status': status,
      if (grade != null) 'grade': grade,
      if (feedback != null) 'feedback': feedback,
    };
  }
}
