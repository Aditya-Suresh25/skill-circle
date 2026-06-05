import 'post.dart';

class MentorTask {
  const MentorTask({
    required this.id,
    required this.circleId,
    required this.mentorId,
    required this.title,
    required this.description,
    this.deadline,
    this.difficulty = 'Beginner',
    this.category = 'General',
    this.estimatedMinutes = 30,
    this.points = 10,
    this.status = 'not_started',
    this.assignmentScope = 'all_mentees',
    this.assignedUserIds = const [],
    this.assignedCircleIds = const [],
    this.orderIndex = 0,
    this.resources = const [],
    required this.createdAt,
  });

  final String id;
  final String circleId;
  final String mentorId;
  final String title;
  final String description;
  final DateTime? deadline;
  final String difficulty;
  final String category;
  final int estimatedMinutes;
  final int points;
  final String status;
  final String assignmentScope;
  final List<String> assignedUserIds;
  final List<String> assignedCircleIds;
  final int orderIndex;
  final List<Attachment> resources;
  final DateTime createdAt;

  factory MentorTask.fromMap(String id, Map<String, dynamic> data) {
    return MentorTask(
      id: id,
      circleId: data['circle_id'] as String? ?? data['circleId'] as String? ?? '',
      mentorId: data['mentor_id'] as String? ?? data['mentorId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      deadline: DateTime.tryParse(data['deadline'] as String? ?? ''),
      difficulty: data['difficulty'] as String? ?? 'Beginner',
      category: data['category'] as String? ?? 'General',
      estimatedMinutes: (data['estimated_minutes'] as num?)?.toInt() ?? (data['estimatedMinutes'] as num?)?.toInt() ?? 30,
      points: (data['points'] as num?)?.toInt() ?? (data['xp_reward'] as num?)?.toInt() ?? 10,
      status: data['status'] as String? ?? 'not_started',
      assignmentScope: data['assignment_scope'] as String? ?? data['assignmentScope'] as String? ?? 'all_mentees',
      assignedUserIds: List<String>.from(data['assigned_user_ids'] ?? data['assignedUserIds'] ?? const <String>[]),
      assignedCircleIds: List<String>.from(data['assigned_circle_ids'] ?? data['assignedCircleIds'] ?? const <String>[]),
      orderIndex: (data['order_index'] as num?)?.toInt() ?? (data['orderIndex'] as num?)?.toInt() ?? 0,
      resources: Attachment.fromDynamicList(data['resources']),
      createdAt: DateTime.tryParse(data['created_at'] as String? ?? data['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': id, // map to postId field when reusing posts collection
      'circle_id': circleId,
      'mentor_id': mentorId,
      'title': title,
      'post_content': description, // map to post_content in posts collection
      'deadline': deadline?.toUtc().toIso8601String(),
      'difficulty': difficulty,
      'category': category,
      'estimated_minutes': estimatedMinutes,
      'points': points,
      'status': status,
      'assignment_scope': assignmentScope,
      'assigned_user_ids': assignedUserIds,
      'assigned_circle_ids': assignedCircleIds,
      'order_index': orderIndex,
      'resources': resources.map((r) => r.toEncodedString()).toList(growable: false),
      'created_at': createdAt.toUtc().toIso8601String(),
      'timestamp': createdAt.toUtc().toIso8601String(), // map to timestamp in posts collection
      'user_id': mentorId,
      'username': 'Mentor',
    };
  }
}

class TaskSubmission {
  const TaskSubmission({
    required this.id,
    required this.taskId,
    required this.userId,
    this.userName, // local convenience field
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
  final String? userName;
  final String? content;
  final List<Attachment> attachments;
  final DateTime submittedAt;
  final String status;
  final String? grade;
  final String? feedback;

  factory TaskSubmission.fromMap(String id, Map<String, dynamic> data) {
    return TaskSubmission(
      id: id,
      taskId: data['task_id'] as String? ?? data['taskId'] as String? ?? '',
      userId: data['user_id'] as String? ?? data['userId'] as String? ?? '',
      userName: data['username'] as String? ?? data['userName'] as String?,
      content: data['content'] as String? ?? data['comment_text'] as String?,
      attachments: Attachment.fromDynamicList(data['attachments']),
      submittedAt: DateTime.tryParse(data['submitted_at'] as String? ?? data['submittedAt'] as String? ?? '') ?? DateTime.now(),
      status: data['status'] as String? ?? 'pending',
      grade: data['grade'] as String?,
      feedback: data['feedback'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'commentId': id, // map to commentId when reusing comments collection
      'post_id': taskId, // map to post_id when reusing comments collection
      'task_id': taskId,
      'user_id': userId,
      'username': userName ?? 'Learner',
      'comment_text': content ?? 'Task Submission', // map to comment_text in comments collection
      'content': content,
      'attachments': attachments.map((a) => a.toEncodedString()).toList(growable: false),
      'submitted_at': submittedAt.toUtc().toIso8601String(),
      'timestamp': submittedAt.toUtc().toIso8601String(), // map to timestamp in comments collection
      'status': status,
      if (grade != null) 'grade': grade,
      if (feedback != null) 'feedback': feedback,
    };
  }

  TaskSubmission copyWith({String? userName}) {
    return TaskSubmission(
      id: id,
      taskId: taskId,
      userId: userId,
      userName: userName ?? this.userName,
      content: content,
      attachments: attachments,
      submittedAt: submittedAt,
      status: status,
      grade: grade,
      feedback: feedback,
    );
  }
}
