import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skill_circle_app/core/constants/app_routes.dart';
import 'package:skill_circle_app/core/theme/theme_mode_provider.dart';
import 'package:skill_circle_app/features/comments/presentation/providers/comments_providers.dart';
import 'package:skill_circle_app/features/posts/presentation/providers/posts_providers.dart';
import 'package:skill_circle_app/features/profile/presentation/providers/profile_providers.dart';
import 'package:skill_circle_app/features/skill_circles/domain/entities/skill_circle.dart';
import 'package:skill_circle_app/features/skill_circles/presentation/providers/skill_circles_aurora_providers.dart' as circles;
import 'package:skill_circle_app/models/badge_model.dart' as shared_models;
import 'package:skill_circle_app/models/comment_model.dart' as shared_models_comment;

class SkillCirclesPage extends ConsumerStatefulWidget {
  const SkillCirclesPage({super.key});

  @override
  ConsumerState<SkillCirclesPage> createState() => _SkillCirclesPageState();
}

class _SkillCirclesPageState extends ConsumerState<SkillCirclesPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(circles.skillCirclesControllerProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(circles.skillCirclesControllerProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final currentUser = ref.watch(currentUserProvider);
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    final badges = currentUser == null ? const <shared_models.BadgeModel>[] : ref.watch(userBadgesProvider(currentUser.id)).valueOrNull ?? const <shared_models.BadgeModel>[];
    final recentComments = ref.watch(recentCommentsProvider).valueOrNull ?? const <shared_models_comment.CommentModel>[];
    final circlesList = state.circles;
    final filtered = _searchController.text.isEmpty
      ? circlesList
      : circlesList.where((circle) => circle.title.toLowerCase().contains(_searchController.text.toLowerCase())).toList(growable: false);
    final trending = circlesList.take(3).toList(growable: false);
    final joinedSkills = profile?.joinedSkills ?? const <String>[];
    final joinedCircleCount = currentUser == null ? 0 : circlesList.where((circle) => circle.members.contains(currentUser.id)).length;
    final unlockedBadgeCount = badges.where((badge) => !badge.isLocked).length;
    final heroProgress = _buildHeroProgress(joinedSkills: joinedSkills, circlesList: circlesList, joinedCircleCount: joinedCircleCount, unlockedBadgeCount: unlockedBadgeCount, recentCommentCount: recentComments.length);
    final recentDiscussions = _buildRecentDiscussions(recentComments);
    final activeMembers = _buildActiveMembers(recentComments);
    final recommended = _buildRecommendedCircles(circlesList, joinedSkills);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF7F3FF),
      floatingActionButton: _GlassActionButton(
        label: 'Create Circle',
        icon: Icons.add_rounded,
        onTap: () async {
          final created = await context.push<bool>(AppRoutes.createCircle);
          if (!mounted || created != true) return;

          ref.invalidate(circles.allCirclesStreamProvider);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Skill circle added to your feed')));
        },
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _AuroraBackdrop(vivid: isDark, isDark: isDark)),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        _HeaderBadge(
                          title: 'Skill Circle',
                          subtitle: 'AI-powered growth workspace',
                        ),
                        const Spacer(),
                        _GlassToggle(
                          value: isDark,
                          onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: _HeroCard(
                      title: 'Your Learning Snapshot',
                      subtitle: 'Live community signals from your profile, circles, badges, and activity.',
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth > 420;
                          return Column(
                            children: [
                              GridView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: heroProgress.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: wide ? 4 : 2,
                                  childAspectRatio: wide ? 0.78 : 0.90,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemBuilder: (context, index) {
                                  final item = heroProgress[index];
                                  return _SkillRingCard(data: item);
                                },
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _MiniStat(
                                      label: 'Joined circles',
                                      value: '$joinedCircleCount',
                                      icon: Icons.local_fire_department_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _MiniStat(
                                      label: 'Unlocked badges',
                                      value: '$unlockedBadgeCount',
                                      icon: Icons.verified_rounded,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: _SectionHeader(
                      title: 'Trending Skill Circles',
                      subtitle: 'The most active circles right now.',
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      height: 136,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: trending.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final item = trending[index];
                          return _TrendingTile(circle: item);
                        },
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: _SectionHeader(
                      title: 'Recent Discussions',
                      subtitle: 'Latest live comments from the community.',
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  sliver: SliverList.builder(
                    itemCount: recentDiscussions.length,
                    itemBuilder: (context, index) {
                      final discussion = recentDiscussions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _DiscussionCard(
                          title: discussion['title']!,
                          meta: discussion['meta']!,
                        ),
                      );
                    },
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: _SectionHeader(
                      title: 'Active Voices',
                      subtitle: 'People who have been posting most recently.',
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: activeMembers.isEmpty
                          ? const [
                              _MemberChip(name: 'Skill Circle', role: 'Start posting to appear here'),
                            ]
                          : activeMembers.map((member) => _MemberChip(name: member.name, role: member.role)).toList(growable: false),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  sliver: SliverToBoxAdapter(
                    child: _SectionHeader(
                      title: 'Recommended Communities',
                      subtitle: 'Suggested circles based on your skills and live activity.',
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      height: 132,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: recommended.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) => _TrendingTile(circle: recommended[index]),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  sliver: SliverToBoxAdapter(
                    child: _SectionHeader(
                      title: 'Community Circles',
                      subtitle: 'Discover translucent communities with live progress and ambient glow.',
                      trailing: SizedBox(
                        width: 150,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search',
                            prefixIcon: const Icon(Icons.search_rounded, size: 18),
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.06),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (state.isLoading)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) => const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: _CircleSkeletonCard(),
                      ),
                    ),
                  )
                else if (filtered.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 48),
                      child: Center(
                        child: Text('No circles found.', style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    sliver: SliverList.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final circle = filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _GlassCircleCard(
                            circle: circle,
                            onTap: () {
                              context.push('/skill-circles/${circle.id}');
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuroraBackdrop extends StatelessWidget {
  const _AuroraBackdrop({required this.vivid, required this.isDark});

  final bool vivid;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDark ? const Color(0xFF06060A) : const Color(0xFFF8F5FF),
                  isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF4EEFF),
                  isDark ? const Color(0xFF131320) : const Color(0xFFF1E9FF),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -120,
          left: -80,
          child: _GlowBlob(color: const Color(0xFF8B5CF6).withValues(alpha: vivid ? 0.35 : 0.18), size: 320),
        ),
        Positioned(
          top: 120,
          right: -90,
          child: _GlowBlob(color: const Color(0xFFC084FC).withValues(alpha: vivid ? 0.28 : 0.14), size: 260),
        ),
        Positioned(
          bottom: -120,
          left: 30,
          child: _GlowBlob(color: const Color(0xFFA855F7).withValues(alpha: vivid ? 0.28 : 0.12), size: 300),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0.10,
            child: CustomPaint(painter: _NoisePainter()),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Stack(
              children: List.generate(16, (index) {
                final left = (index * 43) % 360.0;
                final top = (index * 77) % 640.0;
                return Positioned(
                  left: left,
                  top: top,
                  child: Container(
                    width: index.isEven ? 4 : 2,
                    height: index.isEven ? 4 : 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: index.isEven ? 0.25 : 0.12),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFC084FC).withValues(alpha: 0.25), blurRadius: 18, spreadRadius: 3),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    const gap = 22.0;
    for (var y = 0.0; y < size.height; y += gap) {
      for (var x = 0.0; x < size.width; x += gap) {
        if (((x + y) ~/ gap) % 4 == 0) {
          canvas.drawCircle(Offset(x + 2, y + 3), 0.65, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(color: color, blurRadius: 120, spreadRadius: 24),
          ],
        ),
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: Color(0xFFB9B9CE), fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassToggle extends StatelessWidget {
  const _GlassToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: 84,
            height: 44,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              boxShadow: [
                BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.18), blurRadius: 24, spreadRadius: 2),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Icon(Icons.dark_mode_rounded, size: 16, color: value ? Colors.white54 : Colors.white),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(Icons.light_mode_rounded, size: 16, color: value ? Colors.white : Colors.white54),
                  ),
                ),
                AnimatedAlign(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [Color(0xFFC084FC), Color(0xFF8B5CF6)]),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.45), blurRadius: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.title, required this.subtitle, required this.child});

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.10),
                Colors.white.withValues(alpha: 0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            boxShadow: [
              BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.12), blurRadius: 40, spreadRadius: 2),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.6)),
              const SizedBox(height: 8),
              Text(subtitle, style: const TextStyle(color: Color(0xFFC8C8D9), height: 1.4)),
              const SizedBox(height: 18),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillProgressData {
  const _SkillProgressData({required this.label, required this.subtitle, required this.value, required this.accent, required this.icon});

  final String label;
  final String subtitle;
  final double value;
  final Color accent;
  final IconData icon;
}

class _SkillRingCard extends StatelessWidget {
  const _SkillRingCard({required this.data});

  final _SkillProgressData data;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: data.value),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return _RingGlass(
          accent: data.accent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: data.accent.withValues(alpha: 0.22), blurRadius: 34, spreadRadius: 6),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 102,
                    height: 102,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 10,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      strokeCap: StrokeCap.round,
                      valueColor: AlwaysStoppedAnimation<Color>(data.accent),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(data.icon, color: Colors.white, size: 20),
                      const SizedBox(height: 6),
                      Text('${(value * 100).round()}%', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(data.label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(data.subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFBEBED1), fontSize: 11)),
            ],
          ),
        );
      },
    );
  }
}

class _RingGlass extends StatelessWidget {
  const _RingGlass({required this.child, required this.accent});

  final Widget child;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 218,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.10),
                Colors.white.withValues(alpha: 0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            boxShadow: [
              BoxShadow(color: accent.withValues(alpha: 0.12), blurRadius: 28, spreadRadius: 2),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFFC084FC), Color(0xFF8B5CF6)]),
                  boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.35), blurRadius: 18)],
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Color(0xFFBEBED1), fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle, this.trailing});

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Color(0xFFB8B8CB), height: 1.35)),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing!,
        ],
      ],
    );
  }
}

