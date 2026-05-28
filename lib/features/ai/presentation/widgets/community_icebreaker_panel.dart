import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/presentation/widgets/glass/glass.dart';
import 'package:skill_circle_app/features/ai/presentation/providers/community_icebreaker_providers.dart';
import 'package:skill_circle_app/features/profile/presentation/providers/profile_providers.dart';

class CommunityIcebreakerPanel extends ConsumerWidget {
  const CommunityIcebreakerPanel({super.key, required this.communityTopic});

  final String communityTopic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final interests = profileAsync.valueOrNull?.joinedSkills ?? const <String>[];
    final request = CommunityIcebreakerRequest(topic: communityTopic, interests: interests);
    final questionsAsync = ref.watch(communityIcebreakerProvider(request));

    return GlassPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)]),
                  boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.28), blurRadius: 18)],
                ),
                child: const Icon(Icons.bolt_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Icebreaker ideas',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Gemini generates three short conversation starters.',
                      style: TextStyle(color: Color(0xFFB8B8CB), height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Regenerate',
                onPressed: () => ref.invalidate(communityIcebreakerProvider(request)),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (questionsAsync.isLoading)
            const _LoadingQuestions()
          else if (questionsAsync.hasError)
            _ErrorState(
              onRetry: () => ref.invalidate(communityIcebreakerProvider(request)),
            )
          else
            _QuestionList(
              questions: questionsAsync.valueOrNull ?? const <String>[],
              onQuestionTap: (question) async {
                await Clipboard.setData(ClipboardData(text: question));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Question copied')),
                );
              },
            ),
          if (interests.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: interests
                  .take(3)
                  .map(
                    (interest) => Chip(
                      label: Text(interest),
                      labelStyle: const TextStyle(color: Colors.white),
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuestionList extends StatelessWidget {
  const _QuestionList({required this.questions, required this.onQuestionTap});

  final List<String> questions;
  final ValueChanged<String> onQuestionTap;

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Text(
        'No icebreakers yet. Try regenerate.',
        style: TextStyle(color: Color(0xFFB8B8CB)),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: questions
          .map(
            (question) => InkWell(
              onTap: () => onQuestionTap(question),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                constraints: const BoxConstraints(minHeight: 56, minWidth: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Text(
                  question,
                  style: const TextStyle(fontWeight: FontWeight.w600, height: 1.3),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _LoadingQuestions extends StatelessWidget {
  const _LoadingQuestions();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        LinearProgressIndicator(minHeight: 2),
        SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Generating fresh questions...', style: TextStyle(color: Color(0xFFB8B8CB))),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Could not reach Gemini. Using a local fallback next refresh.',
            style: TextStyle(color: Color(0xFFB8B8CB)),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}