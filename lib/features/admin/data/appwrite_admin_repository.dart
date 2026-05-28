import 'package:appwrite/appwrite.dart';
import 'package:skill_circle_app/core/constants/appwrite_storage_config.dart';
import 'package:skill_circle_app/core/utils/appwrite_file_url.dart';
import 'package:skill_circle_app/features/admin/domain/admin_repository.dart';
import 'package:skill_circle_app/features/posts/domain/entities/post.dart';
import 'package:skill_circle_app/features/profile/domain/entities/profile.dart';
import 'package:skill_circle_app/features/skill_circles/domain/entities/skill_circle.dart';

class AppwriteAdminRepository implements AdminRepository {
  AppwriteAdminRepository(this._databases, this._config);

  final Databases _databases;
  final AppwriteStorageConfig _config;

  @override
  Future<List<Profile>> listUsers({int limit = 50}) async {
    final response = await _databases.listDocuments(
      databaseId: _config.databaseId,
      collectionId: _config.usersCollectionId,
      queries: [Query.orderDesc('createdAt'), Query.limit(limit)],
    );

    return response.documents
        .map((document) => Profile.fromMap(Map<String, dynamic>.from(document.data as Map)))
        .toList(growable: false);
  }

  @override
  Future<List<SkillCircle>> listCircles({int limit = 50}) async {
    final response = await _databases.listDocuments(
      databaseId: _config.databaseId,
      collectionId: _config.skillCirclesCollectionId,
      queries: [Query.orderDesc('created_at'), Query.limit(limit)],
    );

    return response.documents
      .map((document) => SkillCircle.fromMap(document.$id, Map<String, dynamic>.from(document.data as Map)))
        .toList(growable: false);
  }

  @override
  Future<List<Post>> listPosts({int limit = 50}) async {
    final response = await _databases.listDocuments(
      databaseId: _config.databaseId,
      collectionId: _config.postsCollectionId,
      queries: [Query.orderDesc('timestamp'), Query.limit(limit)],
    );

    return response.documents
        .map(
          (document) => Post.fromMap(
            document.$id,
            Map<String, dynamic>.from(document.data as Map),
            attachmentUrlBuilder: (fileId) => buildAppwriteFileViewUrl(
              endpoint: _config.endpoint,
              bucketId: _config.bucketId,
              projectId: _config.projectId,
              fileId: fileId,
            ),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> deleteCircle(String circleId) async {
    await _databases.deleteDocument(
      databaseId: _config.databaseId,
      collectionId: _config.skillCirclesCollectionId,
      documentId: circleId,
    );
  }

  @override
  Future<void> deletePost(String postId) async {
    await _databases.deleteDocument(
      databaseId: _config.databaseId,
      collectionId: _config.postsCollectionId,
      documentId: postId,
    );
  }
}
