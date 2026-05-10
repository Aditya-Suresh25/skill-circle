import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skill_circle_app/core/constants/app_routes.dart';
import 'package:skill_circle_app/features/posts/presentation/pages/posts_page.dart';
import 'package:skill_circle_app/features/posts/presentation/widgets/post_composer.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

class CircleDetailScreen extends ConsumerWidget {
  const CircleDetailScreen({super.key, required this.circleId});

  final String circleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docStream = FirebaseFirestore.instance.collection('SkillCircles').doc(circleId).snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Circle'),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: docStream,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (!snap.hasData || !snap.data!.exists) {
            if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            return const Center(child: Text('Circle not found'));
          }

          final data = snap.data!.data()!;
          final name = data['circle_name'] as String? ?? '';
          final description = data['description'] as String? ?? '';
          final memberCount = (data['member_count'] as num?)?.toInt() ?? (data['memberCount'] as num?)?.toInt() ?? 0;

          return DefaultTabController(
            length: 1,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: ClayTokens.pageBg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: ClayTokens.brandPale,
                            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 20, color: ClayTokens.brand)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 6),
                                Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            children: [
                              Text('$memberCount', style: const TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              OutlinedButton(onPressed: () {}, child: const Text('Join')),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TabBar(tabs: const [Tab(text: 'Posts')]),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(children: [PostsPage(circleId: circleId)]),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (FirebaseAuth.instance.currentUser == null) {
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
        },
        child: const Icon(Icons.add_comment_rounded),
      ),
    );
  }
}
