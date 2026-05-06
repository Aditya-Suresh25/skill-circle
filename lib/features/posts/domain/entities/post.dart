import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.circleId,
    required this.content,
    required this.timestamp,
    required this.upvotes,
    this.attachments = const [],
  });

  final String id;
  final String userId;
  final String circleId;
  final String content;
  final DateTime timestamp;
  final int upvotes;
  final List<Attachment> attachments;

  factory Post.fromMap(String id, Map<String, dynamic> data) {
    return Post(
      id: id,
      userId: data['user_id'] as String? ?? '',
      circleId: data['circle_id'] as String? ?? '',
      content: data['post_content'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
      upvotes: (data['upvotes'] as num?)?.toInt() ?? 0,
      attachments: (data['attachments'] as List<dynamic>?)
              ?.map((e) => Attachment.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList(growable: false) ??
          const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'circle_id': circleId,
      'post_content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'upvotes': upvotes,
      'attachments': attachments.map((a) => a.toMap()).toList(growable: false),
    };
  }
}

class Attachment {
  const Attachment({
    required this.url,
    required this.name,
    required this.size,
    required this.contentType,
    required this.storagePath,
  });

  final String url;
  final String name;
  final int size;
  final String contentType;
  final String storagePath;

  factory Attachment.fromMap(Map<String, dynamic> map) {
    return Attachment(
      url: map['url'] as String? ?? '',
      name: map['name'] as String? ?? '',
      size: (map['size'] as num?)?.toInt() ?? 0,
      contentType: map['content_type'] as String? ?? '',
      storagePath: map['storage_path'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'name': name,
      'size': size,
      'content_type': contentType,
      'storage_path': storagePath,
    };
  }
}