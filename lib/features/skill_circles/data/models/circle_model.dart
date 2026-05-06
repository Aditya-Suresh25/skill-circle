import 'package:cloud_firestore/cloud_firestore.dart';

class CircleModel {
  const CircleModel({
    required this.circleId,
    required this.circleName,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    required this.memberCount,
    this.members = const [],
    this.circleNameLower,
  });

  final String circleId;
  final String circleName;
  final String description;
  final String createdBy;
  final DateTime? createdAt;
  final int memberCount;
  final List<String> members;
  final String? circleNameLower;

  factory CircleModel.fromJson(String id, Map<String, dynamic> json) {
    return CircleModel(
      circleId: (json['circle_id'] as String?) ?? id,
      circleName: (json['circle_name'] as String?) ?? (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      createdBy: (json['created_by'] as String?) ?? (json['createdBy'] as String?) ?? '',
      createdAt: (json['created_at'] as Timestamp?)?.toDate() ?? (json['createdAt'] as Timestamp?)?.toDate(),
      memberCount: (json['member_count'] as num?)?.toInt() ?? (json['memberCount'] as num?)?.toInt() ?? 0,
      members: List<String>.from(json['members'] ?? const <String>[]),
      circleNameLower: json['circle_name_lower'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'circle_id': circleId,
      'circle_name': circleName,
      'description': description,
      'created_by': createdBy,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
      'member_count': memberCount,
      'members': members,
      'circle_name_lower': circleNameLower ?? circleName.trim().toLowerCase(),
    };
  }
}