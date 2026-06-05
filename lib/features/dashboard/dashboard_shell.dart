import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_circle_app/core/appwrite.dart';

class DashboardShell extends ConsumerWidget {
  const DashboardShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Construct dynamic tabs based on user role
    final tabs = [
      _ShellTab(route: '/circles', label: 'Circles', icon: Icons.bubble_chart_rounded),
      _ShellTab(route: '/ai-writer', label: 'AI Writer', icon: Icons.auto_awesome_rounded),
      _ShellTab(route: '/profile', label: 'Profile', icon: Icons.person_rounded),
    ];

    if (user != null) {
      if (user.role == 'mentor' || user.role == 'admin') {
        tabs.insert(2, _ShellTab(route: '/mentor', label: 'Mentor', icon: Icons.psychology_rounded));
      }
      if (user.role == 'admin') {
        tabs.insert(tabs.length - 1, _ShellTab(route: '/admin', label: 'Admin', icon: Icons.admin_panel_settings_rounded));
      }
    }

    final location = GoRouterState.of(context).uri.toString();
    int selectedIndex = tabs.indexWhere((t) => location.startsWith(t.route));
    if (selectedIndex == -1) selectedIndex = 0;

    return Scaffold(
      extendBody: true, // Make body draw behind the floating bar
      body: child,
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 68,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.60)
                    : Colors.white.withValues(alpha: 0.70),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(tabs.length, (index) {
                    final tab = tabs[index];
                    final isSelected = selectedIndex == index;
                    return GestureDetector(
                      onTap: () => context.go(tab.route),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF8B5CF6).withValues(alpha: 0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              tab.icon,
                              color: isSelected
                                  ? const Color(0xFFC084FC)
                                  : (isDark ? Colors.white.withValues(alpha: 0.40) : Colors.black.withValues(alpha: 0.40)),
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tab.label,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFFC084FC)
                                  : (isDark ? Colors.white.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.45)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShellTab {
  const _ShellTab({required this.route, required this.label, required this.icon});

  final String route;
  final String label;
  final IconData icon;
}
