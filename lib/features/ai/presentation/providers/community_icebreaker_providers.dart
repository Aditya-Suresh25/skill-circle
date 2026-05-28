import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/providers/app_config_provider.dart';
import 'package:skill_circle_app/features/ai/data/gemini_icebreaker_service.dart';

final communityIcebreakerServiceProvider = Provider<GeminiIcebreakerService>((ref) {
  return const GeminiIcebreakerService();
});

class CommunityIcebreakerRequest {
  const CommunityIcebreakerRequest({
    required this.topic,
    required this.interests,
  });

  final String topic;
  final List<String> interests;

  String get _interestSignature => interests.map((value) => value.trim().toLowerCase()).where((value) => value.isNotEmpty).join('|');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommunityIcebreakerRequest && other.topic == topic && other._interestSignature == _interestSignature;
  }

  @override
  int get hashCode => Object.hash(topic, _interestSignature);
}

final communityIcebreakerProvider = FutureProvider.family.autoDispose<List<String>, CommunityIcebreakerRequest>((ref, request) async {
  final config = ref.watch(appConfigProvider);
  final service = ref.watch(communityIcebreakerServiceProvider);
  return service.generateIcebreakers(
    apiKey: config.geminiApiKey,
    communityTopic: request.topic,
    userInterests: request.interests,
  );
});