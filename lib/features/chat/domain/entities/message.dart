import 'package:skill_circle_app/core/utils/appwrite_serialization.dart';

class Message {
  const Message({
    required this.id,
    required this.channelId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    this.readBy = const [],
  });

  final String id;
  final String channelId;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final List<String> readBy;

  factory Message.fromMap(String id, Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String? ?? map['messageId'] as String? ?? id,
      channelId: map['channelId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      createdAt: _parseTimestamp(map['createdAt']) ?? DateTime.now(),
      readBy: List<String>.from(map['readBy'] ?? const <String>[]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': id,
      'channelId': channelId,
      'senderId': senderId,
      'text': text,
      'createdAt': serializeAppwriteDate(createdAt),
      'readBy': readBy,
    };
  }

  static DateTime? _parseTimestamp(dynamic value) {
    return parseAppwriteDate(value);
  }
}
