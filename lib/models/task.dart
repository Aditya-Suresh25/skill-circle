import 'dart:convert';
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
      circleId: data['circle_id'] as String? ?? '',
      mentorId: data['mentor_id'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      deadline: DateTime.tryParse(data['deadline'] as String? ?? ''),
      difficulty: data['difficulty'] as String? ?? 'Beginner',
      category: data['category'] as String? ?? 'General',
      estimatedMinutes: (data['estimated_minutes'] as num?)?.toInt() ?? 30,
      points: (data['points'] as num?)?.toInt() ?? 10,
      status: data['status'] as String? ?? 'not_started',
      assignmentScope: data['assignment_scope'] as String? ?? 'all_mentees',
      assignedUserIds: List<String>.from(data['assigned_user_ids'] ?? []),
      assignedCircleIds: List<String>.from(data['assigned_circle_ids'] ?? []),
      orderIndex: (data['order_index'] as num?)?.toInt() ?? 0,
      resources: Attachment.fromDynamicList(data['resources']),
      createdAt: DateTime.tryParse(data['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'circle_id': circleId,
      'mentor_id': mentorId,
      'title': title,
      'description': description,
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
    };
  }

  MentorTask copyWith({
    String? title,
    String? description,
    DateTime? deadline,
    String? difficulty,
    String? category,
    int? estimatedMinutes,
    int? points,
    String? status,
    String? assignmentScope,
    List<String>? assignedUserIds,
    List<String>? assignedCircleIds,
    int? orderIndex,
    List<Attachment>? resources,
  }) {
    return MentorTask(
      id: id,
      circleId: circleId,
      mentorId: mentorId,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      points: points ?? this.points,
      status: status ?? this.status,
      assignmentScope: assignmentScope ?? this.assignmentScope,
      assignedUserIds: assignedUserIds ?? this.assignedUserIds,
      assignedCircleIds: assignedCircleIds ?? this.assignedCircleIds,
      orderIndex: orderIndex ?? this.orderIndex,
      resources: resources ?? this.resources,
      createdAt: createdAt,
    );
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
      taskId: data['task_id'] as String? ?? '',
      userId: data['user_id'] as String? ?? '',
      userName: data['username'] as String?,
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
      'username': userName ?? 'Learner',
      'content': content,
      'attachments': attachments.map((a) => a.toEncodedString()).toList(growable: false),
      'submitted_at': submittedAt.toUtc().toIso8601String(),
      'status': status,
      if (grade != null) 'grade': grade,
      if (feedback != null) 'feedback': feedback,
    };
  }

  TaskSubmission copyWith({
    String? userName,
    String? status,
    String? grade,
    String? feedback,
  }) {
    return TaskSubmission(
      id: id,
      taskId: taskId,
      userId: userId,
      userName: userName ?? this.userName,
      content: content,
      attachments: attachments,
      submittedAt: submittedAt,
      status: status ?? this.status,
      grade: grade ?? this.grade,
      feedback: feedback ?? this.feedback,
    );
  }
}
