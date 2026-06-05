class SkillCircle {
  const SkillCircle({
    required this.circleId,
    required this.circleName,
    required this.description,
    required this.createdBy,
    this.createdAt,
    this.memberCount = 0,
    this.members = const [],
    this.imageUrl,
    this.bannerUrl,
  });

  final String circleId;
  final String circleName;
  final String description;
  final String createdBy;
  final DateTime? createdAt;
  final int memberCount;
  final List<String> members;
  final String? imageUrl;
  final String? bannerUrl;

  factory SkillCircle.fromMap(String id, Map<String, dynamic> map) {
    return SkillCircle(
      circleId: id,
      circleName: map['circle_name'] as String? ?? map['circleName'] as String? ?? 'Unnamed Circle',
      description: map['description'] as String? ?? '',
      createdBy: map['created_by'] as String? ?? map['createdBy'] as String? ?? '',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? map['createdAt'] as String? ?? ''),
      memberCount: (map['member_count'] as num?)?.toInt() ?? (map['memberCount'] as num?)?.toInt() ?? 0,
      members: List<String>.from(map['members'] ?? const []),
      imageUrl: map['imageUrl'] as String? ?? map['image_url'] as String?,
      bannerUrl: map['bannerUrl'] as String? ?? map['banner_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'circle_id': circleId,
      'circle_name': circleName,
      'description': description,
      'created_by': createdBy,
      'created_at': createdAt?.toUtc().toIso8601String() ?? DateTime.now().toUtc().toIso8601String(),
      'member_count': memberCount,
      'members': members,
      'circle_name_lower': circleName.toLowerCase(),
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (bannerUrl != null) 'bannerUrl': bannerUrl,
    };
  }
}
