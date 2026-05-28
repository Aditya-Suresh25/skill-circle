import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/providers/appwrite_storage_providers.dart';

class AdminDashboardStats {
  const AdminDashboardStats({
    required this.users,
    required this.circles,
    required this.posts,
    required this.comments,
  });

  final int users;
  final int circles;
  final int posts;
  final int comments;
}

final adminDashboardStatsProvider = FutureProvider<AdminDashboardStats>((ref) async {
  final databases = ref.watch(appwriteDatabasesProvider);
  final config = ref.watch(appwriteStorageConfigProvider);

  final results = await Future.wait([
    databases.listDocuments(databaseId: config.databaseId, collectionId: config.usersCollectionId, queries: [Query.limit(1)]),
    databases.listDocuments(databaseId: config.databaseId, collectionId: config.skillCirclesCollectionId, queries: [Query.limit(1)]),
    databases.listDocuments(databaseId: config.databaseId, collectionId: config.postsCollectionId, queries: [Query.limit(1)]),
    databases.listDocuments(databaseId: config.databaseId, collectionId: config.commentsCollectionId, queries: [Query.limit(1)]),
  ]);

  return AdminDashboardStats(
    users: results[0].total,
    circles: results[1].total,
    posts: results[2].total,
    comments: results[3].total,
  );
});
