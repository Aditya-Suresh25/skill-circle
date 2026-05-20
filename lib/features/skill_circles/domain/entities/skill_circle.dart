import 'package:skill_circle_app/core/utils/appwrite_serialization.dart';

class SkillCircle {
  const SkillCircle({
    required this.id,
    required this.title,
    required this.description,
    required this.memberCount,
    this.members = const [],
    this.createdBy,
    this.imageUrl,
    this.bannerUrl,
  });

  final String id;
  final String title;
  final String description;
  final int memberCount;
  final List<String> members;
  final String? createdBy;
  final String? imageUrl;
  final String? bannerUrl;

  factory SkillCircle.fromMap(String id, Map<String, dynamic> data) {
    return SkillCircle(
      id: data['id'] as String? ?? data['circleId'] as String? ?? data['circle_id'] as String? ?? id,
      title: data['circle_name'] as String? ?? data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      memberCount: (data['member_count'] as num?)?.toInt() ?? (data['memberCount'] as num?)?.toInt() ?? 0,
      members: List<String>.from(data['members'] ?? const <String>[]),
      createdBy: data['created_by'] as String? ?? data['createdBy'] as String?,
      imageUrl: data['imageUrl'] as String?,
      bannerUrl: data['bannerUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'circle_id': id,
      'circle_name': title,
      'description': description,
      'member_count': memberCount,
      'members': members,
      'created_by': createdBy,
      'updatedAt': serializeAppwriteDate(DateTime.now()),
    };
    if (imageUrl != null) map['imageUrl'] = imageUrl;
    if (bannerUrl != null) map['bannerUrl'] = bannerUrl;
    return map;
  }
}