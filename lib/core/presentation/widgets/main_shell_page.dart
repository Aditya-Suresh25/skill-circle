import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skill_circle_app/core/constants/app_routes.dart';
import 'package:skill_circle_app/core/theme/theme_mode_provider.dart';

class MainShellPage extends ConsumerWidget {
  const MainShellPage({super.key, required this.child});

  final Widget child;

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.circles);
        break;
      case 1:
        context.go(AppRoutes.posts);
        break;
      case 2:
        context.go(AppRoutes.profile);
        break;
    }
  }

  int _currentIndex(BuildContext context) {
    final uri = GoRouterState.of(context).uri.toString();
    if (uri.startsWith(AppRoutes.profile)) {
      return 2;
    }
    if (uri.startsWith(AppRoutes.posts)) {
      return 1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _currentIndex(context);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.82),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? const Color(0xFF8B5CF6) : const Color(0xFF6D28D9)).withValues(alpha: 0.20),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(child: _NavItem(index: 0, currentIndex: currentIndex, icon: Icons.explore_outlined, activeIcon: Icons.explore, label: 'Circles', onTap: () => _onItemTapped(context, 0), isDark: isDark)),
                Expanded(child: _NavItem(index: 1, currentIndex: currentIndex, icon: Icons.dynamic_feed_outlined, activeIcon: Icons.dynamic_feed, label: 'Feed', onTap: () => _onItemTapped(context, 1), isDark: isDark)),
                Expanded(child: _NavItem(index: 2, currentIndex: currentIndex, icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile', onTap: () => _onItemTapped(context, 2), isDark: isDark)),
                IconButton(
                  tooltip: 'Toggle theme',
                  onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
                  icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                  color: isDark ? Colors.white : const Color(0xFF2E1D56),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final selected = index == currentIndex;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: selected
              ? LinearGradient(
                  colors: [
                    const Color(0xFFC084FC).withValues(alpha: isDark ? 0.34 : 0.24),
                    const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.26 : 0.16),
                  ],
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? activeIcon : icon, color: selected ? const Color(0xFFC084FC) : (isDark ? Colors.white70 : const Color(0xFF7A7094))),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? (isDark ? Colors.white : const Color(0xFF2E1D56)) : (isDark ? Colors.white70 : const Color(0xFF7A7094)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
