import 'dart:async';
import 'dart:typed_data';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/constants/appwrite_storage_config.dart';
import 'package:skill_circle_app/models/user.dart';
import 'package:skill_circle_app/models/circle.dart';
import 'package:skill_circle_app/models/post.dart';
import 'package:skill_circle_app/models/comment.dart';
import 'package:skill_circle_app/models/channel.dart';
import 'package:skill_circle_app/models/message.dart';
import 'package:skill_circle_app/models/task.dart';

final appwriteConfigProvider = Provider<AppwriteStorageConfig>((ref) => AppwriteStorageConfig.fromEnv());

final appwriteClientProvider = Provider<Client>((ref) {
  final config = ref.watch(appwriteConfigProvider);
  return Client().setEndpoint(config.endpoint).setProject(config.projectId);
});

final appwriteServiceProvider = Provider<AppwriteService>((ref) {
  final client = ref.watch(appwriteClientProvider);
  final config = ref.watch(appwriteConfigProvider);
  return AppwriteService(client, config);
});

class AppwriteService {
  AppwriteService(this.client, this._config)
      : _account = Account(client),
        _databases = Databases(client),
        _storage = Storage(client),
        _realtime = Realtime(client);

  final Client client;
  final AppwriteStorageConfig _config;
  final Account _account;
  final Databases _databases;
  final Storage _storage;
  final Realtime _realtime;