class _TrendingTile extends StatelessWidget {
  const _TrendingTile({required this.circle});

  final SkillCircle circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.10),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(circle.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          Text(circle.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFC1C1D4), fontSize: 12)),
          Text('${circle.memberCount} active members', style: const TextStyle(color: Color(0xFFE3D8FF), fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _DiscussionCard extends StatelessWidget {
  const _DiscussionCard({required this.title, required this.meta});

  final String title;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(meta, style: const TextStyle(color: Color(0xFFBFBFD2), fontSize: 12)),
        ],
      ),
    );
  }
}

class _MemberChip extends StatelessWidget {
  const _MemberChip({required this.name, required this.role});

  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFFC084FC), Color(0xFF8B5CF6)]),
            ),
            alignment: Alignment.center,
            child: Text(name[0], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          Text('$name • $role', style: const TextStyle(color: Color(0xFFEAEAFF), fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _CircleSkeletonCard extends StatefulWidget {
  const _CircleSkeletonCard();

  @override
  State<_CircleSkeletonCard> createState() => _CircleSkeletonCardState();
}

class _CircleSkeletonCardState extends State<_CircleSkeletonCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.35, end: 0.70).animate(_controller),
      child: Container(
        height: 114,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
      ),
    );
  }
}

class _GlassCircleCard extends StatelessWidget {
  const _GlassCircleCard({required this.circle, this.onTap});

