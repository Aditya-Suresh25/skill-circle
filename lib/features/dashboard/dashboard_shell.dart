import 'package:skill_circle_app/core/constants/app_colors.dart';
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
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      AppColors.darkSurface.withValues(alpha: 0.95),
                      AppColors.darkSurface2.withValues(alpha: 0.85),
                    ]
                  : [
                      AppColors.lightSurface.withValues(alpha: 0.95),
                      AppColors.lightSurface2.withValues(alpha: 0.85),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? AppColors.twitchPurple : AppColors.twitchPurpleLight).withValues(alpha: isDark ? 0.15 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
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
                              ? AppColors.twitchPurple.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          tab.icon,
                          color: isSelected
                              ? AppColors.twitchPurpleLight
                              : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                          size: 24,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        tab.label,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? AppColors.twitchPurpleLight
                              : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
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
    );
  }
}

class _ShellTab {
  const _ShellTab({required this.route, required this.label, required this.icon});

  final String route;
  final String label;
  final IconData icon;
}
