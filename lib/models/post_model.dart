class PostModel {
	final String postId;
	final String userId;
	final String username;
	final String title;
	final String content;
	final DateTime timestamp;

	const PostModel({
		required this.postId,
		required this.userId,
		required this.username,
		required this.title,
		required this.content,
		required this.timestamp,
	});

	factory PostModel.fromMap(Map<String, dynamic> map) {
		return PostModel(
			postId: map['postId'] as String? ?? '',
			userId: map['userId'] as String? ?? '',
			username: map['username'] as String? ?? '',
			title: map['title'] as String? ?? '',
			content: map['content'] as String? ?? '',
			timestamp: _parseTimestamp(map['timestamp']),
		);
	}

	Map<String, dynamic> toMap() {
		return {
			'postId': postId,
			'userId': userId,
			'username': username,
			'title': title,
			'content': content,
			'timestamp': timestamp.toIso8601String(),
		};
	}

	static DateTime _parseTimestamp(dynamic value) {
		if (value is DateTime) return value;
		if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
		if (value is String) {
			final parsed = DateTime.tryParse(value);
			if (parsed != null) return parsed;
		}
		return DateTime.now();
	}
}