  final SkillCircle circle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.10),
                  Colors.white.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CircleAvatar(circle: circle),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(circle.title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                          ),
                          const _StatusPill(text: 'Open'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(circle.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFC1C1D4), height: 1.35)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _MemberCount(count: circle.memberCount),
                          const Spacer(),
                          SizedBox(
                            width: 92,
                            child: ElevatedButton(
                              onPressed: onTap,
                              child: const Text('Explore'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleAvatar extends StatelessWidget {
  const _CircleAvatar({required this.circle});

  final SkillCircle circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: [Color(0xFF1F1833), Color(0xFF0F1020)]),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.22), blurRadius: 24, spreadRadius: 2)],
        image: circle.imageUrl != null && circle.imageUrl!.isNotEmpty
            ? DecorationImage(image: NetworkImage(circle.imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: circle.imageUrl == null || circle.imageUrl!.isEmpty
          ? Center(
              child: Text(
                circle.title.isNotEmpty ? circle.title[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
              ),
            )
          : null,
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFFE8E8F6), fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _MemberCount extends StatelessWidget {
  const _MemberCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Text('$count members', style: const TextStyle(color: Color(0xFFAEAECA), fontSize: 12, fontWeight: FontWeight.w600));
  }
}

class _GlassActionButton extends StatelessWidget {
  const _GlassActionButton({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white.withValues(alpha: 0.10), Colors.white.withValues(alpha: 0.05)],
            ),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.24), blurRadius: 28)],
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CommunityVoice {
  const _CommunityVoice({required this.name, required this.role});

  final String name;
  final String role;
}

