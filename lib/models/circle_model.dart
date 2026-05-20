import 'package:skill_circle_app/core/utils/appwrite_serialization.dart';

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

	factory CircleModel.fromMap(String id, Map<String, dynamic> map) {
		return CircleModel(
			circleId: map['circle_id'] as String? ?? map['circleId'] as String? ?? id,
			circleName: map['circle_name'] as String? ?? map['circleName'] as String? ?? map['title'] as String? ?? '',
			description: map['description'] as String? ?? '',
			createdBy: map['created_by'] as String? ?? map['createdBy'] as String? ?? '',
			createdAt: _parseTimestamp(map['created_at'] ?? map['createdAt']),
			memberCount: (map['member_count'] as num?)?.toInt() ?? (map['memberCount'] as num?)?.toInt() ?? 0,
			members: List<String>.from(map['members'] ?? const <String>[]),
			circleNameLower: map['circle_name_lower'] as String? ?? map['circleNameLower'] as String?,
		);
	}

	Map<String, dynamic> toMap() {
		return {
			'circle_id': circleId,
			'circle_name': circleName,
			'description': description,
			'created_by': createdBy,
			'created_at': createdAt != null ? serializeAppwriteDate(createdAt!) : null,
			'member_count': memberCount,
			'members': members,
			'circle_name_lower': circleNameLower ?? circleName.trim().toLowerCase(),
		};
	}

	static DateTime? _parseTimestamp(dynamic value) {
		if (value == null) return null;
		return parseAppwriteDate(value);
	}
}
