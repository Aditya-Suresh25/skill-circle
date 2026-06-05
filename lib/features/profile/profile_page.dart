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
                    color: Colors.black.withValues(alpha: 0.15),
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
                        style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: bioController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),
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
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)),
                          )
                        : const Text('Save Changes'),
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
    ];

    return Scaffold(
      body: AuroraBackground(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              title: Text(
                'My Profile',
                style: GoogleFonts.sora(fontWeight: FontWeight.bold),
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
                    color: Colors.white,
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
                GlassPanel(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFC084FC), width: 3),
                            ),
                            child: CircleAvatar(
                              radius: 54,
                              backgroundColor: Colors.grey.shade900,
                              backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                              child: user.photoUrl == null
                                  ? const Icon(Icons.person_rounded, size: 54, color: Colors.white)
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
                                  color: Color(0xFF8B5CF6),
                                  shape: BoxShape.circle,
                                ),
                                child: _isUploadingImage
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                                      )
                                    : const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.displayName,
                        style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: GoogleFonts.outfit(fontSize: 14, color: Colors.white.withValues(alpha: 0.60)),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFC084FC).withValues(alpha: 0.40)),
                        ),
                        child: Text(
                          user.role.toUpperCase(),
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFC084FC)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            user.bio!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(fontSize: 15, color: Colors.white.withValues(alpha: 0.80)),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      OutlinedButton.icon(
                        onPressed: () => _showEditProfileDialog(user),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.20)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: const Text('Edit Details'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Stats Section
                Row(
                  children: [
                    Expanded(
                      child: GlassPanel(
                        child: Column(
                          children: [
                            Text(
                              user.joinedSkills.length.toString(),
                              style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Circles Joined',
                              style: GoogleFonts.outfit(fontSize: 13, color: Colors.white.withValues(alpha: 0.50)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassPanel(
                        child: Column(
                          children: [
                            Text(
                              badges.where((b) => b.unlocked).length.toString(),
                              style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Badges Earned',
                              style: GoogleFonts.outfit(fontSize: 13, color: Colors.white.withValues(alpha: 0.50)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Badges Showcase
                Text(
                  'My Badges',
                  style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12),
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
                    return GlassPanel(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            badge.icon,
                            size: 32,
                            color: badge.unlocked ? const Color(0xFFC084FC) : Colors.white.withValues(alpha: 0.20),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            badge.title,
                            style: GoogleFonts.sora(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: badge.unlocked ? Colors.white : Colors.white.withValues(alpha: 0.30),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            badge.unlocked ? badge.description : 'Locked',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: badge.unlocked ? Colors.white.withValues(alpha: 0.60) : Colors.white.withValues(alpha: 0.20),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

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
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign Out'),
                ),
                const SizedBox(height: 48),
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
