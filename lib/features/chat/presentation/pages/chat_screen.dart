import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/presentation/widgets/aurora_background.dart';
import 'package:skill_circle_app/core/presentation/widgets/glass/glass.dart';
import 'package:skill_circle_app/core/services/app_router.dart';
import 'package:skill_circle_app/features/chat/domain/entities/channel.dart';
import 'package:skill_circle_app/features/chat/presentation/providers/chat_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.circleId, required this.channel});

  final String circleId;
  final Channel channel;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _currentUserId = '';
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _currentUserId = ref.read(routerAuthStateProvider).valueOrNull?.id ?? '';
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (_currentUserId.isNotEmpty) {
      ref.read(chatRepositoryProvider).setTypingStatus(widget.circleId, widget.channel.id, _currentUserId, false);
    }
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final repo = ref.read(chatRepositoryProvider);
    if (_textController.text.isNotEmpty) {
      repo.setTypingStatus(widget.circleId, widget.channel.id, _currentUserId, true);
    } else {
      repo.setTypingStatus(widget.circleId, widget.channel.id, _currentUserId, false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isSending) return;

    final repo = ref.read(chatRepositoryProvider);
    setState(() => _isSending = true);
    try {
      _textController.clear();
      await repo.sendMessage(widget.circleId, widget.channel.id, _currentUserId, text);
      await repo.setTypingStatus(widget.circleId, widget.channel.id, _currentUserId, false);
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesStreamProvider({
      'circleId': widget.circleId,
      'channelId': widget.channel.id,
    }));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF2A1C3F);
    final subtitleColor = isDark ? const Color(0xFFD5CFE4) : const Color(0xFF675A7E);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '# ${widget.channel.name}',
              style: TextStyle(color: titleColor, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            StreamBuilder(
              stream: ref.watch(chatRepositoryProvider).watchChannels(widget.circleId),
              builder: (context, snapshot) {
                final channels = snapshot.data ?? [];
                final currentChannel = channels.firstWhere(
                  (c) => c.id == widget.channel.id,
                  orElse: () => widget.channel,
                );

                final typers = currentChannel.typing.where((uid) => uid != _currentUserId).toList();
                if (typers.isEmpty) {
                  return Text(
                    widget.channel.description,
                    style: TextStyle(fontSize: 12, color: subtitleColor),
                  );
                }
                return AnimatedSwitcher(
                  duration: GlassTokens.motionFast,
                  child: Text(
                    '${typers.length} person(s) typing...',
                    key: ValueKey(typers.length),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: AuroraBackground(
        child: Column(
          children: [
            Expanded(
              child: messagesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => Center(child: Text('Error: $err')),
                data: (messages) {
                  if (messages.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: GlassPageHeader(
                        title: 'Start the thread',
                        subtitle: 'No messages yet in #${widget.channel.name}. Be the first to break the silence.',
                      ),
                    );
                  }
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == _currentUserId;

                      if (!isMe && !message.readBy.contains(_currentUserId)) {
                        Future.microtask(() => ref.read(chatRepositoryProvider).markMessageRead(
                              widget.circleId,
                              widget.channel.id,
                              message.id,
                              _currentUserId,
                            ));
                      }

                      return _MessageBubble(
                        text: message.text,
                        isMe: isMe,
                      );
                    },
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: GlassPanel(
                  padding: GlassTokens.panelPaddingDense,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            hintText: 'Message #${widget.channel.name}',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filled(
                        onPressed: _isSending ? null : _sendMessage,
                        icon: _isSending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.text, required this.isMe});

  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: AnimatedContainer(
        duration: GlassTokens.motionFast,
        curve: GlassTokens.motionCurve,
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isMe
                ? (isDark
                    ? const [Color(0xFF8B5CF6), Color(0xFF6D28D9)]
                    : const [Color(0xFFA855F7), Color(0xFF7E22CE)])
                : (isDark
                    ? [Colors.white.withValues(alpha: 0.14), Colors.white.withValues(alpha: 0.06)]
                    : [Colors.white.withValues(alpha: 0.78), Colors.white.withValues(alpha: 0.58)]),
          ),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMe ? Colors.white : (isDark ? Colors.white : const Color(0xFF2A1C3F)),
            height: 1.35,
          ),
        ),
      ),
    );
  }
}
