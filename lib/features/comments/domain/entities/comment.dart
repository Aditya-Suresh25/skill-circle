import 'package:cloud_firestore/cloud_firestore.dart';

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
      id: id,
      postId: data['post_id'] as String? ?? '',
      userId: data['user_id'] as String? ?? '',
      text: data['comment_text'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'post_id': postId,
      'user_id': userId,
      'comment_text': text,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
 