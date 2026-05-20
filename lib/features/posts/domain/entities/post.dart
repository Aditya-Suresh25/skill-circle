import 'package:skill_circle_app/core/utils/appwrite_serialization.dart';

class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.username,
    required this.circleId,
    required this.content,
    required this.timestamp,
    required this.upvotes,
    this.attachments = const [],
  });

  final String id;
  final String userId;
  final String username;
  final String circleId;
  final String content;
  final DateTime timestamp;
  final int upvotes;
  final List<Attachment> attachments;

  factory Post.fromMap(
    String id,
    Map<String, dynamic> data, {
    String Function(String fileId)? attachmentUrlBuilder,
  }) {
    return Post(
      id: data['id'] as String? ?? data['postId'] as String? ?? data['post_id'] as String? ?? id,
      userId: data['user_id'] as String? ?? '',
      username: data['username'] as String? ?? data['display_name'] as String? ?? 'Community Member',
      circleId: data['circle_id'] as String? ?? '',
      content: data['post_content'] as String? ?? '',
      timestamp: parseAppwriteDate(data['timestamp']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      upvotes: (data['upvotes'] as num?)?.toInt() ?? 0,
      attachments: Attachment.fromDynamicList(data['attachments'], urlBuilder: attachmentUrlBuilder),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': id,
      'user_id': userId,
      'username': username,
      'circle_id': circleId,
      'post_content': content,
      'timestamp': serializeAppwriteDate(timestamp),
      'upvotes': upvotes,
      'attachments': attachments.map((attachment) => attachment.toEncodedString()).toList(growable: false),
    };
  }
}

class Attachment {
  const Attachment({
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

  factory Attachment.fromMap(Map<String, dynamic> map) {
    return Attachment(
      fileId: map['file_id'] as String? ?? map['fileId'] as String? ?? '',
      url: map['url'] as String? ?? '',
      name: map['name'] as String? ?? '',
      size: (map['size'] as num?)?.toInt() ?? 0,
      contentType: map['content_type'] as String? ?? '',
      storagePath: map['storage_path'] as String? ?? '',
    );
  }

  factory Attachment.fromEncodedString(String encoded, {String Function(String fileId)? urlBuilder}) {
    final parts = encoded.split('|');
    final fileId = parts.isNotEmpty ? parts[0] : '';
    final name = parts.length > 1 ? Uri.decodeComponent(parts[1]) : '';
    final contentType = parts.length > 2 ? Uri.decodeComponent(parts[2]) : '';
    final size = parts.length > 3 ? int.tryParse(parts[3]) ?? 0 : 0;
    final storagePath = parts.length > 4 ? Uri.decodeComponent(parts[4]) : '';

    return Attachment(
      fileId: fileId,
      url: urlBuilder?.call(fileId) ?? '',
      name: name,
      size: size,
      contentType: contentType,
      storagePath: storagePath,
    );
  }

  static List<Attachment> fromDynamicList(dynamic value, {String Function(String fileId)? urlBuilder}) {
    final rawAttachments = value as List<dynamic>? ?? const [];
    return rawAttachments
        .map((item) {
          if (item is Map) {
            return Attachment.fromMap(Map<String, dynamic>.from(item));
          }
          if (item is String) {
            return Attachment.fromEncodedString(item, urlBuilder: urlBuilder);
          }
          return const Attachment(fileId: '', url: '', name: '', size: 0, contentType: '', storagePath: '');
        })
        .where((attachment) => attachment.fileId.isNotEmpty || attachment.url.isNotEmpty)
        .toList(growable: false);
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

  String toEncodedString() {
    return [
      fileId,
      Uri.encodeComponent(name),
      Uri.encodeComponent(contentType),
      size.toString(),
      Uri.encodeComponent(storagePath),
    ].join('|');
  }
}