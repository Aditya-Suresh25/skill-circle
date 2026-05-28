import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skill_circle_app/core/constants/app_routes.dart';
import 'package:skill_circle_app/core/presentation/widgets/aurora_background.dart';
import 'package:skill_circle_app/core/presentation/widgets/glass/glass.dart';
import 'package:skill_circle_app/features/ai/presentation/widgets/community_icebreaker_panel.dart';
import 'package:skill_circle_app/features/posts/presentation/providers/posts_providers.dart';
import 'package:skill_circle_app/features/skill_circles/presentation/providers/skill_circles_providers.dart';
import 'package:skill_circle_app/utils/color_theme.dart';
import 'package:skill_circle_app/features/auth/domain/entities/app_user.dart';
import 'package:skill_circle_app/features/skill_circles/domain/entities/skill_circle.dart';
import 'package:skill_circle_app/features/posts/presentation/pages/posts_page.dart';
import 'package:skill_circle_app/features/posts/presentation/widgets/post_composer.dart';
import 'package:skill_circle_app/features/chat/presentation/providers/chat_providers.dart';
import 'package:skill_circle_app/features/chat/presentation/pages/chat_screen.dart';
import 'package:skill_circle_app/features/profile/presentation/providers/profile_providers.dart';

class CircleDetailScreen extends ConsumerWidget {
  const CircleDetailScreen({super.key, required this.circleId});

  final String circleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final skillCirclesState = ref.watch(skillCirclesControllerProvider);

    if (skillCirclesState.circles.isEmpty && !skillCirclesState.isLoading) {
      Future.microtask(() => ref.read(skillCirclesControllerProvider.notifier).loadInitial());
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Circle'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: AuroraBackground(
        child: skillCirclesState.circles.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _buildCircleView(context, ref, currentUser, skillCirclesState.circles),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPostComposer(context, currentUser),
        child: const Icon(Icons.add_comment_rounded),
      ),
    );
  }

  Widget _buildCircleView(BuildContext context, WidgetRef ref, currentUser, List<SkillCircle> circles) {
    final matches = circles.where((c) => c.id == circleId);
    
    if (matches.isEmpty) {
      return const Center(child: Text('Circle not found'));
    }

    final circle = matches.first;
    final memberCount = circle.members.length;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF2A1D3D);
    final subtitleColor = isDark ? const Color(0xFFD6CFE5) : const Color(0xFF66587D);

    return DefaultTabController(
      length: 2,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          if (circle.bannerUrl != null && circle.bannerUrl!.isNotEmpty)
            SliverToBoxAdapter(
              child: Image.network(
                circle.bannerUrl!,
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: const Color(0xFFE9D5FF),
                          backgroundImage: circle.imageUrl != null && circle.imageUrl!.isNotEmpty
                              ? NetworkImage(circle.imageUrl!)
                              : null,
                          child: circle.imageUrl == null || circle.imageUrl!.isEmpty
                              ? Text(
                                  circle.title.isNotEmpty ? circle.title[0].toUpperCase() : '?',
                                  style: const TextStyle(fontSize: 20, color: Color(0xFF6D28D9)),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                circle.title,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: titleColor),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                circle.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: subtitleColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          children: [
                            Text('$memberCount', style: TextStyle(fontWeight: FontWeight.w700, color: titleColor)),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 84,
                              child: OutlinedButton(
                                onPressed: () {},
                                child: const Text('Join'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Members', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: titleColor)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: circle.members.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return _MemberAvatar(userId: circle.members[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: CommunityIcebreakerPanel(communityTopic: circle.title),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: GlassPanel(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: TabBar(
                  labelColor: titleColor,
                  unselectedLabelColor: subtitleColor,
                  tabs: const [Tab(text: 'Channels'), Tab(text: 'Posts')],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          children: [
            _ChannelsTab(circleId: circleId),
            PostsPage(circleId: circleId),
          ],
        ),
      ),
    );
  }

  void _showPostComposer(BuildContext context, AppUser? currentUser) async {
    if (currentUser == null) {
      if (context.mounted) context.go(AppRoutes.login);
      return;
    }
    if (!context.mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: PostComposer(
            circleId: circleId,
            onSubmitted: () => Navigator.of(sheetContext).pop(),
          ),
        );
      },
    );
  }
}

class _ChannelsTab extends ConsumerWidget {
  const _ChannelsTab({required this.circleId});

  final String circleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelsAsync = ref.watch(channelsStreamProvider(circleId));

    return channelsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text('Error: $err')),
      data: (channels) {
        if (channels.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No channels yet.'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _showCreateChannelDialog(context, ref),
                  child: const Text('Create Channel'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: channels.length,
          itemBuilder: (context, index) {
            final channel = channels[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassPanel(
                child: ListTile(
                  leading: const Icon(Icons.tag_rounded),
                  title: Text(channel.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(channel.description),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChatScreen(circleId: circleId, channel: channel),
                    ));
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateChannelDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Channel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Channel Name', prefixText: '# '),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;
              await ref.read(chatRepositoryProvider).createChannel(circleId, nameCtrl.text.trim(), description: descCtrl.text.trim());
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _MemberAvatar extends ConsumerWidget {
  const _MemberAvatar({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileStreamProvider(userId));

    return profileAsync.when(
      loading: () => const CircleAvatar(radius: 20, backgroundColor: Colors.white24, child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))),
      error: (_, __) => const CircleAvatar(radius: 20, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white, size: 20)),
      data: (profile) {
        if (profile == null) {
          return const CircleAvatar(radius: 20, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white, size: 20));
        }
        
        if (profile.photoUrl != null && profile.photoUrl!.isNotEmpty) {
          return Tooltip(
            message: profile.displayName,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white24,
              backgroundImage: NetworkImage(profile.photoUrl!),
            ),
          );
        }
        
        return Tooltip(
          message: profile.displayName,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: ClayTokens.brandDeep,
            child: Text(
              profile.displayName.isNotEmpty ? profile.displayName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}

