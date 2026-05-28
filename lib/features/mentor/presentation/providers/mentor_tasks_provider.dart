import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/features/mentor/domain/entities/task.dart';
import 'package:skill_circle_app/features/mentor/presentation/providers/mentor_providers.dart';

final mentorTasksProvider = StreamProvider.family<List<MentorTask>, String>((ref, circleId) {
  final repo = ref.read(mentorRepositoryProvider);
  return repo.watchTasksForCircle(circleId);
});
