// Removed firebase_auth
import 'package:skill_circle_app/core/services/app_router.dart';
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
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final circlesAsync = ref.watch(allCirclesStreamProvider);
    final allCircles = circlesAsync.valueOrNull ?? [];
    final user = ref.watch(authStateProvider).valueOrNull;
    final uid = user?.id;

    final filtered = _searchController.text.isEmpty
        ? allCircles
        : allCircles.where((c) => c.title.toLowerCase().contains(_searchController.text.toLowerCase())).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!mounted) {
            return;
          }

          if (ref.read(authStateProvider).valueOrNull == null) {
            context.go(AppRoutes.login);
            return;
          }

          final created = await context.push<bool>(AppRoutes.createCircle);
          if (!mounted || created != true) {
            return;
          }

          ref.invalidate(allCirclesStreamProvider);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Skill circle added to your feed')),
          );
        },
        backgroundColor: ClayTokens.brandDeep,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Circle'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0E6B79), Color(0xFF19A7B8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Skill Circles', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                    SizedBox(height: 6),
                    Text('Find your people. Learn, build, and ship together.', style: TextStyle(color: Color(0xFFE3FBFF), height: 1.3)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Search circles',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: circlesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                  data: (_) {
                    if (allCircles.isEmpty) {
                      return const Center(child: Text('No circles yet. Create one!'));
                    }
                    if (filtered.isEmpty) {
                      return const Center(child: Text('No circles found matching your search.'));
                    }
                    return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {

                          final circle = filtered[index];
                          final isMember = uid != null && circle.members.contains(uid);
                          return GestureDetector(
                            onTap: () {
                              if (user == null) {
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
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF22AFBE), Color(0xFF0F6B78)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                image: circle.imageUrl != null && circle.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(circle.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: circle.imageUrl == null || circle.imageUrl.isEmpty
                  ? Center(
                      child: Text(
                        circle.title.isNotEmpty ? circle.title[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    )
                  : null,
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      color: ClayTokens.brandPale,
                    ),
                    child: Text(
                      '${circle.memberCount} members',
                      style: const TextStyle(fontSize: 12, color: ClayTokens.brandDeep, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 84,
                  child: isMember
                      ? OutlinedButton(onPressed: onLeave, child: const Text('Leave'))
                      : ElevatedButton(onPressed: onJoin, child: const Text('Join')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}