List<_SkillProgressData> _buildHeroProgress({
  required List<String> joinedSkills,
  required List<SkillCircle> circlesList,
  required int joinedCircleCount,
  required int unlockedBadgeCount,
  required int recentCommentCount,
}) {
  final colors = <Color>[
    const Color(0xFFC084FC),
    const Color(0xFFA855F7),
    const Color(0xFF8B5CF6),
    const Color(0xFFB794F4),
  ];
  final icons = <IconData>[
    Icons.palette_outlined,
    Icons.code_rounded,
    Icons.auto_fix_high_rounded,
    Icons.record_voice_over_rounded,
  ];

  final sourceLabels = joinedSkills.isNotEmpty
      ? joinedSkills
      : circlesList.isNotEmpty
          ? circlesList.take(4).map((circle) => circle.title).toList(growable: false)
          : const <String>['Explore', 'Connect', 'Build', 'Share'];

  return List.generate(sourceLabels.take(4).length, (index) {
    final label = sourceLabels[index];
    final matchingCircles = circlesList.where((circle) => _matchesTopic(circle, label)).length;
    final score = joinedSkills.isNotEmpty
        ? (0.35 + (matchingCircles * 0.15)).clamp(0.35, 1.0)
        : circlesList.isEmpty
            ? 0.45
            : (0.35 + (circlesList[index % circlesList.length].memberCount / 100.0)).clamp(0.35, 1.0);

    final subtitle = matchingCircles > 0
        ? '$matchingCircles matching circles'
        : index == 0
            ? '$joinedCircleCount joined circles'
            : index == 1
                ? '$unlockedBadgeCount badges unlocked'
                : '$recentCommentCount recent comments';

    return _SkillProgressData(
      label: label,
      subtitle: subtitle,
      value: score,
      accent: colors[index % colors.length],
      icon: icons[index % icons.length],
    );
  }, growable: false);
}

List<Map<String, String>> _buildRecentDiscussions(List<shared_models_comment.CommentModel> comments) {
  if (comments.isEmpty) {
    return const <Map<String, String>>[];
  }

  return comments.reversed.take(3).map((comment) {
    final text = comment.text.trim();
    final title = text.length > 52 ? '${text.substring(0, 52).trimRight()}…' : text;
    final postRef = comment.postId.isEmpty ? 'community thread' : 'post ${comment.postId.length > 6 ? comment.postId.substring(0, 6) : comment.postId}';
    return <String, String>{
      'title': title.isEmpty ? 'New community comment' : title,
      'meta': '${comment.username.isEmpty ? 'Someone' : comment.username} • ${_formatRelativeTime(comment.timestamp)} • $postRef',
    };
  }).toList(growable: false);
}

List<_CommunityVoice> _buildActiveMembers(List<shared_models_comment.CommentModel> comments) {
  final seen = <String>{};
  final voices = <_CommunityVoice>[];

  for (final comment in comments.reversed) {
    final name = comment.username.trim();
    if (name.isEmpty) {
      continue;
    }
    final key = name.toLowerCase();
    if (seen.add(key)) {
      voices.add(
        _CommunityVoice(
          name: name,
          role: 'Active ${_formatRelativeTime(comment.timestamp)}',
        ),
      );
    }
    if (voices.length == 4) {
      break;
    }
  }

  return voices;
}

List<SkillCircle> _buildRecommendedCircles(List<SkillCircle> circlesList, List<String> joinedSkills) {
  final ranked = circlesList.toList(growable: false);
  ranked.sort((a, b) {
    final scoreA = _circleMatchScore(a, joinedSkills);
    final scoreB = _circleMatchScore(b, joinedSkills);
    return scoreB.compareTo(scoreA);
  });
  return ranked.take(3).toList(growable: false);
}

int _circleMatchScore(SkillCircle circle, List<String> joinedSkills) {
  final title = circle.title.toLowerCase();
  final description = circle.description.toLowerCase();
  var score = circle.memberCount;

  for (final skill in joinedSkills) {
    final normalized = skill.toLowerCase();
    if (title.contains(normalized)) {
      score += 100;
    }
    if (description.contains(normalized)) {
      score += 40;
    }
  }

  return score;
}

bool _matchesTopic(SkillCircle circle, String topic) {
  final normalized = topic.toLowerCase();
  return circle.title.toLowerCase().contains(normalized) || circle.description.toLowerCase().contains(normalized);
}

String _formatRelativeTime(DateTime timestamp) {
  final difference = DateTime.now().difference(timestamp);
  if (difference.inMinutes < 1) return 'just now';
  if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
  if (difference.inHours < 24) return '${difference.inHours}h ago';
  return '${difference.inDays}d ago';
}