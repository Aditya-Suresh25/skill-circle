import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/presentation/widgets/aurora_background.dart';
import 'package:skill_circle_app/features/mentor/presentation/providers/mentor_providers.dart';
import 'package:skill_circle_app/features/mentor/presentation/pages/mentor_task_list_page.dart';
import 'package:skill_circle_app/features/mentor/presentation/pages/mentor_task_editor_page.dart';

class MentorDashboardPage extends ConsumerWidget {
  const MentorDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mentorAsync = ref.watch(currentMentorProfileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuroraBackground(
        child: SafeArea(
          child: mentorAsync.when(
            data: (mentor) {
              if (mentor == null) {
                return Center(
                  child: _GlassDashboardCard(
                    title: 'Mentor profile not found',
                    subtitle: 'Complete mentor signup to unlock your control center.',
                    icon: Icons.workspace_premium_outlined,
                    onTap: null,
                  ),
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _GlassHeader(
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: isDark
                                  ? const [Color(0xFFFB7185), Color(0xFFF43F5E)]
                                  : const [Color(0xFFE11D48), Color(0xFF9F1239)],
                            ),
                          ),
                          child: const Icon(Icons.psychology_alt_rounded, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mentor.displayName,
                                style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xFF2B1C3D),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                mentor.bio?.isNotEmpty == true ? mentor.bio! : 'Mentor control center',
                                style: TextStyle(
                                  color: isDark ? const Color(0xFFD6D1E5) : const Color(0xFF63567B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _GlassDashboardCard(
                    title: 'Manage Circles',
                    subtitle: 'Coordinate the circles you mentor and guide community direction.',
                    icon: Icons.groups_3_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  _GlassDashboardCard(
                    title: 'Tasks',
                    subtitle: 'Review open learning tasks and evaluate progress.',
                    icon: Icons.list_alt_rounded,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MentorTaskListPage(circleId: ''))),
                  ),
                  const SizedBox(height: 10),
                  _GlassDashboardCard(
                    title: 'Create Task',
                    subtitle: 'Publish a focused assignment with clear outcomes.',
                    icon: Icons.add_box_rounded,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MentorTaskEditorPage(circleId: ''))),
                  ),
                  const SizedBox(height: 10),
                  _GlassDashboardCard(
                    title: 'Submissions',
                    subtitle: 'Track learner submissions and provide actionable feedback.',
                    icon: Icons.assignment_turned_in_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  _GlassDashboardCard(
                    title: 'Leaderboard',
                    subtitle: 'Highlight top performers and recognize consistency.',
                    icon: Icons.emoji_events_rounded,
                    onTap: () {},
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Failed to load mentor profile')),
          ),
        ),
      ),
    );
  }
}

class _GlassHeader extends StatelessWidget {
  const _GlassHeader({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.white.withValues(alpha: 0.14), Colors.white.withValues(alpha: 0.05)]
                  : [Colors.white.withValues(alpha: 0.72), Colors.white.withValues(alpha: 0.50)],
            ),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.9),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassDashboardCard extends StatelessWidget {
  const _GlassDashboardCard({required this.title, required this.subtitle, required this.icon, this.onTap});

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.white.withValues(alpha: 0.12), Colors.white.withValues(alpha: 0.04)]
                  : [Colors.white.withValues(alpha: 0.66), Colors.white.withValues(alpha: 0.46)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.11) : Colors.white.withValues(alpha: 0.85),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? Colors.white.withValues(alpha: 0.14) : Colors.white.withValues(alpha: 0.8),
                  ),
                  child: Icon(icon, color: isDark ? const Color(0xFFFF8BA7) : const Color(0xFF9F1239)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF2A1B3F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isDark ? const Color(0xFFD8D2E7) : const Color(0xFF665879),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white70 : const Color(0xFF584A70)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
