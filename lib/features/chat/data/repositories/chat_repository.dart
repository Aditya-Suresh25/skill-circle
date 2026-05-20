import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:skill_circle_app/core/constants/appwrite_storage_config.dart';
import 'package:skill_circle_app/features/chat/domain/entities/channel.dart';
import 'package:skill_circle_app/features/chat/domain/entities/message.dart';

class ChatRepository {
  ChatRepository(
    this._databases,
    this._realtime,
    this._config,
  );

  final Databases _databases;
  final Realtime _realtime;
  final AppwriteStorageConfig _config;

  Stream<List<Channel>> watchChannels(String circleId) {
    return _watchChannels(circleId);
  }

  Future<Channel> createChannel(String circleId, String name, {String description = ''}) async {
    final channelId = ID.unique();
    final channel = Channel(
      id: channelId,
      circleId: circleId,
      name: name,
      description: description,
      createdAt: DateTime.now(),
    );

    await _databases.createDocument(
      databaseId: _config.databaseId,
      collectionId: _config.channelsCollectionId,
      documentId: channelId,
      data: channel.toMap(),
      permissions: [
        Permission.read(Role.any()),
        Permission.update(Role.users()),
        Permission.delete(Role.users()),
      ],
    );

    return channel;
  }

  Stream<List<Message>> watchMessages(String circleId, String channelId, {int limit = 50}) {
    return _watchMessages(circleId, channelId, limit: limit);
  }

  Future<void> sendMessage(String circleId, String channelId, String senderId, String text) async {
    final messageId = ID.unique();
    final msg = Message(
      id: messageId,
      channelId: channelId,
      senderId: senderId,
      text: text,
      createdAt: DateTime.now(),
      readBy: [senderId],
    );

    await _databases.createDocument(
      databaseId: _config.databaseId,
      collectionId: _config.messagesCollectionId,
      documentId: messageId,
      data: {
        ...msg.toMap(),
        'circleId': circleId,
      },
      permissions: [
        Permission.read(Role.any()),
        Permission.update(Role.users()),
        Permission.delete(Role.users()),
      ],
    );
  }

  Future<void> setTypingStatus(String circleId, String channelId, String userId, bool isTyping) async {
    final document = await _databases.getDocument(
      databaseId: _config.databaseId,
      collectionId: _config.channelsCollectionId,
      documentId: channelId,
    );

    final typing = List<String>.from((document.data as Map)['typing'] ?? const <String>[]);
    if (isTyping) {
      if (!typing.contains(userId)) typing.add(userId);
    } else {
      typing.remove(userId);
    }

    await _databases.updateDocument(
      databaseId: _config.databaseId,
      collectionId: _config.channelsCollectionId,
      documentId: channelId,
      data: {
        'circleId': circleId,
        'typing': typing,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      },
    );
  }

  Future<void> markMessageRead(String circleId, String channelId, String messageId, String userId) async {
    final document = await _databases.getDocument(
      databaseId: _config.databaseId,
      collectionId: _config.messagesCollectionId,
      documentId: messageId,
    );

    final readBy = List<String>.from((document.data as Map)['readBy'] ?? const <String>[]);
    if (!readBy.contains(userId)) {
      readBy.add(userId);
    }

    await _databases.updateDocument(
      databaseId: _config.databaseId,
      collectionId: _config.messagesCollectionId,
      documentId: messageId,
      data: {
        'circleId': circleId,
        'channelId': channelId,
        'readBy': readBy,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      },
    );
  }

  Future<void> updateUserStatus(String userId, String status) async {
    try {
      await _databases.updateDocument(
        databaseId: _config.databaseId,
        collectionId: _config.usersCollectionId,
        documentId: userId,
        data: {
          'status': status,
          'lastSeen': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } on AppwriteException {
      // Ignore presence updates when the user schema does not include these fields.
    }
  }

  Stream<List<Channel>> _watchChannels(String circleId) {
    final controller = StreamController<List<Channel>>.broadcast();
    StreamSubscription? subscription;

    Future<void> refresh() async {
      try {
        final documents = await _listChannelDocuments(circleId);
        final channels = documents.map(_toChannel).toList(growable: false);
        if (!controller.isClosed) {
          controller.add(channels);
        }
      } catch (error, stackTrace) {
        if (!controller.isClosed) {
          controller.addError(error, stackTrace);
        }
      }
    }

    controller.onListen = () {
      refresh();
      subscription = _realtime.subscribe([
        'databases.${_config.databaseId}.collections.${_config.channelsCollectionId}.documents',
      ]).stream.listen((_) => refresh());
    };

    controller.onCancel = () async {
      await subscription?.cancel();
      await controller.close();
    };

    return controller.stream;
  }

  Stream<List<Message>> _watchMessages(String circleId, String channelId, {required int limit}) {
    final controller = StreamController<List<Message>>.broadcast();
    StreamSubscription? subscription;

    Future<void> refresh() async {
      try {
        final documents = await _listMessageDocuments(circleId, channelId, limit: limit);
        final messages = documents.map(_toMessage).toList(growable: false);
        if (!controller.isClosed) {
          controller.add(messages);
        }
      } catch (error, stackTrace) {
        if (!controller.isClosed) {
          controller.addError(error, stackTrace);
        }
      }
    }

    controller.onListen = () {
      refresh();
      subscription = _realtime.subscribe([
        'databases.${_config.databaseId}.collections.${_config.messagesCollectionId}.documents',
      ]).stream.listen((_) => refresh());
    };

    controller.onCancel = () async {
      await subscription?.cancel();
      await controller.close();
    };

    return controller.stream;
  }

  Future<List<dynamic>> _listChannelDocuments(String circleId) async {
    final response = await _databases.listDocuments(
      databaseId: _config.databaseId,
      collectionId: _config.channelsCollectionId,
      queries: [
        Query.equal('circleId', circleId),
        Query.orderAsc('createdAt'),
      ],
    );
    return response.documents;
  }

  Future<List<dynamic>> _listMessageDocuments(String circleId, String channelId, {required int limit}) async {
    final response = await _databases.listDocuments(
      databaseId: _config.databaseId,
      collectionId: _config.messagesCollectionId,
      queries: [
        Query.equal('circleId', circleId),
        Query.equal('channelId', channelId),
        Query.orderDesc('createdAt'),
        Query.limit(limit),
      ],
    );
    return response.documents;
  }

  Channel _toChannel(dynamic document) {
    return Channel.fromMap(document.$id as String, Map<String, dynamic>.from(document.data as Map));
  }

  Message _toMessage(dynamic document) {
    return Message.fromMap(document.$id as String, Map<String, dynamic>.from(document.data as Map));
  }
}
