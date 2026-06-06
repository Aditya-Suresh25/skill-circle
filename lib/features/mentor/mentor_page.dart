import 'package:skill_circle_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_circle_app/core/appwrite.dart';
import 'package:skill_circle_app/core/widgets/glass.dart';
import 'package:skill_circle_app/models/task.dart';

import 'package:skill_circle_app/core/theme.dart';
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
                style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<TaskSubmission>>(
                  future: ref.read(appwriteServiceProvider).getSubmissions(task.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final submissions = snapshot.data ?? [];
                    if (submissions.isEmpty) {
                      return Center(child: Text('No submissions yet.'));
                    }

                    return ListView.builder(
                      itemCount: submissions.length,
                      itemBuilder: (context, index) {
                        final sub = submissions[index];
                        return Card(
                          color: context.textColor.withValues(alpha: 0.05),
                          child: ListTile(
                            title: Text(sub.userName ?? 'Student'),
                            subtitle: Text('Status: ${sub.status.toUpperCase()} | Grade: ${sub.grade ?? 'None'}'),
                            trailing: IconButton(
                              icon: Icon(Icons.grade_rounded, color: AppColors.accentCyan),
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
              title: Text('Grade Submission', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (sub.content?.isNotEmpty ?? false) ...[
                    Text('Notes:', style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 13)),
                    SizedBox(height: 4),
                    Text(sub.content!),
                    SizedBox(height: 12),
                  ],
                  if (sub.attachments.isNotEmpty) ...[
                    Text('Attachment:', style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 13)),
                    SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        sub.attachments.first.url,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                  Text('Grade:', style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () => setModalState(() => grade = 'Pass'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          backgroundColor: grade == 'Pass' ? Colors.green : Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Pass'),
                      ),
                      ElevatedButton(
                        onPressed: () => setModalState(() => grade = 'Needs Work'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          backgroundColor: grade == 'Needs Work' ? Colors.orange : Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Needs Work'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: feedbackController,
                    decoration: const InputDecoration(labelText: 'Feedback notes'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setModalState(() => isSaving = true);
                          await ref.read(appwriteServiceProvider).gradeSubmission(sub.id, grade, feedbackController.text.trim(), sub.userId, sub.taskId);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Submission graded successfully!')));
                          }
                          setModalState(() => isSaving = false);
                        },
                  child: Text('Submit Grade'),
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
        title: Text('Mentor Panel', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
      ),
      body: AuroraBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Mentorship Overview',
                style: GoogleFonts.lexend(fontSize: 22, fontWeight: FontWeight.bold, color: context.textColor),
              ),
              SizedBox(height: 6),
              Text(
                'Track assigned tasks across all circles and view learner submissions.',
                style: GoogleFonts.inter(fontSize: 14, color: context.textColor.withValues(alpha: 0.60)),
              ),
              SizedBox(height: 20),
              Expanded(
                child: tasksAsync.when(
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Failed to load tasks: $err')),
                  data: (tasks) {
                    if (tasks.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.psychology_outlined, size: 64, color: context.textColor.withValues(alpha: 0.25)),
                            SizedBox(height: 12),
                            Text(
                              'No tasks created yet.',
                              style: GoogleFonts.lexend(color: context.textColor.withValues(alpha: 0.5)),
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
                          child: GradientPanel(
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
                                        style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold, color: context.textColor),
                                      ),
                                    ),
                                    Icon(Icons.assignment_turned_in_outlined, color: context.textColor.withValues(alpha: 0.70)),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  task.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(fontSize: 14, color: context.textColor.withValues(alpha: 0.70)),
                                ),
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () => _viewSubmissions(task),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: context.textColor,
                                        side: BorderSide(color: context.textColor.withValues(alpha: 0.20)),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        minimumSize: Size.zero,
                                      ),
                                      child: Text('Check Submissions'),
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
