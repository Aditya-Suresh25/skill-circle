import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/presentation/widgets/aurora_background.dart';
import 'package:skill_circle_app/core/presentation/widgets/glass/glass.dart';
import 'package:skill_circle_app/core/services/app_router.dart';
import 'package:skill_circle_app/features/mentor/domain/entities/task.dart';
import 'package:skill_circle_app/features/mentor/presentation/providers/mentor_providers.dart';
import 'package:uuid/uuid.dart';
import 'package:skill_circle_app/features/posts/domain/entities/post.dart' show Attachment;
import 'package:skill_circle_app/features/posts/presentation/providers/posts_providers.dart' show storageServiceProvider;

class MentorTaskEditorPage extends ConsumerStatefulWidget {
  const MentorTaskEditorPage({super.key, required this.circleId, this.task});

  final String circleId;
  final MentorTask? task;

  @override
  ConsumerState<MentorTaskEditorPage> createState() => _MentorTaskEditorPageState();
}

class _MentorTaskEditorPageState extends ConsumerState<MentorTaskEditorPage> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _difficulty = ValueNotifier<String>('Beginner');
  DateTime? _deadline;
  final List<Attachment> _resources = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    if (t != null) {
      _title.text = t.title;
      _desc.text = t.description;
      _difficulty.value = t.difficulty;
      _deadline = t.deadline;
      _resources.addAll(t.resources);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _difficulty.dispose();
    super.dispose();
  }

  String _contentTypeFromFilename(String name) {
    final ext = name.split('.').last.toLowerCase();
    if (['jpg', 'jpeg'].contains(ext)) return 'image/jpeg';
    if (ext == 'png') return 'image/png';
    if (ext == 'gif') return 'image/gif';
    if (ext == 'webp') return 'image/webp';
    if (ext == 'pdf') return 'application/pdf';
    if (ext == 'mp4') return 'video/mp4';
    return 'application/octet-stream';
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true, withData: true);
    if (result == null) return;
    final storage = ref.read(storageServiceProvider);
    final userId = ref.read(routerAuthStateProvider).valueOrNull?.id ?? '';
    for (final file in result.files) {
      final bytes = file.bytes;
      if (bytes == null) continue;
      final uploaded = await storage.uploadFile(bytes: bytes, filename: file.name, contentType: _contentTypeFromFilename(file.name), ownerId: userId);
      _resources.add(uploaded);
    }
    setState(() {});
  }

  Future<void> _save() async {
    final repo = ref.read(mentorRepositoryProvider);
    if (_title.text.trim().isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      final id = widget.task?.id ?? const Uuid().v4();
      final task = MentorTask(
        id: id,
        circleId: widget.circleId,
        mentorId: ref.read(routerAuthStateProvider).valueOrNull?.id ?? '',
        title: _title.text.trim(),
        description: _desc.text.trim(),
        deadline: _deadline,
        difficulty: _difficulty.value,
        orderIndex: widget.task?.orderIndex ?? 0,
        resources: List<Attachment>.from(_resources),
        createdAt: widget.task?.createdAt ?? DateTime.now(),
      );
      if (widget.task == null) {
        await repo.createTask(task);
      } else {
        await repo.updateTask(task);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save task: $e')));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF2A1C3F);
    final subtitleColor = isDark ? const Color(0xFFD5CEE4) : const Color(0xFF675A7D);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(widget.task == null ? 'Create Task' : 'Edit Task'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (widget.task != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final repo = ref.read(mentorRepositoryProvider);
                try {
                  await repo.deleteTask(widget.task!.id);
                  if (mounted) Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
                }
              },
            ),
        ],
      ),
      body: AuroraBackground(
        child: ListView(
          padding: GlassTokens.pagePadding,
          children: [
            GlassPageHeader(
              title: widget.task == null ? 'Compose Mentor Task' : 'Refine Mentor Task',
              subtitle: 'Structure clear outcomes, resources, and a level to help learners execute with confidence.',
            ),
            const SizedBox(height: 12),
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _desc,
                    decoration: const InputDecoration(labelText: 'Description'),
                    minLines: 3,
                    maxLines: 6,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('Difficulty:', style: TextStyle(color: subtitleColor, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      ValueListenableBuilder<String>(
                        valueListenable: _difficulty,
                        builder: (context, value, child) {
                          return DropdownButton<String>(
                            value: value,
                            items: const ['Beginner', 'Intermediate', 'Advanced']
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) => _difficulty.value = v ?? 'Beginner',
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: _pickFiles,
                        icon: const Icon(Icons.attach_file_rounded),
                        label: const Text('Add Resources'),
                      ),
                      if (_deadline != null)
                        Text(
                          'Deadline: ${_deadline!.toLocal().toIso8601String().split('T').first}',
                          style: TextStyle(color: subtitleColor, fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_resources.isNotEmpty)
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attached resources',
                      style: TextStyle(
                        color: titleColor,
                        fontWeight: FontWeight.w700,
                        fontSize: GlassTokens.sectionTitleSize,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final r = _resources[index];
                          return Container(
                            width: 170,
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isDark ? Colors.white.withValues(alpha: 0.16) : Colors.white.withValues(alpha: 0.9),
                              ),
                              borderRadius: BorderRadius.circular(14),
                              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.7),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: r.contentType.startsWith('image/')
                                      ? ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                          child: Image.network(r.url, fit: BoxFit.cover, width: double.infinity),
                                        )
                                      : Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            child: Text(r.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                                          ),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemCount: _resources.length,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _save,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
