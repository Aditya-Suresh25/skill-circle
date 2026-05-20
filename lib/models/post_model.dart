import 'package:skill_circle_app/core/utils/appwrite_serialization.dart';

class PostAttachmentModel {
	const PostAttachmentModel({
		required this.fileId,
		required this.url,
		required this.name,
		required this.size,
		required this.contentType,
		required this.storagePath,
	});

	final String fileId;
	final String url;
	final String name;
	final int size;
	final String contentType;
	final String storagePath;

	factory PostAttachmentModel.fromMap(Map<String, dynamic> map) {
		return PostAttachmentModel(
			fileId: map['file_id'] as String? ?? map['fileId'] as String? ?? '',
			url: map['url'] as String? ?? '',
			name: map['name'] as String? ?? '',
			size: (map['size'] as num?)?.toInt() ?? 0,
			contentType: map['content_type'] as String? ?? map['contentType'] as String? ?? '',
			storagePath: map['storage_path'] as String? ?? map['storagePath'] as String? ?? '',
		);
	}

	Map<String, dynamic> toMap() {
		return {
			'file_id': fileId,
			'url': url,
			'name': name,
			'size': size,
			'content_type': contentType,
			'storage_path': storagePath,
		};
	}
}

class PostModel {
	const PostModel({
		required this.postId,
		required this.userId,
		required this.circleId,
		required this.username,
		required this.content,
		required this.timestamp,
		required this.upvotes,
		this.title,
		this.attachments = const [],
	});

	final String postId;
	final String userId;
	final String circleId;
	final String username;
	final String content;
	final DateTime timestamp;
	final int upvotes;
	final String? title;
	final List<PostAttachmentModel> attachments;

	factory PostModel.fromMap(String id, Map<String, dynamic> map) {
		final rawAttachments = map['attachments'] as List<dynamic>? ?? const [];

		return PostModel(
			postId: map['postId'] as String? ?? map['id'] as String? ?? id,
			userId: map['user_id'] as String? ?? map['userId'] as String? ?? '',
			circleId: map['circle_id'] as String? ?? map['circleId'] as String? ?? '',
			username: map['username'] as String? ?? map['display_name'] as String? ?? '',
			content: map['post_content'] as String? ?? map['content'] as String? ?? '',
			timestamp: _parseTimestamp(map['timestamp']),
			upvotes: (map['upvotes'] as num?)?.toInt() ?? 0,
			title: map['title'] as String?,
			attachments: rawAttachments
					.map((item) => PostAttachmentModel.fromMap(Map<String, dynamic>.from(item as Map)))
					.toList(growable: false),
		);
	}

	Map<String, dynamic> toMap() {
		return {
			'postId': postId,
			'user_id': userId,
			'circle_id': circleId,
			'username': username,
			'title': title,
			'post_content': content,
			'timestamp': serializeAppwriteDate(timestamp),
			'upvotes': upvotes,
			'attachments': attachments.map((attachment) => attachment.toMap()).toList(growable: false),
		};
	}

	static DateTime _parseTimestamp(dynamic value) {
		final parsed = parseAppwriteDate(value);
		if (parsed != null) return parsed;
		return DateTime.fromMillisecondsSinceEpoch(0);
	}
}