  // --- Auth & Profile ---
  Future<AppUser> signUp(String email, String password, String name, String role) async {
    final userId = ID.unique();
    await _account.create(userId: userId, email: email, password: password, name: name);
    
    // Automatically sign in to create session; first clear any existing active session
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (_) {}
    
    await _account.createEmailPasswordSession(email: email, password: password);

    final user = AppUser(
      id: userId,
      displayName: name,
      email: email,
      role: role,
      joinedSkills: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _databases.createDocument(
      databaseId: _config.databaseId,
      collectionId: _config.usersCollectionId,
      documentId: userId,
      data: user.toMap(),
    );

    return user;
  }

  Future<AppUser> signIn(String email, String password) async {
    // Clear any existing active session first
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (_) {}
    
    final session = await _account.createEmailPasswordSession(email: email, password: password);
    final profile = await getCurrentProfile(session.userId);
    if (profile == null) {
      // Create profile fallback
      final acc = await _account.get();
      final user = AppUser(
        id: session.userId,
        displayName: acc.name,
        email: acc.email,
        role: 'student',
        joinedSkills: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _databases.createDocument(
        databaseId: _config.databaseId,
        collectionId: _config.usersCollectionId,
        documentId: session.userId,
        data: user.toMap(),
      );
      return user;
    }
    return profile;
  }

  Future<void> signOut() async {
    await _account.deleteSession(sessionId: 'current');
  }

  Future<AppUser?> getCurrentUser() async {
    try {
      final acc = await _account.get();
      return getCurrentProfile(acc.$id);
    } catch (_) {
      return null;
    }
  }

  Future<AppUser?> getCurrentProfile(String userId) async {
    try {
      final doc = await _databases.getDocument(
        databaseId: _config.databaseId,
        collectionId: _config.usersCollectionId,
        documentId: userId,
      );
      return AppUser.fromMap(doc.$id, Map<String, dynamic>.from(doc.data));
    } catch (_) {
      return null;
    }
  }

  Future<AppUser> updateProfile(String userId, {String? displayName, String? bio, String? photoUrl}) async {
    final current = await getCurrentProfile(userId);
    if (current == null) throw Exception('Profile not found');

    final updated = current.copyWith(
      displayName: displayName,
      bio: bio,
      photoUrl: photoUrl,
      updatedAt: DateTime.now(),
    );

    final doc = await _databases.updateDocument(
      databaseId: _config.databaseId,
      collectionId: _config.usersCollectionId,
      documentId: userId,
      data: updated.toMap(),
    );

    return AppUser.fromMap(doc.$id, Map<String, dynamic>.from(doc.data));
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    await _databases.updateDocument(
      databaseId: _config.databaseId,
      collectionId: _config.usersCollectionId,
      documentId: userId,
      data: {'role': newRole, 'updatedAt': DateTime.now().toUtc().toIso8601String()},
    );
  }

  Future<List<AppUser>> getAllUsers() async {
    final res = await _databases.listDocuments(
      databaseId: _config.databaseId,
      collectionId: _config.usersCollectionId,
      queries: [Query.limit(100)],
    );
    return res.documents.map((d) => AppUser.fromMap(d.$id, Map<String, dynamic>.from(d.data))).toList();
  }

  // --- Skill Circles ---
  Future<List<SkillCircle>> getCircles() async {
    final res = await _databases.listDocuments(
      databaseId: _config.databaseId,
      collectionId: _config.skillCirclesCollectionId,
      queries: [Query.limit(100)],
    );
    return res.documents.map((d) => SkillCircle.fromMap(d.$id, Map<String, dynamic>.from(d.data))).toList();
  }

  Future<SkillCircle> createCircle(String name, String description, String creatorId, {String? imageUrl, String? bannerUrl}) async {
    final circleId = ID.unique();
    final circle = SkillCircle(
      circleId: circleId,
      circleName: name,
      description: description,
      createdBy: creatorId,
      createdAt: DateTime.now(),
      memberCount: 1,
      members: [creatorId],
      imageUrl: imageUrl,
      bannerUrl: bannerUrl,
    );

    final doc = await _databases.createDocument(
      databaseId: _config.databaseId,
      collectionId: _config.skillCirclesCollectionId,
      documentId: circleId,
      data: circle.toMap(),
    );

    // Update user's joinedSkills
    final profile = await getCurrentProfile(creatorId);
    if (profile != null) {
      final updatedSkills = Set<String>.from(profile.joinedSkills)..add(circleId);
      await _databases.updateDocument(
        databaseId: _config.databaseId,
        collectionId: _config.usersCollectionId,
        documentId: creatorId,
        data: {'joinedSkills': updatedSkills.toList()},
      );
    }

    return SkillCircle.fromMap(doc.$id, Map<String, dynamic>.from(doc.data));
  }

  Future<void> deleteCircle(String circleId) async {
    await _databases.deleteDocument(
      databaseId: _config.databaseId,
      collectionId: _config.skillCirclesCollectionId,
      documentId: circleId,
    );
  }

  Future<void> joinCircle(String circleId, String userId) async {
    final doc = await _databases.getDocument(
      databaseId: _config.databaseId,
      collectionId: _config.skillCirclesCollectionId,
      documentId: circleId,
    );
    final circle = SkillCircle.fromMap(doc.$id, Map<String, dynamic>.from(doc.data));
    if (circle.members.contains(userId)) return;

    final updatedMembers = List<String>.from(circle.members)..add(userId);
    await _databases.updateDocument(
      databaseId: _config.databaseId,
      collectionId: _config.skillCirclesCollectionId,
      documentId: circleId,
      data: {
        'members': updatedMembers,
        'member_count': updatedMembers.length,
      },
    );

    final profile = await getCurrentProfile(userId);
    if (profile != null) {
      final updatedSkills = Set<String>.from(profile.joinedSkills)..add(circleId);
      await _databases.updateDocument(
        databaseId: _config.databaseId,
        collectionId: _config.usersCollectionId,
        documentId: userId,
        data: {'joinedSkills': updatedSkills.toList()},
      );
    }
  }

  Future<void> leaveCircle(String circleId, String userId) async {
    final doc = await _databases.getDocument(
      databaseId: _config.databaseId,
      collectionId: _config.skillCirclesCollectionId,
      documentId: circleId,
    );
    final circle = SkillCircle.fromMap(doc.$id, Map<String, dynamic>.from(doc.data));
    if (!circle.members.contains(userId)) return;

    final updatedMembers = List<String>.from(circle.members)..remove(userId);
    await _databases.updateDocument(
      databaseId: _config.databaseId,
      collectionId: _config.skillCirclesCollectionId,
      documentId: circleId,
      data: {
        'members': updatedMembers,
        'member_count': updatedMembers.length,
      },
    );

    final profile = await getCurrentProfile(userId);
    if (profile != null) {
      final updatedSkills = Set<String>.from(profile.joinedSkills)..remove(circleId);
      await _databases.updateDocument(
        databaseId: _config.databaseId,
        collectionId: _config.usersCollectionId,
        documentId: userId,
        data: {'joinedSkills': updatedSkills.toList()},
      );
    }
  }

  // --- Posts ---
  Future<List<Post>> getPosts(String circleId) async {
    final res = await _databases.listDocuments(
      databaseId: _config.databaseId,
      collectionId: _config.postsCollectionId,
      queries: [
        Query.equal('circle_id', circleId),
        Query.orderDesc('timestamp'),
        Query.limit(100),
      ],
    );
    return res.documents.map((d) => Post.fromMap(d.$id, Map<String, dynamic>.from(d.data), attachmentUrlBuilder: getFileViewUrl)).toList();
  }

  Future<Post> createPost(String circleId, String userId, String username, String content, {List<Attachment> attachments = const []}) async {
    final postId = ID.unique();
    final post = Post(
      id: postId,
      userId: userId,
      username: username,
      circleId: circleId,
      content: content,
      timestamp: DateTime.now(),
      upvotes: 0,
      attachments: attachments,
    );

    final doc = await _databases.createDocument(
      databaseId: _config.databaseId,
      collectionId: _config.postsCollectionId,
      documentId: postId,
      data: post.toMap(),
    );

    return Post.fromMap(doc.$id, Map<String, dynamic>.from(doc.data), attachmentUrlBuilder: getFileViewUrl);
  }

  Future<void> upvotePost(String postId, int currentUpvotes) async {
    await _databases.updateDocument(
      databaseId: _config.databaseId,
      collectionId: _config.postsCollectionId,
      documentId: postId,
      data: {'upvotes': currentUpvotes + 1},
    );
  }

  Future<void> updatePost(String postId, String content) async {
    await _databases.updateDocument(
      databaseId: _config.databaseId,
      collectionId: _config.postsCollectionId,
      documentId: postId,
      data: {'content': content},
    );
  }

  Future<void> deletePost(String postId) async {
    await _databases.deleteDocument(
      databaseId: _config.databaseId,
      collectionId: _config.postsCollectionId,
      documentId: postId,
    );
  }

  // --- Comments ---
  Future<List<Comment>> getComments(String postId) async {
    final res = await _databases.listDocuments(
      databaseId: _config.databaseId,
      collectionId: _config.commentsCollectionId,
      queries: [
        Query.equal('post_id', postId),
        Query.orderAsc('timestamp'),
        Query.limit(100),
      ],
    );
    return res.documents.map((d) => Comment.fromMap(d.$id, Map<String, dynamic>.from(d.data))).toList();
  }

  Future<Comment> createComment(String postId, String userId, String username, String text) async {
    final commentId = ID.unique();
    final comment = Comment(
      commentId: commentId,
      postId: postId,
      userId: userId,
      username: username,
      commentText: text,
      timestamp: DateTime.now(),
    );

    final doc = await _databases.createDocument(
      databaseId: _config.databaseId,
      collectionId: _config.commentsCollectionId,
      documentId: commentId,
      data: comment.toMap(),
    );

    return Comment.fromMap(doc.$id, Map<String, dynamic>.from(doc.data));
  }

  // --- Channels & Real-time Messages ---
  Future<List<ChatChannel>> getChannels(String circleId) async {
    final res = await _databases.listDocuments(
      databaseId: _config.databaseId,
      collectionId: _config.channelsCollectionId,
      queries: [Query.equal('circleId', circleId), Query.orderAsc('createdAt')],
    );
    return res.documents.map((d) => ChatChannel.fromMap(d.$id, Map<String, dynamic>.from(d.data))).toList();
  }

  Future<ChatChannel> createChannel(String circleId, String name, String description) async {
    final channelId = ID.unique();
    final channel = ChatChannel(
      channelId: channelId,
      circleId: circleId,
      name: name,
      description: description,
      createdAt: DateTime.now(),
    );
    final doc = await _databases.createDocument(
      databaseId: _config.databaseId,
      collectionId: _config.channelsCollectionId,
      documentId: channelId,
      data: channel.toMap(),
    );
    return ChatChannel.fromMap(doc.$id, Map<String, dynamic>.from(doc.data));
  }

  Future<List<ChatMessage>> getMessages(String channelId) async {
    final res = await _databases.listDocuments(
      databaseId: _config.databaseId,
      collectionId: _config.messagesCollectionId,
      queries: [Query.equal('channelId', channelId), Query.orderAsc('createdAt'), Query.limit(100)],
    );
    
    final messages = <ChatMessage>[];
    for (final doc in res.documents) {
      final msg = ChatMessage.fromMap(doc.$id, Map<String, dynamic>.from(doc.data));
      final senderProfile = await getCurrentProfile(msg.senderId);
      messages.add(msg.copyWith(senderName: senderProfile?.displayName));
    }
    return messages;
  }

  Future<ChatMessage> sendMessage(String channelId, String senderId, String senderName, String text) async {
    final messageId = ID.unique();
    final message = ChatMessage(
      messageId: messageId,
      channelId: channelId,
      senderId: senderId,
      text: text,
      createdAt: DateTime.now(),
    );

    final doc = await _databases.createDocument(
      databaseId: _config.databaseId,
      collectionId: _config.messagesCollectionId,
      documentId: messageId,
      data: message.toMap(),
    );

    return ChatMessage.fromMap(doc.$id, Map<String, dynamic>.from(doc.data)).copyWith(senderName: senderName);
  }

  Stream<RealtimeMessage> watchMessages() {
    return _realtime.subscribe([
      'databases.${_config.databaseId}.collections.${_config.messagesCollectionId}.documents'
    ]).stream;
  }

  // --- Mentor Tasks & Submissions ---
  Future<void> createTask(MentorTask task) async {
    final docId = task.id.isEmpty ? ID.unique() : task.id;
    
    await _databases.createDocument(
      databaseId: _config.databaseId,
      collectionId: _config.tasksCollectionId,
      documentId: docId,
      data: task.toMap(),
    );
  }

  Future<List<MentorTask>> getTasks(String circleId) async {
    final res = await _databases.listDocuments(
      databaseId: _config.databaseId,
      collectionId: _config.tasksCollectionId,
      queries: [
        Query.equal('circle_id', circleId),
        Query.orderDesc('created_at'),
        Query.limit(100),
      ],
    );
    return res.documents.map((d) => MentorTask.fromMap(d.$id, Map<String, dynamic>.from(d.data))).toList();
  }

  Future<void> updateTask(MentorTask task) async {
    await _databases.updateDocument(
      databaseId: _config.databaseId,
      collectionId: _config.tasksCollectionId,
      documentId: task.id,
      data: task.toMap(),
    );
  }

  Future<void> deleteTask(String taskId) async {
    await _databases.deleteDocument(
      databaseId: _config.databaseId,
      collectionId: _config.tasksCollectionId,
      documentId: taskId,
    );
  }

  Future<void> submitTask(TaskSubmission submission) async {
    await _databases.createDocument(
      databaseId: _config.databaseId,
      collectionId: _config.taskSubmissionsCollectionId,
      documentId: submission.id.isEmpty ? ID.unique() : submission.id,
      data: submission.toMap(),
    );
  }

  Future<List<TaskSubmission>> getSubmissions(String taskId) async {
    final res = await _databases.listDocuments(
      databaseId: _config.databaseId,
      collectionId: _config.taskSubmissionsCollectionId,
      queries: [
        Query.equal('task_id', taskId),
        Query.orderDesc('submitted_at'),
        Query.limit(100),
      ],
    );

    final submissions = <TaskSubmission>[];
    for (final doc in res.documents) {
      final sub = TaskSubmission.fromMap(doc.$id, Map<String, dynamic>.from(doc.data));
      final userProfile = await getCurrentProfile(sub.userId);
      submissions.add(sub.copyWith(userName: userProfile?.displayName));
    }
    return submissions;
  }

  Future<void> gradeSubmission(String submissionId, String grade, String feedback, String userId, String taskId) async {
    final doc = await _databases.getDocument(
      databaseId: _config.databaseId,
      collectionId: _config.taskSubmissionsCollectionId,
      documentId: submissionId,
    );
    
    final submission = TaskSubmission.fromMap(doc.$id, Map<String, dynamic>.from(doc.data));
    final updatedSubmission = submission.copyWith(grade: grade, feedback: feedback, status: 'graded');

    await _databases.updateDocument(
      databaseId: _config.databaseId,
      collectionId: _config.taskSubmissionsCollectionId,
      documentId: submissionId,
      data: updatedSubmission.toMap(),
    );

    if (grade == 'Pass') {
      final profile = await getCurrentProfile(userId);
      if (profile != null) {
        final taskSkillId = 'task_$taskId';
        if (!profile.joinedSkills.contains(taskSkillId)) {
          final updatedSkills = Set<String>.from(profile.joinedSkills)..add(taskSkillId);
          await _databases.updateDocument(
            databaseId: _config.databaseId,
            collectionId: _config.usersCollectionId,
            documentId: userId,
            data: {'joinedSkills': updatedSkills.toList()},
          );
        }
      }
    }
  }

  // --- Storage ---
  Future<Attachment> uploadFile(Uint8List bytes, String filename, String contentType, String ownerId) async {
    final fileId = ID.unique();
    // Ensure active session for uploads if anonymous
    try {
      await _account.createAnonymousSession();
    } on AppwriteException catch (e) {
      if (e.type != 'user_session_already_exists') {
        // let file upload fail normally if auth fails
      }
    }

    final file = await _storage.createFile(
      bucketId: _config.bucketId,
      fileId: fileId,
      file: InputFile.fromBytes(
        bytes: bytes,
        filename: filename,
        contentType: contentType,
      ),
    );

    final publicUrl = getFileViewUrl(file.$id);
    return Attachment(
      fileId: file.$id,
      url: publicUrl,
      name: filename,
      size: bytes.length,
      contentType: contentType,
      storagePath: '$ownerId/${file.$id}',
    );
  }

  Future<void> deleteFile(String fileId) async {
    try {
      await _storage.deleteFile(bucketId: _config.bucketId, fileId: fileId);
    } catch (_) {}
  }

  String getFileViewUrl(String fileId) {
    final base = _config.endpoint.endsWith('/')
        ? _config.endpoint.substring(0, _config.endpoint.length - 1)
        : _config.endpoint;
    final encodedBucketId = Uri.encodeComponent(_config.bucketId);
    final encodedFileId = Uri.encodeComponent(fileId);
    final encodedProjectId = Uri.encodeQueryComponent(_config.projectId);
    return '$base/storage/buckets/$encodedBucketId/files/$encodedFileId/view?project=$encodedProjectId';
  }
}

final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, AppUser?>((ref) {
  final service = ref.watch(appwriteServiceProvider);
  return CurrentUserNotifier(service);
});

class CurrentUserNotifier extends StateNotifier<AppUser?> {
  CurrentUserNotifier(this._service) : super(null) {
    checkSession();
  }

  final AppwriteService _service;

  Future<void> checkSession() async {
    try {
      final user = await _service.getCurrentUser();
      state = user;
    } catch (_) {
      state = null;
    }
  }

  void setUser(AppUser? user) {
    state = user;
  }

  Future<void> signOut() async {
    try {
      await _service.signOut();
    } catch (_) {}
    state = null;
  }
}
