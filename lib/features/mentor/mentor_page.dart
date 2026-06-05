import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_circle_app/core/appwrite.dart';
import 'package:skill_circle_app/core/widgets/glass.dart';
import 'package:skill_circle_app/models/task.dart';

final mentorTasksProvider = FutureProvider.autoDispose<List<MentorTask>>((ref) async {
  final service = ref.watch(appwriteServiceProvider);
  final circles = await service.getCircles();
  
  final allTasks = <MentorTask>[];
  for (final circle in circles) {
    try {
      final tasks = await service.getTasks(circle.circleId);
      allTasks.addAll(tasks);
    } catch (_) {}
  }
  return allTasks;
});

class MentorPage extends ConsumerStatefulWidget {
  const MentorPage({super.key});

  @override
  ConsumerState<MentorPage> createState() => _MentorPageState();
}

class _MentorPageState extends ConsumerState<MentorPage> {
  void _viewSubmissions(MentorTask task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Submissions for: ${task.title}',
                style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<TaskSubmission>>(
                  future: ref.read(appwriteServiceProvider).getSubmissions(task.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final submissions = snapshot.data ?? [];
                    if (submissions.isEmpty) {
                      return const Center(child: Text('No submissions yet.'));
                    }

                    return ListView.builder(
                      itemCount: submissions.length,
                      itemBuilder: (context, index) {
                        final sub = submissions[index];
                        return Card(
                          color: Colors.white.withValues(alpha: 0.05),
                          child: ListTile(
                            title: Text(sub.userName ?? 'Student'),
                            subtitle: Text('Status: ${sub.status.toUpperCase()} | Grade: ${sub.grade ?? 'None'}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.grade_rounded, color: Color(0xFFC084FC)),
                              onPressed: () {
                                Navigator.pop(context);
                                _showGradingDialog(sub);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGradingDialog(TaskSubmission sub) {
    final feedbackController = TextEditingController();
    String grade = 'Pass';
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text('Grade Submission', style: GoogleFonts.sora(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () => setModalState(() => grade = 'Pass'),
                        style: ElevatedButton.styleFrom(backgroundColor: grade == 'Pass' ? Colors.green : Colors.grey),
                        child: const Text('Pass'),
                      ),
                      ElevatedButton(
                        onPressed: () => setModalState(() => grade = 'Needs Work'),
                        style: ElevatedButton.styleFrom(backgroundColor: grade == 'Needs Work' ? Colors.orange : Colors.grey),
                        child: const Text('Needs Work'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: feedbackController,
                    decoration: const InputDecoration(labelText: 'Feedback notes'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setModalState(() => isSaving = true);
                          await ref.read(appwriteServiceProvider).gradeSubmission(sub.id, grade, feedbackController.text.trim());
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Submission graded successfully!')));
                          }
                          setModalState(() => isSaving = false);
                        },
                  child: const Text('Submit Grade'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(mentorTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Mentor Panel', style: GoogleFonts.sora(fontWeight: FontWeight.bold)),
      ),
      body: AuroraBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Mentorship Overview',
                style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Track assigned tasks across all circles and view learner submissions.',
                style: GoogleFonts.outfit(fontSize: 14, color: Colors.white.withValues(alpha: 0.60)),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: tasksAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Failed to load tasks: $err')),
                  data: (tasks) {
                    if (tasks.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.psychology_outlined, size: 64, color: Colors.white.withValues(alpha: 0.25)),
                            const SizedBox(height: 12),
                            Text(
                              'No tasks created yet.',
                              style: GoogleFonts.sora(color: Colors.white.withValues(alpha: 0.5)),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: GlassPanel(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        task.title,
                                        style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ),
                                    Icon(Icons.assignment_turned_in_outlined, color: const Color(0xFFC084FC).withValues(alpha: 0.70)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  task.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(fontSize: 14, color: Colors.white.withValues(alpha: 0.70)),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () => _viewSubmissions(task),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: BorderSide(color: Colors.white.withValues(alpha: 0.20)),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        minimumSize: Size.zero,
                                      ),
                                      child: const Text('Check Submissions'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
