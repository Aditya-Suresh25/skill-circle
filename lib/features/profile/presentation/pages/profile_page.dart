import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skill_circle_app/core/constants/app_routes.dart';
import 'package:skill_circle_app/core/services/app_router.dart';
import 'package:skill_circle_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:skill_circle_app/features/profile/presentation/providers/profile_providers.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

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

    final authUser = ref.read(authStateProvider).valueOrNull;
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
    final authUser = ref.read(authStateProvider).valueOrNull;
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
    final authUser = ref.read(authStateProvider).valueOrNull;
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
    final authUser = ref.watch(authStateProvider).valueOrNull;
    final profileAsync = authUser != null
        ? ref.watch(profileStreamProvider(authUser.id))
        : const AsyncValue.loading();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          onPressed: () => context.go(AppRoutes.home),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: authUser == null
          ? const Center(child: Text('Not authenticated'))
          : profileAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, st) => Center(
                child: Text('Error loading profile: $error'),
              ),
              data: (profile) {
                // Initialize controllers with current values
                if (_nameController.text.isEmpty && profile != null) {
                  _nameController.text = profile.displayName;
                  _bioController.text = profile.bio ?? '';
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Avatar
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: ClayTokens.clayShadow,
                            ),
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: ClayTokens.brandPale,
                              backgroundImage:
                                  profile?.photoUrl != null && _pickedImage == null
                                      ? NetworkImage(profile!.photoUrl!)
                                      : _pickedImage != null
                                          ? FileImage(_pickedImage!)
                                          : null,
                              child: (profile?.photoUrl == null &&
                                      _pickedImage == null)
                                  ? const Icon(Icons.person,
                                      color: ClayTokens.brand, size: 32)
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ClayTokens.brand,
                                boxShadow: ClayTokens.clayShadow,
                              ),
                              child: IconButton(
                                onPressed: _isUploadingImage
                                    ? null
                                    : _pickImage,
                                icon: _isUploadingImage
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  ClayTokens.surface),
                                        ),
                                      )
                                    : const Icon(Icons.camera_alt,
                                        color: ClayTokens.surface, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Name Field
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bio Field
                      TextField(
                        controller: _bioController,
                        decoration: InputDecoration(
                          labelText: 'Bio',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),

                      // Joined Skills
                      if (profile?.joinedSkills.isNotEmpty ?? false) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Joined Skills (${profile!.joinedSkills.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final skill in profile.joinedSkills)
                              Chip(
                                label: Text(skill),
                                backgroundColor: ClayTokens.brandPale,
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // User Info Display
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ClayTokens.pageBg,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: ClayTokens.clayShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Email', authUser.email ?? 'N/A'),
                            if (profile?.createdAt != null) ...[
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                'Joined',
                                _formatDate(profile!.createdAt!),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Action Buttons
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          child: const Text('Save Profile'),
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (profile?.photoUrl != null)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _deleteProfileImage,
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete Profile Image'),
                          ),
                        ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () async {
                            await ref
                                .read(authControllerProvider.notifier)
                                .signOut();
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
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ClayTokens.textSecond,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ClayTokens.textPrimary,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}