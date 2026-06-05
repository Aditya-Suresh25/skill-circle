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

class _CircleDetailPageState extends ConsumerState<CircleDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final circleAsync = ref.watch(circleProvider(widget.circleId));

    return Scaffold(
      appBar: AppBar(
        title: circleAsync.when(
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Error'),
          data: (c) => Text(c.circleName, style: GoogleFonts.sora(fontWeight: FontWeight.bold)),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.sora(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.sora(fontWeight: FontWeight.normal),
          indicatorColor: const Color(0xFFC084FC),
          labelColor: const Color(0xFFC084FC),
          unselectedLabelColor: Colors.white.withValues(alpha: 0.50),
          tabs: const [
            Tab(text: 'Feed'),
            Tab(text: 'Chat'),
            Tab(text: 'Tasks'),
            Tab(text: 'Brainstorm'),
          ],
        ),
      ),
      body: AuroraBackground(
        child: circleAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFFC084FC)))),
          error: (err, _) => Center(child: Text('Failed to load circle details: $err', style: const TextStyle(color: Colors.white))),
          data: (circle) {
            return TabBarView(
              controller: _tabController,
              children: [
                _FeedTab(circle: circle),
                _ChatTab(circle: circle),
                _TasksTab(circle: circle),
                _AiSuggestionsTab(circle: circle),
              ],
            );
          },
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

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(postsProvider(widget.circle.circleId));

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(postsProvider(widget.circle.circleId)),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Create Post box
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _postController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Share something with the circle...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
                    fillColor: Colors.white.withValues(alpha: 0.04),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
                if (_pickedFileName != null) ...[
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(_pickedFileName!),
                    onDeleted: () => setState(() => _pickedFileName = null),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.add_photo_alternate_rounded, color: Color(0xFFC084FC)),
                    ),
                    ElevatedButton(
                      onPressed: _isPosting ? null : _createPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        minimumSize: Size.zero,
                      ),
                      child: _isPosting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                          : const Text('Post'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Posts Feed
          postsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFFC084FC)))),
            error: (err, _) => Center(child: Text('Error loading feed: $err', style: const TextStyle(color: Colors.white))),
            data: (posts) {
              if (posts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text('No posts yet. Be the first to share!', style: TextStyle(color: Colors.white.withValues(alpha: 0.50))),
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
                    child: GlassPanel(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: const Color(0xFF8B5CF6),
                                child: Text(post.username.isNotEmpty ? post.username[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(post.username, style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${post.timestamp.day}/${post.timestamp.month} at ${post.timestamp.hour}:${post.timestamp.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.40)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(post.content, style: GoogleFonts.outfit(fontSize: 15, color: Colors.white)),
                          if (post.attachments.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                post.attachments.first.url,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 100,
                                  color: Colors.white.withValues(alpha: 0.05),
                                  child: const Center(child: Icon(Icons.broken_image_rounded, color: Colors.grey)),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
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
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.arrow_upward_rounded, size: 16, color: Color(0xFFC084FC)),
                                      const SizedBox(width: 4),
                                      Text('${post.upvotes}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              InkWell(
                                onTap: () => _showComments(post),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.mode_comment_outlined, size: 15, color: Color(0xFFC084FC)),
                                      SizedBox(width: 4),
                                      Text('Comments', style: TextStyle(color: Colors.white, fontSize: 13)),
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
              Text('Comments', style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Comment>>(
            future: ref.read(appwriteServiceProvider).getComments(widget.post.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return SizedBox(height: 100, child: Center(child: Text('Failed to load comments')));
              }
              final comments = snapshot.data ?? [];
              if (comments.isEmpty) {
                return const SizedBox(height: 100, child: Center(child: Text('No comments yet.')));
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
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(comment.username, style: GoogleFonts.sora(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 2),
                                Text(comment.commentText, style: GoogleFonts.outfit(fontSize: 14)),
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
          const SizedBox(height: 16),
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
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: _isSubmitting ? null : _submitComment,
                icon: const Icon(Icons.send_rounded),
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
      setState(() {
        _messages = messages;
      });
      _scrollToBottom();
    } catch (_) {}

    setState(() => _isLoadingMessages = false);

    // Listen to real-time updates for messages
    _realtimeSubscription = service.watchMessages().listen((msg) async {
      // Event corresponds to message collection
      if (msg.events.any((e) => e.contains('.create'))) {
        final data = Map<String, dynamic>.from(msg.payload);
        if (data['channelId'] == channel.channelId) {
          final message = ChatMessage.fromMap(data['\$id'] ?? '', data);
          final senderProfile = await service.getCurrentProfile(message.senderId);
          setState(() {
            _messages.add(message.copyWith(senderName: senderProfile?.displayName));
          });
          _scrollToBottom();
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
          title: Text('Create Channel', style: GoogleFonts.sora(fontWeight: FontWeight.bold)),
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
              child: const Text('Cancel'),
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
              child: const Text('Create'),
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
          color: Colors.white.withValues(alpha: 0.02),
          child: Row(
            children: [
              Expanded(
                child: channelsAsync.when(
                  loading: () => const Center(child: LinearProgressIndicator()),
                  error: (_, __) => const Text('Error'),
                  data: (channels) {
                    if (channels.isEmpty) {
                      return Text('No channels yet', style: TextStyle(color: Colors.white.withValues(alpha: 0.40)));
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
                                color: isSel ? const Color(0xFF8B5CF6) : Colors.transparent,
                                border: Border.all(color: isSel ? const Color(0xFFC084FC) : Colors.white.withValues(alpha: 0.12)),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  '# ${ch.name}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                    color: isSel ? Colors.white : Colors.white.withValues(alpha: 0.60),
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
                  icon: const Icon(Icons.add_box_rounded, color: Color(0xFFC084FC)),
                ),
            ],
          ),
        ),

        // Messages area
        Expanded(
          child: _selectedChannel == null
              ? Center(child: Text('Please select or create a channel', style: TextStyle(color: Colors.white.withValues(alpha: 0.45))))
              : _isLoadingMessages
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                      ? Center(child: Text('No messages here yet. Start the conversation!', style: TextStyle(color: Colors.white.withValues(alpha: 0.40))))
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
                                  color: isMe ? const Color(0xFF8B5CF6).withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(18),
                                    topRight: const Radius.circular(18),
                                    bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
                                    bottomRight: isMe ? Radius.zero : const Radius.circular(18),
                                  ),
                                  border: Border.all(
                                    color: isMe ? const Color(0xFFC084FC).withValues(alpha: 0.40) : Colors.white.withValues(alpha: 0.06),
                                  ),
                                ),
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isMe)
                                      Text(
                                        msg.senderName ?? 'Member',
                                        style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFC084FC)),
                                      ),
                                    const SizedBox(height: 2),
                                    Text(
                                      msg.text,
                                      style: GoogleFonts.outfit(fontSize: 14, color: Colors.white),
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
              color: Colors.black.withValues(alpha: 0.20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.40)),
                      fillColor: Colors.white.withValues(alpha: 0.04),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send_rounded),
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

  void _showCreateTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Assign Task', style: GoogleFonts.sora(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _taskTitleController,
                  decoration: const InputDecoration(labelText: 'Task Title'),
                ),
                const SizedBox(height: 12),
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
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
                  final task = MentorTask(
                    id: '',
                    circleId: widget.circle.circleId,
                    mentorId: user.id,
                    title: title,
                    description: desc,
                    createdAt: DateTime.now(),
                  );
                  await ref.read(appwriteServiceProvider).createTask(task);
                  _taskTitleController.clear();
                  _taskDescController.clear();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                  ref.invalidate(tasksProvider(widget.circle.circleId));
                } catch (_) {}
                setState(() => _isCreatingTask = false);
              },
              child: const Text('Assign'),
            ),
          ],
        );
      },
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
              title: Text('Submit Task', style: GoogleFonts.sora(fontWeight: FontWeight.bold)),
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
                    const SizedBox(height: 12),
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
                      icon: const Icon(Icons.upload_file_rounded),
                      label: Text(subName != null ? 'File selected: $subName' : 'Select Attachment'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
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
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                      : const Text('Submit'),
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
              title: Text('Grade Submission', style: GoogleFonts.sora(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () => setModalState(() => grade = 'Pass'),
                        style: ElevatedButton.styleFrom(backgroundColor: grade == 'Pass' ? Colors.green : Colors.grey),
                        child: const Text('Pass'),
                      ),
                      ElevatedButton(
                        onPressed: () => setModalState(() => grade = 'Needs Work'),
                        style: ElevatedButton.styleFrom(backgroundColor: grade == 'Needs Work' ? Colors.orange : Colors.grey),
                        child: const Text('Needs Work'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: feedbackController,
                    decoration: const InputDecoration(labelText: 'Feedback notes'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setModalState(() => isSaving = true);
                          await ref.read(appwriteServiceProvider).gradeSubmission(sub.id, grade, feedbackController.text.trim());
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Submission graded!')));
                          }
                          setModalState(() => isSaving = false);
                        },
                  child: const Text('Submit Grade'),
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
              Text('Submissions for: ${task.title}', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<TaskSubmission>>(
                  future: ref.read(appwriteServiceProvider).getSubmissions(task.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final submissions = snapshot.data ?? [];
                    if (submissions.isEmpty) {
                      return const Center(child: Text('No submissions yet.'));
                    }

                    return ListView.builder(
                      itemCount: submissions.length,
                      itemBuilder: (context, index) {
                        final sub = submissions[index];
                        return Card(
                          color: Colors.white.withValues(alpha: 0.05),
                          child: ListTile(
                            title: Text(sub.userName ?? 'Student'),
                            subtitle: Text('Status: ${sub.status.toUpperCase()} | Grade: ${sub.grade ?? 'Unresolved'}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.grade_rounded, color: Color(0xFFC084FC)),
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
              backgroundColor: const Color(0xFF8B5CF6),
              child: const Icon(Icons.add_rounded),
            )
          : null,
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading tasks: $err')),
        data: (tasks) {
          if (tasks.isEmpty) {
            return Center(child: Text('No tasks assigned yet.', style: TextStyle(color: Colors.white.withValues(alpha: 0.40))));
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
                          Expanded(child: Text(task.title, style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.bold))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                            child: Text('Task', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFFC084FC), fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(task.description, style: GoogleFonts.outfit(fontSize: 14, color: Colors.white.withValues(alpha: 0.70))),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isMentor)
                            OutlinedButton.icon(
                              onPressed: () => _viewSubmissions(task),
                              icon: const Icon(Icons.people_outline),
                              label: const Text('View Submissions'),
                            )
                          else
                            ElevatedButton.icon(
                              onPressed: () => _showSubmitTaskDialog(task),
                              icon: const Icon(Icons.send_rounded),
                              label: const Text('Submit Work'),
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
                style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Brainstorm collaborative projects and discussion icebreakers powered by Gemini AI.',
                style: GoogleFonts.outfit(fontSize: 14, color: Colors.white.withValues(alpha: 0.60)),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _generateIdeas(ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: _isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(
                  _isLoading ? 'Brainstorming...' : 'Generate Projects & Icebreakers',
                  style: GoogleFonts.sora(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              if (_suggestions != null)
                GlassPanel(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFC084FC)),
                          const SizedBox(width: 8),
                          Text(
                            'Gemini Suggestions',
                            style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        _suggestions!,
                        style: GoogleFonts.outfit(fontSize: 15, height: 1.5, color: Colors.white.withValues(alpha: 0.90)),
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
