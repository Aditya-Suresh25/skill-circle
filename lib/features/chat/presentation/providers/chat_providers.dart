import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/providers/appwrite_storage_providers.dart';
import 'package:skill_circle_app/features/chat/data/repositories/chat_repository.dart';
import 'package:skill_circle_app/features/chat/domain/entities/channel.dart';
import 'package:skill_circle_app/features/chat/domain/entities/message.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(
    ref.read(appwriteDatabasesProvider),
    ref.read(appwriteRealtimeProvider),
    ref.read(appwriteStorageConfigProvider),
  );
});

final channelsStreamProvider = StreamProvider.family<List<Channel>, String>((ref, circleId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.watchChannels(circleId);
});

final messagesStreamProvider = StreamProvider.family<List<Message>, Map<String, String>>((ref, params) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.watchMessages(params['circleId']!, params['channelId']!);
});
