import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
	const UserModel({
		required this.id,
		required this.displayName,
		required this.email,
		this.photoUrl,
		this.bio,
		this.joinedSkills = const [],
		this.createdAt,
		this.updatedAt,
	});

	final String id;
	final String displayName;
	final String email;
	final String? photoUrl;
	final String? bio;
	final List<String> joinedSkills;
	final DateTime? createdAt;
	final DateTime? updatedAt;

	factory UserModel.fromMap(String id, Map<String, dynamic> map) {
		return UserModel(
			id: map['id'] as String? ?? id,
			displayName: map['displayName'] as String? ?? map['display_name'] as String? ?? '',
			email: map['email'] as String? ?? '',
			photoUrl: map['photoUrl'] as String? ?? map['photo_url'] as String?,
			bio: map['bio'] as String?,
			joinedSkills: List<String>.from(map['joinedSkills'] ?? const <String>[]),
			createdAt: _parseTimestamp(map['createdAt'] ?? map['created_at']),
			updatedAt: _parseTimestamp(map['updatedAt'] ?? map['updated_at']),
		);
	}

	Map<String, dynamic> toMap() {
		return {
			'displayName': displayName,
			'email': email,
			'photoUrl': photoUrl,
			'bio': bio,
			'joinedSkills': joinedSkills,
			'createdAt': createdAt ?? FieldValue.serverTimestamp(),
			'updatedAt': FieldValue.serverTimestamp(),
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
