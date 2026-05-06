import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// IMPORT YOUR SCREENS HERE
// Uncomment these when adding to your actual project structure
// ─────────────────────────────────────────────────────────────────────────────
// import 'package:skill_circle_app/screens/dashboard_screen.dart';
// import 'package:skill_circle_app/screens/circles_screen.dart';
// import 'package:skill_circle_app/screens/create_post_screen.dart';
// import 'package:skill_circle_app/screens/notifications_screen.dart';
// import 'package:skill_circle_app/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of screens to display in the IndexedStack
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Replace these placeholder widgets with your actual imported screen widgets
    _screens = [
      const _PlaceholderScreen(title: 'Dashboard Screen', icon: Icons.grid_view_rounded),
      const _PlaceholderScreen(title: 'Circles Screen', icon: Icons.hub_rounded),
      const _PlaceholderScreen(title: 'Create Post Screen', icon: Icons.add_circle_outline_rounded),
      const _PlaceholderScreen(title: 'Notifications Screen', icon: Icons.notifications_none_rounded),
      const _PlaceholderScreen(title: 'Profile Screen', icon: Icons.person_outline_rounded),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClayTokens.pageBg,
      // extendBody is REQUIRED so the screen content scrolls behind the transparent floating nav bar
      extendBody: true, 
      
      // IndexedStack preserves the state/scroll position of each screen when switching
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      // ── Floating Glassy Navigation Pill (Reference Image Style) ─────────
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(
            bottom: ClayTokens.spaceXL,
            left: ClayTokens.spaceLG,
            right: ClayTokens.spaceLG,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ClayTokens.radiusFull),
            // Outer clay shadow anchors the floating pill
            boxShadow: ClayTokens.clayShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ClayTokens.radiusFull),
            child: BackdropFilter(
              // Glass blur effect
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ClayTokens.spaceSM, 
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: ClayTokens.surface.withValues(alpha: 0.65),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(Icons.grid_view_rounded, 'Home', 0),
                    _buildNavItem(Icons.hub_rounded, 'Circles', 1),
                    _buildCreatePostItem(2), // Distinct center button
                    _buildNavItem(Icons.notifications_none_rounded, 'Alerts', 3),
                    _buildNavItem(Icons.person_outline_rounded, 'Profile', 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Navigation Item Builders
  // ───────────────────────────────────────────────────────────────────────────

  /// Standard navigation icon builder
  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              child: Icon(
                icon,
                key: ValueKey<bool>(isSelected),
                color: isSelected ? ClayTokens.brand : ClayTokens.textHint,
                size: isSelected ? 26 : 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? ClayTokens.brand : ClayTokens.textHint,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Prominent center button for "Create Post"
  Widget _buildCreatePostItem(int index) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ClayTokens.brandMid, ClayTokens.brand],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: isSelected ? ClayTokens.clayButton : ClayTokens.clayAvatar,
          border: isSelected 
              ? Border.all(color: ClayTokens.brandPale, width: 2)
              : null,
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dummy Placeholder Screen (Delete this once you link your real screens)
// ─────────────────────────────────────────────────────────────────────────────
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: ClayTokens.brand.withValues(alpha: 0.2)),
          const SizedBox(height: ClayTokens.spaceMD),
          Text(
            title,
            style: const TextStyle(
              fontSize: ClayTokens.textXL,
              fontWeight: FontWeight.w800,
              color: ClayTokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Standalone Testing Entry Point
// ─────────────────────────────────────────────────────────────────────────────
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: const HomeScreen(),
  ));
}