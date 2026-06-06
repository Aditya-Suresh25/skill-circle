import 'package:skill_circle_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skill_circle_app/core/appwrite.dart';
import 'package:skill_circle_app/core/theme.dart';
import 'package:skill_circle_app/core/widgets/glass.dart';
import 'package:skill_circle_app/models/user.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isUploadingImage = false;

  Future<void> _pickAndUploadImage(AppUser user) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return;

      setState(() => _isUploadingImage = true);

      final bytes = await image.readAsBytes();
      final filename = image.name;
      final contentType = image.mimeType ?? 'image/jpeg';

      final service = ref.read(appwriteServiceProvider);
      final attachment = await service.uploadFile(bytes, filename, contentType, user.id);

      // Save updated photo url
      final updatedUser = await service.updateProfile(user.id, photoUrl: attachment.url);
      ref.read(currentUserProvider.notifier).setUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload profile picture: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  void _showEditProfileDialog(AppUser user) {
    final nameController = TextEditingController(text: user.displayName);
    final bioController = TextEditingController(text: user.bio);
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: context.textColor.withValues(alpha: 0.15),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit Profile',
                        style: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: bioController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            setModalState(() => isSaving = true);
                            try {
                              final updatedUser = await ref.read(appwriteServiceProvider).updateProfile(
                                    user.id,
                                    displayName: nameController.text.trim(),
                                    bio: bioController.text.trim(),
                                  );
                              ref.read(currentUserProvider.notifier).setUser(updatedUser);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Profile saved successfully!')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to save profile: $e')),
                                );
                              }
                            } finally {
                              setModalState(() => isSaving = false);
                            }
                          },
                    child: isSaving
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(context.textColor)),
                          )
                        : Text('Save Changes'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Unlocked Badges criteria
    final badges = [
      _Badge(
        title: 'First Step',
        description: 'Joined your first skill circle.',
        icon: Icons.explore_rounded,
        unlocked: user.joinedSkills.isNotEmpty,
      ),
      _Badge(
        title: 'Bio Master',
        description: 'Told the community about yourself.',
        icon: Icons.assignment_ind_rounded,
        unlocked: user.bio != null && user.bio!.trim().isNotEmpty,
      ),
      _Badge(
        title: 'Elite Member',
        description: 'Assigned as a mentor or admin.',
        icon: Icons.workspace_premium_rounded,
        unlocked: user.role == 'mentor' || user.role == 'admin',
      ),
      _Badge(
        title: 'Innovator',
        description: 'Created a unique display name.',
        icon: Icons.lightbulb_rounded,
        unlocked: user.displayName.isNotEmpty && user.displayName != 'User',
      ),
      _Badge(
        title: 'Task Achiever',
        description: 'Successfully completed a skill task.',
        icon: Icons.check_circle_outline_rounded,
        unlocked: user.joinedSkills.any((s) => s.startsWith('task_')),
      ),
    ];

    return Scaffold(
      body: AuroraBackground(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              title: Text(
                'My Profile',
                style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
              ),
              pinned: true,
              floating: true,
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                  onPressed: () {
                    ref.read(themeModeProvider.notifier).toggleTheme();
                  },
                  icon: Icon(
                    themeMode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: context.textColor,
                  ),
                ),
              ],
            ),
          ],
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Header Card
                GradientPanel(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.twitchPurpleLight, width: 3),
                            ),
                            child: CircleAvatar(
                              radius: 54,
                              backgroundColor: Colors.grey.shade900,
                              backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                              child: user.photoUrl == null
                                  ? Icon(Icons.person_rounded, size: 54, color: context.textColor)
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _isUploadingImage ? null : () => _pickAndUploadImage(user),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.twitchPurple,
                                  shape: BoxShape.circle,
                                ),
                                child: _isUploadingImage
                                    ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(context.textColor)),
                                      )
                                    : Icon(Icons.camera_alt_rounded, size: 16, color: context.textColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        user.displayName,
                        style: GoogleFonts.lexend(fontSize: 22, fontWeight: FontWeight.bold, color: context.textColor),
                      ),
                      SizedBox(height: 4),
                      Text(
                        user.email,
                        style: GoogleFonts.inter(fontSize: 14, color: context.textColor.withValues(alpha: 0.60)),
                      ),
                      SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.twitchPurple.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.twitchPurpleLight.withValues(alpha: 0.40)),
                        ),
                        child: Text(
                          user.role.toUpperCase(),
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.twitchPurpleLight),
                        ),
                      ),
                      SizedBox(height: 16),
                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            user.bio!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 15, color: context.textColor.withValues(alpha: 0.80)),
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                      OutlinedButton.icon(
                        onPressed: () => _showEditProfileDialog(user),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.textColor,
                          side: BorderSide(color: context.textColor.withValues(alpha: 0.20)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        icon: Icon(Icons.edit_rounded, size: 18),
                        label: Text('Edit Details'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Stats Section
                Row(
                  children: [
                    Expanded(
                      child: GradientPanel(
                        child: Column(
                          children: [
                            Text(
                              user.joinedSkills.length.toString(),
                              style: GoogleFonts.lexend(fontSize: 28, fontWeight: FontWeight.bold, color: context.textColor),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Circles Joined',
                              style: GoogleFonts.inter(fontSize: 13, color: context.textColor.withValues(alpha: 0.50)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: GradientPanel(
                        child: Column(
                          children: [
                            Text(
                              badges.where((b) => b.unlocked).length.toString(),
                              style: GoogleFonts.lexend(fontSize: 28, fontWeight: FontWeight.bold, color: context.textColor),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Badges Earned',
                              style: GoogleFonts.inter(fontSize: 13, color: context.textColor.withValues(alpha: 0.50)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Badges Showcase
                Text(
                  'My Badges',
                  style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold, color: context.textColor),
                ),
                SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: badges.length,
                  itemBuilder: (context, index) {
                    final badge = badges[index];
                    return GradientPanel(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            badge.icon,
                            size: 32,
                            color: badge.unlocked ? AppColors.twitchPurpleLight : context.textColor.withValues(alpha: 0.20),
                          ),
                          SizedBox(height: 8),
                          Text(
                            badge.title,
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: badge.unlocked ? context.textColor : context.textColor.withValues(alpha: 0.30),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            badge.unlocked ? badge.description : 'Locked',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: badge.unlocked ? context.textColor.withValues(alpha: 0.60) : context.textColor.withValues(alpha: 0.20),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 24),

                // Logout Button
                ElevatedButton.icon(
                  onPressed: () async {
                    await ref.read(currentUserProvider.notifier).signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.15),
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent, width: 1.2),
                    elevation: 0,
                  ),
                  icon: Icon(Icons.logout_rounded),
                  label: Text('Sign Out'),
                ),
                SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge {
  const _Badge({
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;
}
