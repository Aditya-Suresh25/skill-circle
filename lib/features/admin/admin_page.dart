import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_circle_app/core/appwrite.dart';
import 'package:skill_circle_app/core/widgets/glass.dart';
import 'package:skill_circle_app/models/user.dart';

final adminUsersProvider = FutureProvider.autoDispose<List<AppUser>>((ref) async {
  return ref.watch(appwriteServiceProvider).getAllUsers();
});

class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> {
  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Control', style: GoogleFonts.sora(fontWeight: FontWeight.bold)),
      ),
      body: AuroraBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'User Management',
                style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage registrations and update system-wide roles.',
                style: GoogleFonts.outfit(fontSize: 14, color: Colors.white.withValues(alpha: 0.60)),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: usersAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Failed to load users: $err')),
                  data: (users) {
                    if (users.isEmpty) {
                      return const Center(child: Text('No users registered yet.'));
                    }

                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: GlassPanel(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFF8B5CF6),
                                  child: Text(user.displayName[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(user.displayName, style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                                      const SizedBox(height: 2),
                                      Text(user.email, style: GoogleFonts.outfit(fontSize: 13, color: Colors.white.withValues(alpha: 0.50))),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                DropdownButton<String>(
                                  value: user.role,
                                  dropdownColor: Colors.grey.shade900,
                                  style: const TextStyle(color: Colors.white),
                                  underline: const SizedBox(),
                                  items: ['student', 'mentor', 'admin'].map((role) {
                                    return DropdownMenuItem<String>(
                                      value: role,
                                      child: Text(role.toUpperCase(), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                                    );
                                  }).toList(),
                                  onChanged: (newRole) async {
                                    if (newRole == null || newRole == user.role) return;
                                    final messenger = ScaffoldMessenger.of(context);
                                    try {
                                      await ref.read(appwriteServiceProvider).updateUserRole(user.id, newRole);
                                      ref.invalidate(adminUsersProvider);
                                      messenger.showSnackBar(
                                        SnackBar(content: Text('Updated ${user.displayName} to $newRole')),
                                      );
                                    } catch (e) {
                                      messenger.showSnackBar(
                                        SnackBar(content: Text('Failed to update role: $e')),
                                      );
                                    }
                                  },
                                ),
                              ],
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
        ),
      ),
    );
  }
}
