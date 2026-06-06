import 'package:skill_circle_app/core/theme.dart';
import 'package:skill_circle_app/core/constants/app_colors.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skill_circle_app/core/appwrite.dart';
import 'package:skill_circle_app/core/gemini.dart';
import 'package:skill_circle_app/core/widgets/glass.dart';
import 'package:skill_circle_app/models/circle.dart';
import 'package:skill_circle_app/models/post.dart';
import 'package:skill_circle_app/models/comment.dart';
import 'package:skill_circle_app/models/channel.dart';
import 'package:skill_circle_app/models/message.dart';
import 'package:skill_circle_app/models/task.dart';

// Providers for Circle Detail
final circleProvider = FutureProvider.family.autoDispose<SkillCircle, String>((ref, id) async {
  final service = ref.watch(appwriteServiceProvider);
  final circles = await service.getCircles();
  return circles.firstWhere((c) => c.circleId == id);
});

final postsProvider = FutureProvider.family.autoDispose<List<Post>, String>((ref, circleId) async {
  return ref.watch(appwriteServiceProvider).getPosts(circleId);
});

final channelsProvider = FutureProvider.family.autoDispose<List<ChatChannel>, String>((ref, circleId) async {
  return ref.watch(appwriteServiceProvider).getChannels(circleId);
});

final tasksProvider = FutureProvider.family.autoDispose<List<MentorTask>, String>((ref, circleId) async {
  return ref.watch(appwriteServiceProvider).getTasks(circleId);
});

class CircleDetailPage extends ConsumerStatefulWidget {
  const CircleDetailPage({super.key, required this.circleId});

  final String circleId;

  @override
  ConsumerState<CircleDetailPage> createState() => _CircleDetailPageState();
}

class _CircleDetailPageState extends ConsumerState<CircleDetailPage> {


