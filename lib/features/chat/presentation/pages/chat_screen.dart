// Removed firebase_auth
import 'package:skill_circle_app/core/services/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/features/chat/domain/entities/channel.dart';
import 'package:skill_circle_app/features/chat/presentation/providers/chat_providers.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

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

  @override
  void initState() {
    super.initState();
    _currentUserId = ref.read(authStateProvider).valueOrNull?.id ?? '';
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
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
    if (text.isEmpty) return;

    final repo = ref.read(chatRepositoryProvider);
    _textController.clear();
    await repo.sendMessage(widget.circleId, widget.channel.id, _currentUserId, text);
    await repo.setTypingStatus(widget.circleId, widget.channel.id, _currentUserId, false);
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesStreamProvider({
      'circleId': widget.circleId,
      'channelId': widget.channel.id,
    }));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('# ${widget.channel.name}'),
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
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  );
                }
                return Text(
                  '${typers.length} person(s) typing...',
                  style: const TextStyle(fontSize: 12, color: Colors.yellow, fontWeight: FontWeight.bold),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('Error: $err')),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text('No messages yet. Say hi!'));
                }
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == _currentUserId;

                    // Optimistic read status update
                    if (!isMe && !message.readBy.contains(_currentUserId)) {
                      Future.microtask(() => ref.read(chatRepositoryProvider).markMessageRead(
                        widget.circleId, widget.channel.id, message.id, _currentUserId,
                      ));
                    }

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? ClayTokens.brandPale : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                            bottomLeft: !isMe ? const Radius.circular(0) : const Radius.circular(16),
                          ),
                        ),
                        child: Text(message.text),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: 'Message #${widget.channel.name}',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          ),
        ],
      ),
    );
  }
}
