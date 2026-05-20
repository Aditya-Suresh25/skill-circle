import 'package:skill_circle_app/core/utils/appwrite_serialization.dart';

class CommentModel {
	const CommentModel({
		required this.commentId,
		required this.postId,
		required this.userId,
		required this.username,
		required this.text,
		required this.timestamp,
	});

	final String commentId;
	final String postId;
	final String userId;
	final String username;
	final String text;
	final DateTime timestamp;

	factory CommentModel.fromMap(String id, Map<String, dynamic> map) {
		return CommentModel(
			commentId: map['commentId'] as String? ?? map['id'] as String? ?? id,
			postId: map['post_id'] as String? ?? map['postId'] as String? ?? '',
			userId: map['user_id'] as String? ?? map['userId'] as String? ?? '',
			username: map['username'] as String? ?? map['display_name'] as String? ?? '',
			text: map['comment_text'] as String? ?? map['text'] as String? ?? '',
			timestamp: _parseTimestamp(map['timestamp']),
		);
	}

	Map<String, dynamic> toMap() {
		return {
			'commentId': commentId,
			'post_id': postId,
			'user_id': userId,
			'username': username,
			'comment_text': text,
			'timestamp': serializeAppwriteDate(timestamp),
		};
	}

	static DateTime _parseTimestamp(dynamic value) {
		final parsed = parseAppwriteDate(value);
		if (parsed != null) return parsed;
		return DateTime.fromMillisecondsSinceEpoch(0);
	}
}
