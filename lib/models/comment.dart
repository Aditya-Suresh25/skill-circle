class Comment {
  const Comment({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.username,
    required this.commentText,
    required this.timestamp,
  });

  final String commentId;
  final String postId;
  final String userId;
  final String username;
  final String commentText;
  final DateTime timestamp;

  factory Comment.fromMap(String id, Map<String, dynamic> data) {
    DateTime parsedTime;
    try {
      final t = data['timestamp'];
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

    return Comment(
      commentId: id,
      postId: data['post_id'] as String? ?? '',
      userId: data['user_id'] as String? ?? '',
      username: data['username'] as String? ?? 'Community Member',
      commentText: data['comment_text'] as String? ?? '',
      timestamp: parsedTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'post_id': postId,
      'user_id': userId,
      'username': username,
      'comment_text': commentText,
      'timestamp': timestamp.toUtc().toIso8601String(),
    };
  }
}
