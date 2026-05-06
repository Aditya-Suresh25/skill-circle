import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/features/posts/domain/entities/post.dart';
import 'package:skill_circle_app/features/posts/presentation/providers/posts_controller_provider.dart';
import 'package:skill_circle_app/features/posts/presentation/providers/posts_providers.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

class PostsPage extends ConsumerStatefulWidget {
  const PostsPage({super.key, this.circleId});

  final String? circleId;

  @override
  ConsumerState<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends ConsumerState<PostsPage> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // Start watching realtime posts
    _controller.addListener(() => setState(() {}));
    if (widget.circleId != null) {
      Future.microtask(() => ref.read(postsControllerProvider.notifier).watchPosts(widget.circleId!));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Shouldn't happen if guarded elsewhere

    setState(() => _sending = true);

    if (widget.circleId == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a circle to post into')));
      setState(() => _sending = false);
      return;
    }
    try {
      final post = Post(
        id: '',
        userId: user.uid,
        circleId: widget.circleId!,
        content: text,
        timestamp: DateTime.now(),
        upvotes: 0,
        attachments: const [],
      );

      await ref.read(postsControllerProvider.notifier).createPost(post);
      _controller.clear();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Circle Feed')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 5,
                        decoration: const InputDecoration(hintText: 'Share something...'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _sending
                        ? const CircularProgressIndicator()
                        : ElevatedButton(onPressed: _controller.text.trim().isEmpty ? null : _send, child: const Text('Post')),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: state.posts.isEmpty
                ? state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : const Center(child: Text('No posts yet. Be the first!'))
                : NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      if (n is ScrollEndNotification && n.metrics.pixels >= n.metrics.maxScrollExtent - 50) {
                        if (widget.circleId != null) {
                          ref.read(postsControllerProvider.notifier).loadMore(widget.circleId!);
                        }
                      }
                      return false;
                    },
                    child: ListView.builder(
                      itemCount: state.posts.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.posts.length) {
                          return Padding(
                            padding: const EdgeInsets.all(12),
                            child: Center(child: state.isLoading ? const CircularProgressIndicator() : const Text('Load more')),
                          );
                        }

                        final post = state.posts[index];
                        final currentUser = ref.watch(currentUserProvider);
                        final userId = currentUser?.uid;
                        final isUpvoted = state.upvotedPostIds.contains(post.id);
                        final isPending = state.pendingUpvoteIds.contains(post.id);

                        return PostCard(
                          post: post,
                          isUpvoted: isUpvoted,
                          isPending: isPending,
                          onUpvote: userId == null
                              ? null
                              : () => ref.read(postsControllerProvider.notifier).toggleUpvote(post.id, userId),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, this.isUpvoted = false, this.isPending = false, this.onUpvote});

  final Post post;
  final bool isUpvoted;
  final bool isPending;
  final VoidCallback? onUpvote;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(backgroundColor: ClayTokens.brandPale, child: Text(post.userId.isNotEmpty ? post.userId[0].toUpperCase() : '?')),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('User', style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(_formatTime(post.timestamp), style: const TextStyle(fontSize: 12, color: ClayTokens.textSecond)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(post.content),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: isPending ? null : onUpvote,
                        icon: isUpvoted
                            ? const Icon(Icons.thumb_up, size: 18, color: Colors.blue)
                            : const Icon(Icons.thumb_up_alt_outlined, size: 18),
                        tooltip: isUpvoted ? 'Remove upvote' : 'Upvote',
                      ),
                      const SizedBox(width: 6),
                      Text('${post.upvotes}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
 