import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skill_circle_app/core/constants/app_routes.dart';
import 'package:skill_circle_app/features/posts/domain/entities/post.dart';
import 'package:skill_circle_app/features/posts/presentation/providers/posts_controller_provider.dart';
import 'package:skill_circle_app/features/posts/presentation/providers/posts_providers.dart';
import 'package:skill_circle_app/features/posts/presentation/widgets/post_composer.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

class PostsPage extends ConsumerStatefulWidget {
  const PostsPage({super.key, this.circleId});

  final String? circleId;

  @override
  ConsumerState<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends ConsumerState<PostsPage> {
  @override
  void initState() {
    super.initState();
    if (widget.circleId != null) {
      Future.microtask(() => ref.read(postsControllerProvider.notifier).watchPosts(widget.circleId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postsControllerProvider);
    final hasComposer = widget.circleId != null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF133E47), Color(0xFF127C8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Circle Feed', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                    SizedBox(height: 4),
                    Text('Share ideas, progress updates, and requests for help.', style: TextStyle(color: Color(0xFFE2FAFF))),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: hasComposer
                  ? PostComposer(circleId: widget.circleId, compact: true)
                  : Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Choose a circle to post', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                  SizedBox(height: 4),
                                  Text('Open a circle to attach media and publish an update.', style: TextStyle(color: ClayTokens.textSecond)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.tonal(
                              onPressed: () => context.go(AppRoutes.circles),
                              child: const Text('Browse'),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 8),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        itemCount: state.posts.length + (state.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= state.posts.length) {
                            return Padding(
                              padding: const EdgeInsets.all(12),
                              child: Center(
                                child: state.isLoading ? const CircularProgressIndicator() : const Text('Load more'),
                              ),
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
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1CB0C2), Color(0xFF0D5B65)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      post.userId.isNotEmpty ? post.userId[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Community Member', style: TextStyle(fontWeight: FontWeight.w700)),
                          Text(_formatTime(post.timestamp), style: const TextStyle(fontSize: 12, color: ClayTokens.textSecond)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (post.content.isNotEmpty) Text(post.content),
                    ],
                  ),
                ),
              ],
            ),
            if (post.attachments.isNotEmpty) ...[
              const SizedBox(height: 14),
              SizedBox(
                height: 132,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.attachments.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final attachment = post.attachments[index];
                    return _AttachmentTile(attachment: attachment);
                  },
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: isPending ? null : onUpvote,
                  icon: isUpvoted
                      ? const Icon(Icons.thumb_up, size: 18, color: Colors.blue)
                      : const Icon(Icons.thumb_up_alt_outlined, size: 18),
                  tooltip: isUpvoted ? 'Remove upvote' : 'Upvote',
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: ClayTokens.brandPale,
                  ),
                  child: Text('${post.upvotes}', style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
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

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({required this.attachment});

  final Attachment attachment;

  bool get _isImage => attachment.contentType.startsWith('image/');
  bool get _isVideo => attachment.contentType.startsWith('video/');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: ClayTokens.pageBg,
        border: Border.all(color: ClayTokens.brandLight.withValues(alpha: 0.45)),
      ),
      clipBehavior: Clip.antiAlias,
      child: _isImage
          ? Stack(
              fit: StackFit.expand,
              children: [
                Image.network(attachment.url, fit: BoxFit.cover),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      attachment.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            )
          : Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F6571), Color(0xFF19A7B8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(_isVideo ? Icons.videocam_rounded : Icons.insert_drive_file_rounded, color: Colors.white, size: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attachment.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatSize(attachment.size),
                        style: const TextStyle(color: Color(0xFFE3FBFF), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }
}
 