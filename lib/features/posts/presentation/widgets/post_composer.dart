import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
// Removed firebase_auth
import 'package:skill_circle_app/core/services/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/features/posts/domain/entities/post.dart';
import 'package:skill_circle_app/features/posts/presentation/providers/posts_controller_provider.dart';
import 'package:skill_circle_app/features/posts/presentation/providers/posts_providers.dart';
import 'package:skill_circle_app/features/profile/presentation/providers/profile_providers.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

class PostComposer extends ConsumerStatefulWidget {
  const PostComposer({
    super.key,
    required this.circleId,
    this.compact = false,
    this.onSubmitted,
  });

  final String? circleId;
  final bool compact;
  final VoidCallback? onSubmitted;

  @override
  ConsumerState<PostComposer> createState() => _PostComposerState();
}

class _PostComposerState extends ConsumerState<PostComposer> {
  final _contentController = TextEditingController();
  final List<_DraftAttachment> _attachments = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    await _pickMedia(
      title: 'Add images',
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'gif', 'webp'],
    );
  }

  Future<void> _pickVideos() async {
    await _pickMedia(
      title: 'Add videos',
      type: FileType.custom,
      allowedExtensions: const ['mp4', 'mov', 'm4v', 'webm', 'avi'],
    );
  }

  Future<void> _pickFiles() async {
    await _pickMedia(
      title: 'Add files',
      type: FileType.any,
    );
  }

  Future<void> _pickMedia({
    required String title,
    required FileType type,
    List<String>? allowedExtensions,
  }) async {
    if (_isSubmitting) return;

    final result = await FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: allowedExtensions,
      allowMultiple: true,
      withData: true,
      dialogTitle: title,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final picked = <_DraftAttachment>[];
    for (final file in result.files) {
      final bytes = file.bytes;
      if (bytes == null) {
        continue;
      }

      picked.add(
        _DraftAttachment(
          name: file.name,
          bytes: bytes,
          size: file.size,
          contentType: _contentTypeFor(file),
        ),
      );
    }

    if (picked.isEmpty) {
      return;
    }

    setState(() {
      _attachments.addAll(picked);
    });
  }

  Future<void> _submit() async {
    final content = _contentController.text.trim();
    final user = ref.read(authStateProvider).valueOrNull;
    final profile = user == null ? null : ref.read(profileStreamProvider(user.id)).valueOrNull;
    final username = (profile?.displayName ?? user?.displayName ?? 'Community Member').trim();

    if (widget.circleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Open a circle to publish a post')),
      );
      return;
    }

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to post')),
      );
      return;
    }

    if (content.isEmpty && _attachments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add text or at least one attachment')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final storage = ref.read(storageServiceProvider);
      final uploadedAttachments = <Attachment>[];

      for (final draft in _attachments) {
        final uploaded = await storage.uploadFile(
          bytes: draft.bytes,
          filename: draft.name,
          contentType: draft.contentType,
          ownerId: user.id,
        );
        uploadedAttachments.add(uploaded);
      }

      final post = Post(
        id: '',
        userId: user.id,
        username: username,
        circleId: widget.circleId!,
        content: content,
        timestamp: DateTime.now(),
        upvotes: 0,
        attachments: uploadedAttachments,
      );

      await ref.read(postsControllerProvider.notifier).createPost(post);
      ref.read(postsControllerProvider.notifier).watchPosts(widget.circleId!);

      _contentController.clear();
      setState(() {
        _attachments.clear();
      });

      widget.onSubmitted?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post published')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish post: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(widget.compact ? 14 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1CB0C2), Color(0xFF0D5B65)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.edit_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Share an update',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Attach files, images, or videos before posting.',
                        style: TextStyle(color: ClayTokens.textSecond, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _contentController,
              minLines: widget.compact ? 2 : 3,
              maxLines: widget.compact ? 5 : 7,
              decoration: const InputDecoration(
                hintText: 'What are you working on?'
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _AttachmentAction(
                  icon: Icons.image_outlined,
                  label: 'Image',
                  onTap: _isSubmitting ? null : _pickImages,
                ),
                _AttachmentAction(
                  icon: Icons.videocam_outlined,
                  label: 'Video',
                  onTap: _isSubmitting ? null : _pickVideos,
                ),
                _AttachmentAction(
                  icon: Icons.attach_file_rounded,
                  label: 'File',
                  onTap: _isSubmitting ? null : _pickFiles,
                ),
                if (_attachments.isNotEmpty)
                  _AttachmentAction(
                    icon: Icons.clear_all_rounded,
                    label: 'Clear',
                    onTap: _isSubmitting
                        ? null
                        : () => setState(() => _attachments.clear()),
                  ),
              ],
            ),
            if (_attachments.isNotEmpty) ...[
              const SizedBox(height: 14),
              SizedBox(
                height: 114,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _attachments.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final draft = _attachments[index];
                    return _AttachmentPreview(
                      draft: draft,
                      onRemove: _isSubmitting
                          ? null
                          : () => setState(() => _attachments.removeAt(index)),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(_isSubmitting ? 'Publishing...' : 'Publish Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _contentTypeFor(PlatformFile file) {
    final extension = file.extension?.toLowerCase().trim() ?? '';
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'm4v':
        return 'video/x-m4v';
      case 'webm':
        return 'video/webm';
      case 'avi':
        return 'video/x-msvideo';
      case 'pdf':
        return 'application/pdf';
      case 'txt':
        return 'text/plain';
      case 'zip':
        return 'application/zip';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      default:
        return file.extension == null || file.extension!.isEmpty
            ? 'application/octet-stream'
            : 'application/${file.extension!.toLowerCase()}';
    }
  }
}

class _DraftAttachment {
  const _DraftAttachment({
    required this.name,
    required this.bytes,
    required this.size,
    required this.contentType,
  });

  final String name;
  final Uint8List bytes;
  final int size;
  final String contentType;

  bool get isImage => contentType.startsWith('image/');
  bool get isVideo => contentType.startsWith('video/');
}

class _AttachmentAction extends StatelessWidget {
  const _AttachmentAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: ClayTokens.brandDeep),
      label: Text(label),
      onPressed: onTap,
      side: BorderSide(color: ClayTokens.brandLight.withValues(alpha: 0.8)),
      backgroundColor: ClayTokens.brandPale.withValues(alpha: 0.65),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  const _AttachmentPreview({
    required this.draft,
    required this.onRemove,
  });

  final _DraftAttachment draft;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 140,
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: ClayTokens.pageBg,
            border: Border.all(color: ClayTokens.brandLight.withValues(alpha: 0.5)),
          ),
          clipBehavior: Clip.antiAlias,
          child: draft.isImage
              ? Image.memory(draft.bytes, fit: BoxFit.cover)
              : _AttachmentFallback(
                  icon: draft.isVideo ? Icons.videocam_rounded : Icons.insert_drive_file_rounded,
                  title: draft.name,
                  subtitle: _formatBytes(draft.size),
                ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton.filled(
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded, size: 16),
            style: IconButton.styleFrom(
              minimumSize: const Size(28, 28),
              maximumSize: const Size(28, 28),
              backgroundColor: Colors.black.withValues(alpha: 0.55),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }
}

class _AttachmentFallback extends StatelessWidget {
  const _AttachmentFallback({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          Icon(icon, color: Colors.white, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFFE3FBFF), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
