class SkillCircle {
  const SkillCircle({
    required this.id,
    required this.title,
    required this.description,
    required this.memberCount,
    this.members = const [],
    this.createdBy,
  });

  final String id;
  final String title;
  final String description;
  final int memberCount;
  final List<String> members;
  final String? createdBy;

  factory SkillCircle.fromMap(String id, Map<String, dynamic> data) {
    return SkillCircle(
      id: id,
      title: data['circle_name'] as String? ?? data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      memberCount: (data['member_count'] as num?)?.toInt() ?? (data['memberCount'] as num?)?.toInt() ?? 0,
      members: List<String>.from(data['members'] ?? const <String>[]),
      createdBy: data['created_by'] as String? ?? data['createdBy'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'circle_name': title,
      'description': description,
      'member_count': memberCount,
      'members': members,
      'created_by': createdBy,
    };
  }
}