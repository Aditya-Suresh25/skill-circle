import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/providers/appwrite_storage_providers.dart';
import 'package:skill_circle_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:skill_circle_app/features/profile/data/repositories/appwrite_profile_repository.dart';
import 'package:skill_circle_app/features/profile/domain/entities/profile.dart';
import 'package:skill_circle_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:skill_circle_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:skill_circle_app/features/storage/data/appwrite_storage_service.dart';
import 'package:skill_circle_app/models/badge_model.dart' as shared_models;

/// Provider for ProfileRepository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final databases = ref.watch(appwriteDatabasesProvider);
  final realtime = ref.watch(appwriteRealtimeProvider);
  final storage = ref.watch(appwriteStorageProvider);
  final config = ref.watch(appwriteStorageConfigProvider);
  final storageService = AppwriteStorageService(
    storage: storage,
    bucketId: config.bucketId,
    endpoint: config.endpoint,
    projectId: config.projectId,
  );
  return AppwriteProfileRepository(
    databases,
    realtime,
    storageService,
    config,
  );
});

/// StateNotifierProvider for profile operations and state
final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<Profile?>>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileController(repository);
});

/// Stream provider for watching profile changes in real-time
final profileStreamProvider = StreamProvider.family<Profile?, String>((
  ref,
  userId,
) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.watchProfile(userId);
});

final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  final authUser = ref.watch(authStateProvider).valueOrNull;
  if (authUser == null) {
    return null;
  }

  final repository = ref.watch(profileRepositoryProvider);
  try {
    return await repository.getUserProfile(authUser.id);
  } catch (_) {
    return null;
  }
});

final userBadgesProvider = FutureProvider.family<List<shared_models.BadgeModel>, String>((ref, userId) async {
  final databases = ref.watch(appwriteDatabasesProvider);
  final config = ref.watch(appwriteStorageConfigProvider);

  // Fetch user posts
  final postsResult = await databases.listDocuments(
    databaseId: config.databaseId,
    collectionId: config.postsCollectionId,
    queries: [Query.equal('userId', userId)],
  );
  
  // Fetch user comments
  final commentsResult = await databases.listDocuments(
    databaseId: config.databaseId,
    collectionId: config.commentsCollectionId,
    queries: [Query.equal('userId', userId)],
  );
  
  // Fetch created circles
  final createdCirclesResult = await databases.listDocuments(
    databaseId: config.databaseId,
    collectionId: config.skillCirclesCollectionId,
    queries: [Query.equal('createdBy', userId)],
  );
  
  // Fetch joined circles
  final joinedCirclesResult = await databases.listDocuments(
    databaseId: config.databaseId,
    collectionId: config.skillCirclesCollectionId,
    queries: [Query.contains('members', userId)],
  );
  
  // Fetch user profile
  final profileResult = await databases.getDocument(
    databaseId: config.databaseId,
    collectionId: config.usersCollectionId,
    documentId: userId,
  );

  final totalPosts = postsResult.documents.length;
  final totalComments = commentsResult.documents.length;
  final totalCreatedCircles = createdCirclesResult.documents.length;
  final totalJoinedCircles = joinedCirclesResult.documents.length;
  final profileData = Map<String, dynamic>.from(profileResult.data as Map);
  final displayName = (profileData['displayName'] as String? ?? '').trim();
  final bio = (profileData['bio'] as String? ?? '').trim();
  final photoUrl = (profileData['photoUrl'] as String? ?? '').trim();

  final totalUpvotes = postsResult.documents.fold<int>(0, (runningTotal, doc) {
    final data = Map<String, dynamic>.from(doc.data as Map);
    final upvotedBy = data['upvotedBy'] as List<dynamic>? ?? [];
    return runningTotal + upvotedBy.length;
  });

  double ratio(int value, int target) => target <= 0 ? 1.0 : (value / target).clamp(0.0, 1.0);

  return <shared_models.BadgeModel>[
    shared_models.BadgeModel(
      id: 'first_post',
      title: 'First Post',
      description: 'Publish your first post',
      iconKey: 'post',
      isLocked: totalPosts == 0,
      progress: ratio(totalPosts, 1),
    ),
    shared_models.BadgeModel(
      id: 'active_member',
      title: 'Active Member',
      description: 'Comment and take part in the community',
      iconKey: 'comment',
      isLocked: totalComments == 0,
      progress: ratio(totalComments, 10),
    ),
    shared_models.BadgeModel(
      id: 'circle_founder',
      title: 'Circle Founder',
      description: 'Create a skill circle',
      iconKey: 'circle',
      isLocked: totalCreatedCircles == 0,
      progress: ratio(totalCreatedCircles, 1),
    ),
    shared_models.BadgeModel(
      id: 'community_builder',
      title: 'Community Builder',
      description: 'Join several circles and stay active',
      iconKey: 'group',
      isLocked: totalJoinedCircles == 0,
      progress: ratio(totalJoinedCircles, 5),
    ),
    shared_models.BadgeModel(
      id: 'top_contributor',
      title: 'Top Contributor',
      description: 'Earn upvotes on your posts',
      iconKey: 'trophy',
      isLocked: totalUpvotes == 0,
      progress: ratio(totalUpvotes, 100),
    ),
    shared_models.BadgeModel(
      id: 'complete_profile',
      title: 'Complete Profile',
      description: 'Add your name, bio, and photo',
      iconKey: 'profile',
      isLocked: !(displayName.isNotEmpty && bio.isNotEmpty && photoUrl.isNotEmpty),
      progress: ratio([
        displayName.isNotEmpty,
        bio.isNotEmpty,
        photoUrl.isNotEmpty,
      ].where((item) => item).length, 3),
    ),
  ];
});
