import 'package:skill_circle_app/core/utils/appwrite_serialization.dart';

class Comment {
  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.text,
    required this.timestamp,
  });

  final String id;
  final String postId;
  final String userId;
  final String text;
  final DateTime timestamp;

  factory Comment.fromMap(String id, Map<String, dynamic> data) {
    return Comment(
      id: data['id'] as String? ?? data['commentId'] as String? ?? data['comment_id'] as String? ?? id,
      postId: data['post_id'] as String? ?? '',
      userId: data['user_id'] as String? ?? '',
      text: data['comment_text'] as String? ?? '',
      timestamp: parseAppwriteDate(data['timestamp']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'commentId': id,
      'post_id': postId,
      'user_id': userId,
      'comment_text': text,
      'timestamp': serializeAppwriteDate(timestamp),
    };
  }
}
 