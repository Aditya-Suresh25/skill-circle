import 'package:cloud_firestore/cloud_firestore.dart';

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

  /// Convert Firestore document to UserProfile
  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return UserProfile(
      userId: snapshot.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      joinedSkills: List<String>.from(data['joinedSkills'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      bio: data['bio'],
    );
  }

  /// Convert UserProfile to Firestore document
  Map<String, dynamic> toFirestore() => {
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'joinedSkills': joinedSkills,
        'createdAt': createdAt ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
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
