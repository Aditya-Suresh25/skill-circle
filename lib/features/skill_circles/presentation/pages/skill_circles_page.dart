import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skill_circle_app/core/constants/app_routes.dart';
import 'package:skill_circle_app/features/skill_circles/presentation/providers/skill_circles_providers.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

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
    Future.microtask(() => ref.read(skillCirclesControllerProvider.notifier).loadInitial());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(skillCirclesControllerProvider);
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    final filtered = _searchController.text.isEmpty
        ? state.circles
        : state.circles.where((c) => c.title.toLowerCase().contains(_searchController.text.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skill Circles'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!context.mounted) {
            return;
          }

          if (FirebaseAuth.instance.currentUser == null) {
            context.go(AppRoutes.login);
            return;
          }

          final created = await context.push<bool>(AppRoutes.createCircle);
          if (created == true && mounted) {
            await ref.read(skillCirclesControllerProvider.notifier).refresh();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Skill circle added to your feed')),
              );
            }
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Circle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search circles',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            // Tabs: All / Joined
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => ref.read(skillCirclesControllerProvider.notifier).refresh(),
                          child: const Text('Refresh'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          child: const Text('Clear'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: state.circles.isEmpty
                        ? Center(
                            child: state.isLoading
                                ? const CircularProgressIndicator()
                                : const Text('No circles yet. Create one!'),
                          )
                        : ListView.builder(
                            itemCount: filtered.length + 1,
                            itemBuilder: (context, index) {
                              if (index == filtered.length) {
                                if (state.hasMore) {
                                  // Load more button
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Center(
                                      child: ElevatedButton(
                                        onPressed: state.isLoading
                                            ? null
                                            : () => ref.read(skillCirclesControllerProvider.notifier).loadMore(),
                                        child: state.isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Load more'),
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }

                              final circle = filtered[index];
                              final isMember = (user != null);
                              return GestureDetector(
                                onTap: () {
                                  // Navigate to circle detail
                                  if (user == null) {
                                    // send to login
                                    context.go('/login');
                                    return;
                                  }
                                  context.push('/skill-circles/${circle.id}');
                                },
                                child: _CircleCard(
                                  circle: circle,
                                  isMember: isMember,
                                  onJoin: uid == null ? null : () => ref.read(skillCirclesControllerProvider.notifier).joinCircle(circle.id, uid),
                                  onLeave: uid == null ? null : () => ref.read(skillCirclesControllerProvider.notifier).leaveCircle(circle.id, uid),
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
      ),
    );
  }
}

class _CircleCard extends StatelessWidget {
  const _CircleCard({required this.circle, this.isMember = false, this.onJoin, this.onLeave});

  final dynamic circle;
  final bool isMember;
  final VoidCallback? onJoin;
  final VoidCallback? onLeave;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: ClayTokens.brandPale,
              child: Text(circle.title.isNotEmpty ? circle.title[0].toUpperCase() : '?', style: const TextStyle(fontSize: 20, color: ClayTokens.brand)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(circle.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(circle.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text('${circle.memberCount} members', style: const TextStyle(fontSize: 12, color: ClayTokens.textSecond)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                if (!isMember)
                  ElevatedButton(onPressed: onJoin, child: const Text('Join'))
                else
                  OutlinedButton(onPressed: onLeave, child: const Text('Leave')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}