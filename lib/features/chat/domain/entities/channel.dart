import 'package:skill_circle_app/core/utils/appwrite_serialization.dart';

class Channel {
  const Channel({
    required this.id,
    required this.circleId,
    required this.name,
    this.description = '',
    required this.createdAt,
    this.typing = const [],
  });

  final String id;
  final String circleId;
  final String name;
  final String description;
  final DateTime createdAt;
  final List<String> typing; // List of user IDs currently typing

  factory Channel.fromMap(String id, Map<String, dynamic> map) {
    return Channel(
      id: map['id'] as String? ?? map['channelId'] as String? ?? id,
      circleId: map['circleId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      createdAt: _parseTimestamp(map['createdAt']) ?? DateTime.now(),
      typing: List<String>.from(map['typing'] ?? const <String>[]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'channelId': id,
      'circleId': circleId,
      'name': name,
      'description': description,
      'createdAt': serializeAppwriteDate(createdAt),
      'typing': typing,
    };
  }

  static DateTime? _parseTimestamp(dynamic value) {
    return parseAppwriteDate(value);
  }
}
