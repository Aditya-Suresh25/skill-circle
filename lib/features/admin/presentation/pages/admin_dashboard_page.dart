import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/presentation/widgets/aurora_background.dart';
import 'package:skill_circle_app/core/presentation/widgets/glass/glass.dart';
import 'package:skill_circle_app/features/admin/presentation/providers/admin_dashboard_provider.dart';
import 'package:skill_circle_app/features/admin/presentation/providers/admin_providers.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF2A1A3D);
    final subtitleColor = isDark ? const Color(0xFFD2CCE2) : const Color(0xFF66577F);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuroraBackground(
        child: SafeArea(
          child: statsAsync.when(
            data: (stats) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Command Center',
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Monitor platform health, moderate content, and manage core entities.',
                          style: TextStyle(color: subtitleColor, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SummaryCard(
                    title: 'Users',
                    value: stats.users,
                    icon: Icons.people_alt_rounded,
                  ),
                  const SizedBox(height: 12),
                  _SummaryCard(
                    title: 'Circles',
                    value: stats.circles,
                    icon: Icons.hub_rounded,
                  ),
                  const SizedBox(height: 12),
                  _SummaryCard(
                    title: 'Posts',
                    value: stats.posts,
                    icon: Icons.forum_rounded,
                  ),
                  const SizedBox(height: 12),
                  _SummaryCard(
                    title: 'Comments',
                    value: stats.comments,
                    icon: Icons.chat_bubble_outline_rounded,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Quick controls',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: titleColor),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: const [
                      _ActionChip(label: 'Manage Users', icon: Icons.manage_accounts_rounded),
                      _ActionChip(label: 'Manage Circles', icon: Icons.hub_rounded),
                      _ActionChip(label: 'Moderate Posts', icon: Icons.flag_rounded),
                      _ActionChip(label: 'View Reports', icon: Icons.analytics_rounded),
                    ],
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(child: Text('Failed to load admin dashboard: $error')),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassPanel(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.white.withValues(alpha: 0.16) : Colors.white.withValues(alpha: 0.84),
            ),
            child: Icon(icon, size: 24, color: isDark ? const Color(0xFFC084FC) : const Color(0xFF6D28D9)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF2A1B3C),
              ),
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF2A1B3C),
            ),
          ),
        ],
      ),
    );
  }
}


class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ActionChip(
      avatar: Icon(icon, size: 18, color: isDark ? const Color(0xFFD2C5F7) : const Color(0xFF5B21B6)),
      side: BorderSide(
        color: isDark ? Colors.white.withValues(alpha: 0.16) : Colors.white.withValues(alpha: 0.84),
      ),
      backgroundColor: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.72),
      label: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF321C49),
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: () => _openActionSheet(context),
    );
  }

  void _openActionSheet(BuildContext context) {
    switch (label) {
      case 'Manage Users':
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (sheetContext) => _UsersSheet(),
        );
        break;
      case 'Manage Circles':
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (sheetContext) => _CirclesSheet(),
        );
        break;
      case 'Moderate Posts':
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (sheetContext) => _PostsSheet(),
        );
        break;
      case 'View Reports':
      default:
        showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Reports'),
            content: const Text('Reports are powered by the live counts above. More detailed analytics can be added next.'),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Close')),
            ],
          ),
        );
    }
  }
}

class _UsersSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return Material(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: usersAsync.when(
              data: (users) => ListView.separated(
                controller: controller,
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.person_outline_rounded),
                      title: Text(user.displayName),
                      subtitle: Text('${user.email}\nRole: ${user.role}'),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Failed to load users: $error')),
            ),
          ),
        );
      },
    );
  }
}

class _CirclesSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circlesAsync = ref.watch(adminCirclesProvider);
    final adminRepo = ref.read(adminRepositoryProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return Material(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: circlesAsync.when(
              data: (circles) => ListView.separated(
                controller: controller,
                itemCount: circles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final circle = circles[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.hub_rounded),
                      title: Text(circle.title),
                      subtitle: Text(circle.description),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await adminRepo.deleteCircle(circle.id);
                          ref.invalidate(adminCirclesProvider);
                          ref.invalidate(adminDashboardStatsProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Circle deleted')));
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Failed to load circles: $error')),
            ),
          ),
        );
      },
    );
  }
}

class _PostsSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(adminPostsProvider);
    final adminRepo = ref.read(adminRepositoryProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return Material(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: postsAsync.when(
              data: (posts) => ListView.separated(
                controller: controller,
                itemCount: posts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.forum_rounded),
                      title: Text(post.username),
                      subtitle: Text(post.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await adminRepo.deletePost(post.id);
                          ref.invalidate(adminPostsProvider);
                          ref.invalidate(adminDashboardStatsProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post deleted')));
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Failed to load posts: $error')),
            ),
          ),
        );
      },
    );
  }
}
