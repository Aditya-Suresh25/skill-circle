import 'package:cloud_firestore/cloud_firestore.dart';

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

  /// Convert Firestore document to Profile
  factory Profile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return Profile(
      id: snapshot.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      bio: data['bio'],
      photoUrl: data['photoUrl'],
      joinedSkills: List<String>.from(data['joinedSkills'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert Profile to Firestore document
  Map<String, dynamic> toFirestore() => {
        'displayName': displayName,
        'email': email,
        'bio': bio,
        'photoUrl': photoUrl,
        'joinedSkills': joinedSkills,
        'createdAt': createdAt ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
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