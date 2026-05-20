import 'package:skill_circle_app/core/utils/appwrite_serialization.dart';

/// User profile entity stored in Firestore
class UserProfile {
  const UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    this.photoUrl,
    this.joinedSkills = const [],
    this.createdAt,
    this.updatedAt,
    this.bio,
  });

  final String userId;
  final String name;
  final String email;
  final String? photoUrl;
  final List<String> joinedSkills;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? bio;

  /// Convert document data to UserProfile
  factory UserProfile.fromMap(String id, Map<String, dynamic> data) {
    return UserProfile(
      userId: data['id'] as String? ?? id,
      name: data['name'] as String? ?? data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? data['photo_url'] as String?,
      joinedSkills: List<String>.from(data['joinedSkills'] ?? data['joined_skills'] ?? const <String>[]),
      createdAt: parseAppwriteDate(data['createdAt'] ?? data['created_at']),
      updatedAt: parseAppwriteDate(data['updatedAt'] ?? data['updated_at']),
      bio: data['bio'] as String?,
    );
  }

  /// Convert UserProfile to document data
  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'joinedSkills': joinedSkills,
        'createdAt': createdAt != null ? serializeAppwriteDate(createdAt!) : null,
        'updatedAt': serializeAppwriteDate(updatedAt ?? DateTime.now()),
        'bio': bio,
      };

  /// Create a copy with updated fields
  UserProfile copyWith({
    String? userId,
    String? name,
    String? email,
    String? photoUrl,
    List<String>? joinedSkills,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? bio,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      joinedSkills: joinedSkills ?? this.joinedSkills,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bio: bio ?? this.bio,
    );
  }
}
