class AppUser {
  const AppUser({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.bio,
    required this.role,
    this.joinedSkills = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String? bio;
  final String role; // 'student', 'mentor', 'admin'
  final List<String> joinedSkills;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      displayName: map['displayName'] as String? ?? map['display_name'] as String? ?? 'User',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? map['photo_url'] as String?,
      bio: map['bio'] as String?,
      role: map['role'] as String? ?? 'student',
      joinedSkills: List<String>.from(map['joinedSkills'] ?? map['joined_skills'] ?? const []),
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? map['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? map['updated_at'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (bio != null) 'bio': bio,
      'role': role,
      'joinedSkills': joinedSkills,
      'createdAt': createdAt?.toUtc().toIso8601String() ?? DateTime.now().toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String() ?? DateTime.now().toUtc().toIso8601String(),
    };
  }

  AppUser copyWith({
    String? displayName,
    String? email,
    String? photoUrl,
    String? bio,
    String? role,
    List<String>? joinedSkills,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      id: id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      joinedSkills: joinedSkills ?? this.joinedSkills,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
