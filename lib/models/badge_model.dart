import 'package:cloud_firestore/cloud_firestore.dart';

class BadgeModel {
	const BadgeModel({
		required this.id,
		required this.title,
		required this.description,
		required this.iconKey,
		required this.isLocked,
		this.progress,
		this.earnedAt,
		this.category,
	});

	final String id;
	final String title;
	final String description;
	final String iconKey;
	final bool isLocked;
	final double? progress;
	final DateTime? earnedAt;
	final String? category;

	factory BadgeModel.fromMap(String id, Map<String, dynamic> map) {
		return BadgeModel(
			id: map['id'] as String? ?? id,
			title: map['title'] as String? ?? map['badgeTitle'] as String? ?? '',
			description: map['description'] as String? ?? '',
			iconKey: map['iconKey'] as String? ?? map['icon'] as String? ?? 'workspace_premium',
			isLocked: map['isLocked'] as bool? ?? map['locked'] as bool? ?? false,
			progress: (map['progress'] as num?)?.toDouble(),
			earnedAt: _parseTimestamp(map['earnedAt'] ?? map['earned_at']),
			category: map['category'] as String?,
		);
	}

	Map<String, dynamic> toMap() {
		return {
			'title': title,
			'description': description,
			'iconKey': iconKey,
			'isLocked': isLocked,
			'progress': progress,
			'earnedAt': earnedAt,
			'category': category,
		};
	}

	static DateTime? _parseTimestamp(dynamic value) {
		if (value == null) return null;
		if (value is Timestamp) return value.toDate();
		if (value is DateTime) return value;
		if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
		if (value is String) {
			return DateTime.tryParse(value);
		}
		return null;
	}
}
