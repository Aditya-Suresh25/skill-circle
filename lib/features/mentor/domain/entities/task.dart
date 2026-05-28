import 'package:skill_circle_app/features/posts/domain/entities/post.dart';

class MentorTask {
  const MentorTask({
    required this.id,
    required this.circleId,
    required this.mentorId,
    required this.title,
    required this.description,
    this.deadline,
    this.difficulty = 'Beginner',
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
      'order_index': orderIndex,
      'resources': resources.map((r) => r.toEncodedString()).toList(growable: false),
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}