  @override
  Widget build(BuildContext context) {
    final circleAsync = ref.watch(circleProvider(widget.circleId));
    final user = ref.watch(currentUserProvider);
    final isMentor = user != null && (user.role == 'mentor' || user.role == 'admin');

    return DefaultTabController(
      length: isMentor ? 4 : 3,
      child: Scaffold(
        appBar: AppBar(
          title: circleAsync.when(
            loading: () => const Text('Loading...'),
            error: (_, __) => const Text('Error'),
            data: (c) => Text(c.circleName, style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
          ),
          bottom: TabBar(
            labelStyle: GoogleFonts.lexend(fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.lexend(fontWeight: FontWeight.normal),
            indicatorColor: AppColors.twitchPurpleLight,
            labelColor: AppColors.twitchPurpleLight,
            unselectedLabelColor: context.textColor.withValues(alpha: 0.50),
            tabs: [
              const Tab(text: 'Feed'),
              const Tab(text: 'Chat'),
              const Tab(text: 'Tasks'),
              if (isMentor) const Tab(text: 'Brainstorm'),
            ],
          ),
        ),
        body: AuroraBackground(
          child: circleAsync.when(
            loading: () => Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.twitchPurpleLight))),
            error: (err, _) => Center(child: Text('Failed to load circle details: $err', style: TextStyle(color: context.textColor))),
            data: (circle) {
              return TabBarView(
                children: [
                  _FeedTab(circle: circle),
                  _ChatTab(circle: circle),
                  _TasksTab(circle: circle),
                  if (isMentor) _AiSuggestionsTab(circle: circle),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ==================== FEED TAB ====================
class _FeedTab extends ConsumerStatefulWidget {
  const _FeedTab({required this.circle});
  final SkillCircle circle;

  @override
  ConsumerState<_FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends ConsumerState<_FeedTab> {
  final _postController = TextEditingController();
  bool _isPosting = false;
  Uint8List? _pickedFileBytes;
  String? _pickedFileName;
  String? _pickedFileMime;

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _pickedFileBytes = bytes;
        _pickedFileName = file.name;
        _pickedFileMime = file.mimeType ?? 'image/jpeg';
      });
    }
  }

  Future<void> _createPost() async {
    final text = _postController.text.trim();
    if (text.isEmpty && _pickedFileBytes == null) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isPosting = true);

    try {
      final service = ref.read(appwriteServiceProvider);
      List<Attachment> attachments = [];

      if (_pickedFileBytes != null) {
        final att = await service.uploadFile(_pickedFileBytes!, _pickedFileName!, _pickedFileMime!, user.id);
        attachments.add(att);
      }

      await service.createPost(
        widget.circle.circleId,
        user.id,
        user.displayName,
        text,
        attachments: attachments,
      );

      _postController.clear();
      setState(() {
        _pickedFileBytes = null;
        _pickedFileName = null;
      });
      ref.invalidate(postsProvider(widget.circle.circleId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to publish post: $e')));
      }
    } finally {
      setState(() => _isPosting = false);
    }
  }

  void _showComments(Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CommentsSheet(post: post),
    );
  }

  void _editPost(Post post) {
    final ctrl = TextEditingController(text: post.content);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Post'),
          content: TextField(
            controller: ctrl,
            maxLines: 4,
            style: TextStyle(color: context.textColor),
            decoration: InputDecoration(
              hintText: 'Share something with the circle...',
              filled: true,
              fillColor: context.textColor.withValues(alpha: 0.04),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final newContent = ctrl.text.trim();
                if (newContent.isNotEmpty && newContent != post.content) {
                  try {
                    await ref.read(appwriteServiceProvider).updatePost(post.id, newContent);
                    ref.invalidate(postsProvider(widget.circle.circleId));
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update post: $e')));
                    }
                  }
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text('Save Changes'),
            )
          ],
        );
      }
    );
  }

  void _deletePost(Post post) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Post'),
          content: Text('Are you sure you want to delete this post? This cannot be undone.', style: TextStyle(color: context.textColor.withValues(alpha: 0.8))),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              onPressed: () async {
                try {
                  await ref.read(appwriteServiceProvider).deletePost(post.id);
                  ref.invalidate(postsProvider(widget.circle.circleId));
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete post: $e')));
                  }
                }
              },
              child: Text('Delete'),
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(postsProvider(widget.circle.circleId));
    final user = ref.watch(currentUserProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(postsProvider(widget.circle.circleId)),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Create Post box
          GradientPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _postController,
                  maxLines: 3,
                  style: TextStyle(color: context.textColor),
                  decoration: InputDecoration(
                    hintText: 'Share something with the circle...',
                    hintStyle: TextStyle(color: context.textColor.withValues(alpha: 0.45)),
                    fillColor: context.textColor.withValues(alpha: 0.04),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
                if (_pickedFileName != null) ...[
                  SizedBox(height: 8),
                  Chip(
                    label: Text(_pickedFileName!),
                    onDeleted: () => setState(() => _pickedFileName = null),
                  ),
                ],
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _pickFile,
                      icon: Icon(Icons.add_photo_alternate_rounded, color: AppColors.twitchPurpleLight),
                    ),
                    ElevatedButton(
                      onPressed: _isPosting ? null : _createPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.twitchPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        minimumSize: Size.zero,
                      ),
                      child: _isPosting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                          : Text('Post'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Posts Feed
          postsAsync.when(
            loading: () => Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.twitchPurpleLight))),
            error: (err, _) => Center(child: Text('Error loading feed: $err', style: TextStyle(color: context.textColor))),
            data: (posts) {
              if (posts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text('No posts yet. Be the first to share!', style: TextStyle(color: context.textColor.withValues(alpha: 0.50))),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: GradientPanel(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.twitchPurple,
                                child: Text(post.username.isNotEmpty ? post.username[0].toUpperCase() : 'U', style: TextStyle(color: context.textColor, fontWeight: FontWeight.bold)),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(post.username, style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold, color: context.textColor)),
                                    SizedBox(height: 2),
                                    Text(
                                      '${post.timestamp.day}/${post.timestamp.month} at ${post.timestamp.hour}:${post.timestamp.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(fontSize: 11, color: context.textColor.withValues(alpha: 0.40)),
                                    ),
                                  ],
                                ),
                              ),
                              if (user?.id == post.userId)
                                PopupMenuButton<String>(
                                  icon: Icon(Icons.more_horiz_rounded, color: context.textColor.withValues(alpha: 0.6)),
                                  color: AppColors.darkSurface,
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _editPost(post);
                                    } else if (value == 'delete') {
                                      _deletePost(post);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18, color: Colors.white), SizedBox(width: 8), Text('Edit', style: TextStyle(color: Colors.white))])),
                                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.redAccent), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.redAccent))])),
                                  ],
                                ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(post.content, style: GoogleFonts.inter(fontSize: 15, color: context.textColor)),
                          if (post.attachments.isNotEmpty) ...[
                            SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                post.attachments.first.url,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 100,
                                  color: context.textColor.withValues(alpha: 0.05),
                                  child: Center(child: Icon(Icons.broken_image_rounded, color: Colors.grey)),
                                ),
                              ),
                            ),
                          ],
                          SizedBox(height: 16),
                          Row(
                            children: [
                              InkWell(
                                onTap: () async {
                                  await ref.read(appwriteServiceProvider).upvotePost(post.id, post.upvotes);
                                  ref.invalidate(postsProvider(widget.circle.circleId));
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: context.textColor.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.arrow_upward_rounded, size: 16, color: AppColors.twitchPurpleLight),
                                      SizedBox(width: 4),
                                      Text('${post.upvotes}', style: TextStyle(color: context.textColor, fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              InkWell(
                                onTap: () => _showComments(post),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: context.textColor.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.mode_comment_outlined, size: 15, color: AppColors.twitchPurpleLight),
                                      const SizedBox(width: 4),
                                      Text('Comments', style: TextStyle(color: context.textColor, fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// Comments sheet subclass
class _CommentsSheet extends ConsumerStatefulWidget {
  const _CommentsSheet({required this.post});
  final Post post;

  @override
  ConsumerState<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<_CommentsSheet> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(appwriteServiceProvider).createComment(
            widget.post.id,
            user.id,
            user.displayName,
            text,
          );
      _commentController.clear();
      setState(() {});
      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 200), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to comment: $e')));
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Comments', style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close)),
            ],
          ),
          SizedBox(height: 12),
          FutureBuilder<List<Comment>>(
            future: ref.read(appwriteServiceProvider).getComments(widget.post.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(height: 150, child: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return SizedBox(height: 100, child: Center(child: Text('Failed to load comments')));
              }
              final comments = snapshot.data ?? [];
              if (comments.isEmpty) {
                return SizedBox(height: 100, child: Center(child: Text('No comments yet.')));
              }

              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                child: ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            child: Text(comment.username[0].toUpperCase()),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(comment.username, style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 13)),
                                SizedBox(height: 2),
                                Text(comment.commentText, style: GoogleFonts.inter(fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                  ),
                ),
              ),
              SizedBox(width: 10),
              IconButton.filled(
                onPressed: _isSubmitting ? null : _submitComment,
                icon: Icon(Icons.send_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== CHAT TAB ====================
class _ChatTab extends ConsumerStatefulWidget {
  const _ChatTab({required this.circle});
  final SkillCircle circle;

  @override
  ConsumerState<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends ConsumerState<_ChatTab> {
  ChatChannel? _selectedChannel;
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  final _channelNameController = TextEditingController();

  List<ChatMessage> _messages = [];
  bool _isLoadingMessages = false;
  StreamSubscription? _realtimeSubscription;

  @override
  void initState() {
    super.initState();
    _initChannels();
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    _channelNameController.dispose();
    _realtimeSubscription?.cancel();
    super.dispose();
  }

  void _initChannels() async {
    final channels = await ref.read(appwriteServiceProvider).getChannels(widget.circle.circleId);
    if (channels.isNotEmpty) {
      _selectChannel(channels.first);
    }
  }

  void _selectChannel(ChatChannel channel) async {
    setState(() {
      _selectedChannel = channel;
      _isLoadingMessages = true;
      _messages = [];
    });

    _realtimeSubscription?.cancel();

    final service = ref.read(appwriteServiceProvider);
    try {
      final messages = await service.getMessages(channel.channelId);
      if (mounted) {
        setState(() {
          _messages = messages;
        });
        _scrollToBottom();
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoadingMessages = false);
    }

    // Listen to real-time updates for messages
    _realtimeSubscription = service.watchMessages().listen((msg) async {
      // Event corresponds to message collection
      if (msg.events.any((e) => e.contains('.create'))) {
        final data = Map<String, dynamic>.from(msg.payload);
        if (data['channelId'] == channel.channelId) {
          final message = ChatMessage.fromMap(data['\$id'] ?? '', data);
          final senderProfile = await service.getCurrentProfile(message.senderId);
          if (mounted) {
            setState(() {
              _messages.add(message.copyWith(senderName: senderProfile?.displayName));
            });
            _scrollToBottom();
          }
        }
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _selectedChannel == null) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    _msgController.clear();
    await ref.read(appwriteServiceProvider).sendMessage(
          _selectedChannel!.channelId,
          user.id,
          user.displayName,
          text,
        );
  }

  void _showCreateChannelDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create Channel', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _channelNameController,
            decoration: const InputDecoration(
              labelText: 'Channel Name',
              hintText: 'e.g. general-chat',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _channelNameController.text.trim();
                if (name.isEmpty) return;

                final service = ref.read(appwriteServiceProvider);
                final channel = await service.createChannel(widget.circle.circleId, name, '');
                _channelNameController.clear();
                if (context.mounted) {
                  Navigator.pop(context);
                }
                ref.invalidate(channelsProvider(widget.circle.circleId));
                _selectChannel(channel);
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final channelsAsync = ref.watch(channelsProvider(widget.circle.circleId));
    final user = ref.watch(currentUserProvider);

    return Column(
      children: [
        // Channels list horizontal bar
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          color: context.textColor.withValues(alpha: 0.02),
          child: Row(
            children: [
              Expanded(
                child: channelsAsync.when(
                  loading: () => Center(child: LinearProgressIndicator()),
                  error: (_, __) => Text('Error'),
                  data: (channels) {
                    if (channels.isEmpty) {
                      return Text('No channels yet', style: TextStyle(color: context.textColor.withValues(alpha: 0.40)));
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: channels.length,
                      itemBuilder: (context, index) {
                        final ch = channels[index];
                        final isSel = _selectedChannel?.channelId == ch.channelId;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          child: InkWell(
                            onTap: () => _selectChannel(ch),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: isSel ? AppColors.twitchPurple : Colors.transparent,
                                border: Border.all(color: isSel ? AppColors.twitchPurpleLight : context.textColor.withValues(alpha: 0.12)),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  '# ${ch.name}',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                    color: isSel ? context.textColor : context.textColor.withValues(alpha: 0.60),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              if (user != null && (user.role == 'mentor' || user.role == 'admin'))
                IconButton(
                  onPressed: _showCreateChannelDialog,
                  icon: Icon(Icons.add_box_rounded, color: AppColors.twitchPurpleLight),
                ),
            ],
          ),
        ),

        // Messages area
        Expanded(
          child: _selectedChannel == null
              ? Center(child: Text('Please select or create a channel', style: TextStyle(color: context.textColor.withValues(alpha: 0.45))))
              : _isLoadingMessages
                  ? Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                      ? Center(child: Text('No messages here yet. Start the conversation!', style: TextStyle(color: context.textColor.withValues(alpha: 0.40))))
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            final isMe = msg.senderId == user?.id;

                            return Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isMe ? AppColors.twitchPurple.withValues(alpha: 0.85) : context.textColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(18),
                                    topRight: const Radius.circular(18),
                                    bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
                                    bottomRight: isMe ? Radius.zero : const Radius.circular(18),
                                  ),
                                  border: Border.all(
                                    color: isMe ? AppColors.twitchPurpleLight.withValues(alpha: 0.40) : context.textColor.withValues(alpha: 0.06),
                                  ),
                                ),
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isMe)
                                      Text(
                                        msg.senderName ?? 'Member',
                                        style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.twitchPurpleLight),
                                      ),
                                    SizedBox(height: 2),
                                    Text(
                                      msg.text,
                                      style: GoogleFonts.inter(fontSize: 14, color: context.textColor),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
        ),

        // Text input bar
        if (_selectedChannel != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.textColor.withValues(alpha: 0.20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    style: TextStyle(color: context.textColor),
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: context.textColor.withValues(alpha: 0.40)),
                      fillColor: context.textColor.withValues(alpha: 0.04),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sendMessage,
                  icon: Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ==================== TASKS TAB ====================
class _TasksTab extends ConsumerStatefulWidget {
  const _TasksTab({required this.circle});
  final SkillCircle circle;

  @override
  ConsumerState<_TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends ConsumerState<_TasksTab> {
  final _taskTitleController = TextEditingController();
  final _taskDescController = TextEditingController();
  bool _isCreatingTask = false;

  @override
  void dispose() {
    _taskTitleController.dispose();
    _taskDescController.dispose();
    super.dispose();
  }

  void _showCreateTaskDialog([MentorTask? taskToEdit]) {
    if (taskToEdit != null) {
      _taskTitleController.text = taskToEdit.title;
      _taskDescController.text = taskToEdit.description;
    } else {
      _taskTitleController.clear();
      _taskDescController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(taskToEdit == null ? 'Assign Task' : 'Edit Task', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _taskTitleController,
                  decoration: const InputDecoration(labelText: 'Task Title'),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _taskDescController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Instructions / Details'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _taskTitleController.clear();
                _taskDescController.clear();
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isCreatingTask ? null : () async {
                final title = _taskTitleController.text.trim();
                final desc = _taskDescController.text.trim();
                if (title.isEmpty || desc.isEmpty) return;

                final user = ref.read(currentUserProvider);
                if (user == null) return;

                setState(() => _isCreatingTask = true);
                try {
                  if (taskToEdit == null) {
                    final task = MentorTask(
                      id: '',
                      circleId: widget.circle.circleId,
                      mentorId: user.id,
                      title: title,
                      description: desc,
                      createdAt: DateTime.now(),
                    );
                    await ref.read(appwriteServiceProvider).createTask(task);
                  } else {
                    final updatedTask = taskToEdit.copyWith(
                      title: title,
                      description: desc,
                    );
                    await ref.read(appwriteServiceProvider).updateTask(updatedTask);
                  }
                  
                  _taskTitleController.clear();
                  _taskDescController.clear();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                  ref.invalidate(tasksProvider(widget.circle.circleId));
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                  }
                }
                setState(() => _isCreatingTask = false);
              },
              child: Text(taskToEdit == null ? 'Assign' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTask(MentorTask task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text('Are you sure you want to delete this task? This cannot be undone.', style: TextStyle(color: context.textColor.withValues(alpha: 0.8))),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              onPressed: () async {
                try {
                  await ref.read(appwriteServiceProvider).deleteTask(task.id);
                  ref.invalidate(tasksProvider(widget.circle.circleId));
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete task: $e')));
                  }
                }
              },
              child: Text('Delete'),
            )
          ],
        );
      }
    );
  }

  void _showSubmitTaskDialog(MentorTask task) {
    final commentController = TextEditingController();
    Uint8List? subBytes;
    String? subName;
    String? subMime;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text('Submit Task', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Short submission notes'),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                        if (img != null) {
                          final bytes = await img.readAsBytes();
                          setModalState(() {
                            subBytes = bytes;
                            subName = img.name;
                            subMime = img.mimeType ?? 'image/jpeg';
                          });
                        }
                      },
                      icon: Icon(Icons.upload_file_rounded),
                      label: Text(subName != null ? 'File selected: $subName' : 'Select Attachment'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final user = ref.read(currentUserProvider);
                          if (user == null) return;
                          
                          setModalState(() => isSubmitting = true);
                          try {
                            final service = ref.read(appwriteServiceProvider);
                            List<Attachment> atts = [];

                            if (subBytes != null) {
                              final attachment = await service.uploadFile(subBytes!, subName!, subMime!, user.id);
                              atts.add(attachment);
                            }

                            final submission = TaskSubmission(
                              id: '',
                              taskId: task.id,
                              userId: user.id,
                              content: commentController.text.trim(),
                              attachments: atts,
                              submittedAt: DateTime.now(),
                            );
                            await service.submitTask(submission);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task submitted successfully!')));
                            }
                          } catch (_) {}
                          setModalState(() => isSubmitting = false);
                        },
                  child: isSubmitting
                      ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(context.textColor)))
                      : Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showGradingDialog(TaskSubmission sub) {
    final feedbackController = TextEditingController();
    String grade = 'Pass'; // 'Pass' or 'Needs Work'
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text('Grade Submission', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (sub.content?.isNotEmpty ?? false) ...[
                    Text('Notes:', style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 13)),
                    SizedBox(height: 4),
                    Text(sub.content!),
                    SizedBox(height: 12),
                  ],
                  if (sub.attachments.isNotEmpty) ...[
                    Text('Attachment:', style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 13)),
                    SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        sub.attachments.first.url,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                  Text('Grade:', style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: isSaving ? null : () => setModalState(() => grade = 'Pass'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          backgroundColor: grade == 'Pass' ? Colors.green : Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Pass'),
                      ),
                      ElevatedButton(
                        onPressed: isSaving ? null : () => setModalState(() => grade = 'Needs Work'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          backgroundColor: grade == 'Needs Work' ? Colors.orange : Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Needs Work'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: feedbackController,
                    decoration: const InputDecoration(labelText: 'Feedback notes'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setModalState(() => isSaving = true);
                          await ref.read(appwriteServiceProvider).gradeSubmission(sub.id, grade, feedbackController.text.trim(), sub.userId, sub.taskId);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Submission graded!')));
                          }
                          setModalState(() => isSaving = false);
                        },
                  child: Text('Submit Grade'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _viewSubmissions(MentorTask task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Submissions for: ${task.title}', style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<TaskSubmission>>(
                  future: ref.read(appwriteServiceProvider).getSubmissions(task.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final submissions = snapshot.data ?? [];
                    if (submissions.isEmpty) {
                      return Center(child: Text('No submissions yet.'));
                    }

                    return ListView.builder(
                      itemCount: submissions.length,
                      itemBuilder: (context, index) {
                        final sub = submissions[index];
                        return Card(
                          color: context.textColor.withValues(alpha: 0.05),
                          child: ListTile(
                            title: Text(sub.userName ?? 'Student'),
                            subtitle: Text('Status: ${sub.status.toUpperCase()} | Grade: ${sub.grade ?? 'Unresolved'}'),
                            trailing: IconButton(
                              icon: Icon(Icons.grade_rounded, color: AppColors.twitchPurpleLight),
                              onPressed: () {
                                Navigator.pop(context);
                                _showGradingDialog(sub);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider(widget.circle.circleId));
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      floatingActionButton: (user != null && (user.role == 'mentor' || user.role == 'admin'))
          ? FloatingActionButton(
              onPressed: _showCreateTaskDialog,
              backgroundColor: AppColors.twitchPurple,
              child: Icon(Icons.add_rounded),
            )
          : null,
      body: tasksAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading tasks: $err')),
        data: (tasks) {
          if (tasks.isEmpty) {
            return Center(child: Text('No tasks assigned yet.', style: TextStyle(color: context.textColor.withValues(alpha: 0.40))));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final isMentor = user != null && (user.role == 'mentor' || user.role == 'admin');

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(task.title, style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.twitchPurple.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                            child: Text('Task', style: GoogleFonts.inter(fontSize: 11, color: AppColors.twitchPurpleLight, fontWeight: FontWeight.bold)),
                          ),
                          if (user?.id == task.mentorId || user?.role == 'admin')
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_horiz_rounded, color: context.textColor.withValues(alpha: 0.6)),
                              color: AppColors.darkSurface,
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showCreateTaskDialog(task);
                                } else if (value == 'delete') {
                                  _deleteTask(task);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18, color: Colors.white), SizedBox(width: 8), Text('Edit', style: TextStyle(color: Colors.white))])),
                                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.redAccent), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.redAccent))])),
                              ],
                            ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(task.description, style: GoogleFonts.inter(fontSize: 14, color: context.textColor.withValues(alpha: 0.70))),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isMentor)
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
                              onPressed: () => _viewSubmissions(task),
                              icon: Icon(Icons.people_outline),
                              label: Text('View Submissions'),
                            )
                          else
                            FutureBuilder<List<TaskSubmission>>(
                              future: ref.read(appwriteServiceProvider).getSubmissions(task.id),
                              builder: (context, snapshot) {
                                final mySub = snapshot.data?.where((s) => s.userId == user?.id).firstOrNull;
                                if (mySub != null) {
                                  return ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(0, 48),
                                      backgroundColor: mySub.grade == 'Pass' ? Colors.green : (mySub.grade == 'Needs Work' ? Colors.orange : AppColors.accentCyan),
                                    ),
                                    onPressed: null, // Disabled because already submitted
                                    icon: Icon(mySub.grade == 'Pass' ? Icons.check_circle_rounded : (mySub.grade == 'Needs Work' ? Icons.warning_rounded : Icons.pending_rounded), color: Colors.white),
                                    label: Text(mySub.grade == 'Pass' ? 'Passed' : (mySub.grade == 'Needs Work' ? 'Needs Work' : 'Pending Review'), style: TextStyle(color: Colors.white)),
                                  );
                                }
                                return ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(minimumSize: const Size(0, 48)),
                                  onPressed: () => _showSubmitTaskDialog(task),
                                  icon: Icon(Icons.send_rounded),
                                  label: Text('Submit Work'),
                                );
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==================== AI SUGGESTIONS (BRAINSTORM) TAB ====================
class _AiSuggestionsTab extends StatefulWidget {
  const _AiSuggestionsTab({required this.circle});
  final SkillCircle circle;

  @override
  State<_AiSuggestionsTab> createState() => _AiSuggestionsTabState();
}

class _AiSuggestionsTabState extends State<_AiSuggestionsTab> {
  String? _suggestions;
  bool _isLoading = false;

  Future<void> _generateIdeas(WidgetRef ref) async {
    setState(() => _isLoading = true);
    try {
      final gemini = ref.read(geminiServiceProvider);
      final res = await gemini.generateCircleIdeas(widget.circle.circleName, widget.circle.description);
      setState(() {
        _suggestions = res;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'AI Brainstorm Hub',
                style: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.bold, color: context.textColor),
              ),
              SizedBox(height: 6),
              Text(
                'Brainstorm collaborative projects and discussion icebreakers powered by Gemini AI.',
                style: GoogleFonts.inter(fontSize: 14, color: context.textColor.withValues(alpha: 0.60)),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _generateIdeas(ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.twitchPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: _isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(
                  _isLoading ? 'Brainstorming...' : 'Generate Projects & Icebreakers',
                  style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 24),
              if (_suggestions != null)
                GradientPanel(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline_rounded, color: AppColors.twitchPurpleLight),
                          SizedBox(width: 8),
                          Text(
                            'Gemini Suggestions',
                            style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold, color: context.textColor),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      const Divider(),
                      SizedBox(height: 12),
                      Text(
                        _suggestions!,
                        style: GoogleFonts.inter(fontSize: 15, height: 1.5, color: context.textColor.withValues(alpha: 0.90)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
