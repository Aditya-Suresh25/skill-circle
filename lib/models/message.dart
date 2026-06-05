class ChatMessage {
  const ChatMessage({
    required this.messageId,
    required this.channelId,
    required this.senderId,
    this.senderName, // local convenience field
    required this.text,
    required this.createdAt,
    this.readBy = const [],
  });

  final String messageId;
  final String channelId;
  final String senderId;
  final String? senderName;
  final String text;
  final DateTime createdAt;
  final List<String> readBy;

  factory ChatMessage.fromMap(String id, Map<String, dynamic> data) {
    DateTime parsedTime;
    try {
      final t = data['createdAt'] ?? data['created_at'];
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

    return ChatMessage(
      messageId: id,
      channelId: data['channelId'] as String? ?? data['channel_id'] as String? ?? '',
      senderId: data['senderId'] as String? ?? data['sender_id'] as String? ?? '',
      senderName: data['sender_name'] as String?,
      text: data['text'] as String? ?? '',
      createdAt: parsedTime,
      readBy: List<String>.from(data['readBy'] ?? data['read_by'] ?? const []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'channelId': channelId,
      'senderId': senderId,
      'text': text,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'readBy': readBy,
    };
  }

  ChatMessage copyWith({String? senderName}) {
    return ChatMessage(
      messageId: messageId,
      channelId: channelId,
      senderId: senderId,
      senderName: senderName ?? this.senderName,
      text: text,
      createdAt: createdAt,
      readBy: readBy,
    );
  }
}
