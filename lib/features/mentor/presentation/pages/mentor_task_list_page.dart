import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/presentation/widgets/aurora_background.dart';
import 'package:skill_circle_app/core/presentation/widgets/glass/glass.dart';
import 'package:skill_circle_app/features/mentor/presentation/providers/mentor_tasks_provider.dart';
import 'package:skill_circle_app/features/mentor/presentation/pages/mentor_task_editor_page.dart';

class MentorTaskListPage extends ConsumerWidget {
  const MentorTaskListPage({super.key, required this.circleId});

  final String circleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(mentorTasksProvider(circleId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF2A1C3F);
    final subtitleColor = isDark ? const Color(0xFFD6D0E6) : const Color(0xFF66587D);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Tasks'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MentorTaskEditorPage(circleId: circleId))),
        child: const Icon(Icons.add),
      ),
      body: AuroraBackground(
        child: tasksAsync.when(
          data: (tasks) {
            if (tasks.isEmpty) {
              return Padding(
                padding: GlassTokens.pagePadding,
                child: GlassPageHeader(
                  title: 'Task Board',
                  subtitle: 'No tasks yet. Create your first milestone to guide learners in this circle.',
                ),
              );
            }
            return ListView.separated(
              padding: GlassTokens.pagePadding,
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final t = tasks[index];
                return GlassPanel(
                  useAnimatedEntrance: true,
                  child: ListTile(
                    title: Text(
                      t.title,
                      style: TextStyle(fontWeight: FontWeight.w700, color: titleColor),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        t.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: subtitleColor),
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.16) : Colors.white.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        t.difficulty,
                        style: TextStyle(
                          color: isDark ? const Color(0xFFE5D9FF) : const Color(0xFF5B21B6),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => MentorTaskEditorPage(circleId: circleId, task: t)),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Failed to load tasks: $e')),
        ),
      ),
    );
  }
}
