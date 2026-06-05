class ChatChannel {
  const ChatChannel({
    required this.channelId,
    required this.circleId,
    required this.name,
    this.description,
    required this.createdAt,
    this.typing = const [],
  });

  final String channelId;
  final String circleId;
  final String name;
  final String? description;
  final DateTime createdAt;
  final List<String> typing;

  factory ChatChannel.fromMap(String id, Map<String, dynamic> data) {
    DateTime parsedTime;
    try {
      final t = data['createdAt'];
      if (t == null) {
        parsedTime = DateTime.now();
      } else if (t is String) {
        parsedTime = DateTime.tryParse(t) ?? DateTime.now();
      } else {
        parsedTime = DateTime.now();
      }
    } catch (_) {
      parsedTime = DateTime.now();
    }

    return ChatChannel(
      channelId: id,
      circleId: data['circleId'] as String? ?? data['circle_id'] as String? ?? '',
      name: data['name'] as String? ?? 'General Chat',
      description: data['description'] as String?,
      createdAt: parsedTime,
      typing: List<String>.from(data['typing'] ?? const []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'channelId': channelId,
      'circleId': circleId,
      'name': name,
      if (description != null) 'description': description,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'typing': typing,
    };
  }
}
