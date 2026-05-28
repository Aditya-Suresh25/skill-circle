import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:skill_circle_app/features/mentor/presentation/providers/mentor_providers.dart';
import 'package:skill_circle_app/core/services/app_router.dart';
import 'package:skill_circle_app/features/mentor/domain/entities/mentor.dart' as mentor_entity;

class MentorSignupPage extends ConsumerStatefulWidget {
  const MentorSignupPage({super.key});

  @override
  ConsumerState<MentorSignupPage> createState() => _MentorSignupPageState();
}

class _MentorSignupPageState extends ConsumerState<MentorSignupPage> {
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _skillsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final displayName = _displayNameController.text.trim();
    if (displayName.isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(mentorRepositoryProvider);
      final id = const Uuid().v4();
      final skills = _skillsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      final m = mentor_entity.Mentor(
        id: id,
        userId: ref.read(routerAuthStateProvider).valueOrNull?.id ?? '',
        displayName: displayName,
        bio: _bioController.text.trim(),
        skills: skills,
        createdAt: DateTime.now(),
      );
      await repo.createMentor(m);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/mentor/dashboard');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to register as mentor: $e')));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mentor Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _displayNameController, decoration: const InputDecoration(labelText: 'Display name')),
            const SizedBox(height: 8),
            TextField(controller: _bioController, decoration: const InputDecoration(labelText: 'Short bio')),
            const SizedBox(height: 8),
            TextField(controller: _skillsController, decoration: const InputDecoration(labelText: 'Skills (comma-separated)')),
            const SizedBox(height: 16),
            FilledButton.tonal(onPressed: _isSubmitting ? null : _submit, child: _isSubmitting ? const CircularProgressIndicator() : const Text('Apply as Mentor'))
          ],
        ),
      ),
    );
  }
}
