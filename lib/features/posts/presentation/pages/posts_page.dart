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
      Future.microtask(() {
        ref.read(postsControllerProvider.notifier).watchPosts(widget.circleId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postsControllerProvider);
    final hasComposer = widget.circleId != null;

    return Scaffold(
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification &&
                notification.metrics.extentAfter < 250 &&
                widget.circleId != null) {
              ref.read(postsControllerProvider.notifier).loadMore(widget.circleId!);
            }
            return false;
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                sliver: SliverToBoxAdapter(
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
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
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
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              if (state.posts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : const Center(child: Text('No posts yet. Be the first!')),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final post = state.posts[index];
                        final currentUser = ref.watch(currentUserProvider);
                        final userId = currentUser?.id;
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
                      childCount: state.posts.length,
                    ),
                  ),
                ),
              if (state.posts.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Center(
                      child: state.isLoading
                          ? const CircularProgressIndicator()
                          : (state.hasMore
                              ? TextButton(
                                  onPressed: widget.circleId == null
                                      ? null
                                      : () => ref.read(postsControllerProvider.notifier).loadMore(widget.circleId!),
                                  child: const Text('Load more'),
                                )
                              : const SizedBox.shrink()),
                    ),
                  ),
                ),
            ],
          ),
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
    final author = post.username.trim().isEmpty ? 'Community Member' : post.username.trim();
    final initial = author.isNotEmpty ? author[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ClayTokens.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ClayTokens.brandLight.withValues(alpha: 0.35)),
        boxShadow: ClayTokens.clayShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1CB0C2), Color(0xFF0D5B65)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: ClayTokens.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTime(post.timestamp),
                        style: const TextStyle(fontSize: 12, color: ClayTokens.textSecond),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz_rounded, color: ClayTokens.textHint),
              ],
            ),
            if (post.content.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                post.content,
                style: const TextStyle(fontSize: 15, height: 1.45, color: ClayTokens.textPrimary),
              ),
            ],
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
            const SizedBox(height: 14),
            Row(
              children: [
                _PostActionPill(
                  icon: isUpvoted ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                  label: post.upvotes.toString(),
                  color: isUpvoted ? Colors.blue : ClayTokens.textSecond,
                  onTap: isPending ? null : onUpvote,
                ),
                const SizedBox(width: 10),
                _PostActionPill(
                  icon: Icons.mode_comment_outlined,
                  label: 'Comment',
                  color: ClayTokens.textSecond,
                  onTap: () {},
                ),
                const SizedBox(width: 10),
                _PostActionPill(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  color: ClayTokens.textSecond,
                  onTap: () {},
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

class _PostActionPill extends StatelessWidget {
  const _PostActionPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ClayTokens.pageBg.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
              ),
            ],
          ),
        ),
      ),
    );
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
 