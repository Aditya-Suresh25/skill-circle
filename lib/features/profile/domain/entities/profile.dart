import 'package:skill_circle_app/core/utils/appwrite_serialization.dart';

class Profile {
  const Profile({
    required this.id,
    required this.displayName,
    required this.email,
    this.bio,
    this.photoUrl,
    this.joinedSkills = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String displayName;
  final String email;
  final String? bio;
  final String? photoUrl;
  final List<String> joinedSkills;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Convert Appwrite document to Profile
  factory Profile.fromMap(Map<String, dynamic> data) {
    return Profile(
      id: data['id'] ?? '',
      displayName: data['displayName'] ?? data['name'] ?? '',
      email: data['email'] ?? '',
      bio: data['bio'],
      photoUrl: data['photoUrl'],
      joinedSkills: List<String>.from(data['joinedSkills'] ?? []),
      createdAt: parseAppwriteDate(data['createdAt']),
      updatedAt: parseAppwriteDate(data['updatedAt']),
    );
  }

  /// Convert Profile to Appwrite document
  Map<String, dynamic> toMap() => {
        'id': id,
        'displayName': displayName,
        'name': displayName,
        'email': email,
        'bio': bio,
        'photoUrl': photoUrl,
        'joinedSkills': joinedSkills,
        'createdAt': createdAt != null ? serializeAppwriteDate(createdAt!) : null,
        'updatedAt': updatedAt != null ? serializeAppwriteDate(updatedAt!) : null,
      };

  /// Create a copy with updated fields
  Profile copyWith({
    String? id,
    String? displayName,
    String? email,
    String? bio,
    String? photoUrl,
    List<String>? joinedSkills,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      joinedSkills: joinedSkills ?? this.joinedSkills,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}