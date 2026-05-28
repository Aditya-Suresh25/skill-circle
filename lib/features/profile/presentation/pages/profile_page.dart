import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skill_circle_app/core/constants/app_routes.dart';
import 'package:skill_circle_app/core/presentation/widgets/aurora_background.dart';
import 'package:skill_circle_app/core/presentation/widgets/glass/glass.dart';
import 'package:skill_circle_app/core/services/app_router.dart';
import 'package:skill_circle_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:skill_circle_app/features/profile/domain/entities/profile.dart';
import 'package:skill_circle_app/features/profile/presentation/providers/profile_providers.dart';
import 'package:skill_circle_app/models/badge_model.dart' as shared_models;

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  File? _pickedImage;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final imagePicker = ImagePicker();
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
        await _uploadImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_pickedImage == null) return;

    final authUser = ref.read(routerAuthStateProvider).valueOrNull;
    if (authUser == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final profileController = ref.read(profileControllerProvider.notifier);
      final downloadUrl = await profileController.uploadProfileImage(
        authUser.id,
        _pickedImage!,
      );

      if (downloadUrl != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully')),
        );
        setState(() => _pickedImage = null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    final authUser = ref.read(routerAuthStateProvider).valueOrNull;
    if (authUser == null) return;

    final updates = <String, dynamic>{};
    if (_nameController.text.isNotEmpty &&
        _nameController.text != (ref.read(profileStreamProvider(authUser.id)).valueOrNull?.displayName ?? '')) {
      updates['displayName'] = _nameController.text.trim();
    }
    if (_bioController.text.isNotEmpty) {
      updates['bio'] = _bioController.text.trim();
    }

    if (updates.isEmpty) return;

    try {
      final profileController = ref.read(profileControllerProvider.notifier);
      await profileController.updateProfile(authUser.id, updates);

      if (mounted) {
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  Future<void> _deleteProfileImage() async {
    final authUser = ref.read(routerAuthStateProvider).valueOrNull;
    if (authUser == null) return;

    try {
      final profileController = ref.read(profileControllerProvider.notifier);
      await profileController.deleteProfileImage(authUser.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF2B1D3F);
    final authUser = ref.watch(routerAuthStateProvider).valueOrNull;
    final profileAsync = authUser != null
        ? ref.watch(profileStreamProvider(authUser.id))
        : const AsyncValue.loading();
    final badgesAsync = authUser != null
      ? ref.watch(userBadgesProvider(authUser.id))
      : const AsyncValue<List<shared_models.BadgeModel>>.data(<shared_models.BadgeModel>[]);

    if (authUser != null) {
      ref.listen<AsyncValue<Profile?>>(profileStreamProvider(authUser.id), (previous, next) {
        final profile = next.valueOrNull;
        if (profile != null) {
          if (!FocusScope.of(context).hasFocus) {
             _nameController.text = profile.displayName;
             _bioController.text = profile.bio ?? '';
          }
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: AuroraBackground(
        child: authUser == null
            ? const Center(child: Text('Not authenticated'))
            : profileAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, st) => Center(
                  child: Text('Error loading profile: $error'),
                ),
                data: (profile) {
                  if (_nameController.text.isEmpty && profile != null) {
                    _nameController.text = profile.displayName;
                    _bioController.text = profile.bio ?? '';
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              colors: isDark
                                  ? const [Color(0xFF3B1C5B), Color(0xFF8B5CF6)]
                                  : const [Color(0xFF7C3AED), Color(0xFFC084FC)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.white,
                                    backgroundImage: profile?.photoUrl != null && _pickedImage == null
                                        ? NetworkImage(profile!.photoUrl!)
                                        : _pickedImage != null
                                            ? FileImage(_pickedImage!)
                                            : null,
                                    child: (profile?.photoUrl == null && _pickedImage == null)
                                        ? const Icon(Icons.person, color: Color(0xFF6D28D9), size: 30)
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: -2,
                                    right: -2,
                                    child: IconButton.filled(
                                      onPressed: _isUploadingImage ? null : _pickImage,
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: const Color(0xFF6D28D9),
                                      ),
                                      icon: _isUploadingImage
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Icon(Icons.camera_alt_rounded, size: 18),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile?.displayName ?? 'Member',
                                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      authUser.email ?? 'N/A',
                                      style: const TextStyle(color: Color(0xFFEDE9FE)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 14),
                      GlassPanel(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                              TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Name',
                                  prefixIcon: Icon(Icons.person),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _bioController,
                                decoration: const InputDecoration(
                                  labelText: 'Bio',
                                  prefixIcon: Icon(Icons.description),
                                ),
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (profile?.joinedSkills.isNotEmpty ?? false)
                        GlassPanel(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Joined Skills (${profile!.joinedSkills.length})',
                                  style: TextStyle(fontWeight: FontWeight.w700, color: titleColor),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (final skill in profile.joinedSkills)
                                      Chip(label: Text(skill), backgroundColor: const Color(0xFFE9D5FF)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      badgesAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (badges) {
                          if (badges.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return GlassPanel(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Badges (${badges.length})',
                                    style: TextStyle(fontWeight: FontWeight.w700, color: titleColor),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      for (final badge in badges)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            color: badge.isLocked ? Colors.grey.shade100 : const Color(0xFFEDE9FE),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.workspace_premium_rounded,
                                                size: 18,
                                                color: badge.isLocked ? Colors.grey : const Color(0xFF5B21B6),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                badge.title,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: badge.isLocked ? Colors.grey.shade600 : const Color(0xFF5B21B6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      GlassPanel(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                              _buildInfoRow('Email', authUser.email ?? 'N/A'),
                              if (profile?.createdAt != null) ...[
                                const SizedBox(height: 8),
                                _buildInfoRow('Joined', _formatDate(profile!.createdAt!)),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          child: const Text('Save Profile'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (profile?.photoUrl != null)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _deleteProfileImage,
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: const Text('Delete Profile Image'),
                          ),
                        ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () async {
                            await ref.read(authControllerProvider.notifier).signOut();
                            if (context.mounted) {
                              context.go(AppRoutes.login);
                            }
                          },
                          child: const Text('Sign Out'),
                        ),
                      ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFFD5CEE3) : const Color(0xFF65587D),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF2A1C3F),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
