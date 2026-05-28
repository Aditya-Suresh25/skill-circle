class Mentor {
  const Mentor({
    required this.id,
    required this.userId,
    required this.displayName,
    this.bio,
    this.skills = const [],
    this.isActive = true,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String displayName;
  final String? bio;
  final List<String> skills;
  final bool isActive;
  final DateTime createdAt;

  factory Mentor.fromMap(String id, Map<String, dynamic> data) {
    return Mentor(
      id: id,
      userId: data['user_id'] as String? ?? '',
      displayName: data['display_name'] as String? ?? '',
      bio: data['bio'] as String?,
      skills: (data['skills'] as List<dynamic>?)?.cast<String>() ?? const [],
      isActive: data['is_active'] as bool? ?? true,
      createdAt: DateTime.tryParse(data['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'display_name': displayName,
      if (bio != null) 'bio': bio,
      'skills': skills,
      'is_active': isActive,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}
