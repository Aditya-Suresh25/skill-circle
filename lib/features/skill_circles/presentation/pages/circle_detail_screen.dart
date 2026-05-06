import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skill_circle_app/core/constants/app_routes.dart';
import 'package:skill_circle_app/features/posts/domain/entities/post.dart';
import 'package:skill_circle_app/features/posts/presentation/pages/posts_page.dart';
import 'package:skill_circle_app/features/posts/presentation/providers/posts_controller_provider.dart';
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
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => CreatePostRoute(circleId: circleId)));
        },
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}

// Minimal wrapper to reuse existing CreatePostScreen from screens
class CreatePostRoute extends StatelessWidget {
  const CreatePostRoute({super.key, required this.circleId});
  final String circleId;

  @override
  Widget build(BuildContext context) {
    return CreatePostScreenWrapper(circleId: circleId);
  }
}

// Adapter around the existing CreatePostScreen to provide circleId and integrate create logic
class CreatePostScreenWrapper extends ConsumerStatefulWidget {
  const CreatePostScreenWrapper({super.key, required this.circleId});
  final String circleId;

  @override
  ConsumerState<CreatePostScreenWrapper> createState() => _CreatePostScreenWrapperState();
}

class _CreatePostScreenWrapperState extends ConsumerState<CreatePostScreenWrapper> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contentCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in to post')));
      return;
    }

    setState(() => _submitting = true);
    try {
      final post = Post(id: '', userId: user.uid, circleId: widget.circleId, content: _contentCtrl.text.trim(), timestamp: DateTime.now(), upvotes: 0);
      await ref.read(postsControllerProvider.notifier).createPost(post);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _contentCtrl,
                maxLines: 8,
                decoration: const InputDecoration(hintText: 'Write something...'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Post cannot be empty' : null,
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _submitting ? null : _publish, child: _submitting ? const CircularProgressIndicator() : const Text('Publish')),
            ],
          ),
        ),
      ),
    );
  }
}
