import 'package:flutter/material.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Settings Screen
// ─────────────────────────────────────────────────────────────────────────────
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClayTokens.pageBg,

      // ── AppBar ──────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: ClayTokens.pageBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ClayTokens.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: ClayTokens.textLG,
            fontWeight: FontWeight.w800,
            color: ClayTokens.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ),

      // ── Body ────────────────────────────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ClayTokens.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: ClayTokens.spaceSM),
            
            // Settings Group
            Container(
              decoration: BoxDecoration(
                color: ClayTokens.surface,
                borderRadius: BorderRadius.circular(ClayTokens.radiusLG),
                boxShadow: ClayTokens.clayShadow,
              ),
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Edit Profile',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  
                  _SettingsTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Change Password',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  
                  _SettingsTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notification Settings',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  
                  _SettingsTile(
                    icon: Icons.shield_outlined,
                    title: 'Privacy Settings',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: ClayTokens.spaceLG),
            
            // Destructive Action Group
            Container(
              decoration: BoxDecoration(
                color: ClayTokens.surface,
                borderRadius: BorderRadius.circular(ClayTokens.radiusLG),
                boxShadow: ClayTokens.clayShadow,
              ),
              child: _SettingsTile(
                icon: Icons.logout_rounded,
                title: 'Logout',
                isDestructive: true,
                onTap: () {
                  // TODO: Add logout logic
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Helper Methods
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      color: ClayTokens.pageBg,
      indent: 56, // Aligns with the text, skipping the icon
      endIndent: 16,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Settings Tile Component
// ─────────────────────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDestructive;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Styling logic based on whether the action is destructive (like Logout)
    final textColor = isDestructive ? ClayTokens.error : ClayTokens.textPrimary;
    final iconBgColor = isDestructive 
        ? ClayTokens.error.withValues(alpha: 0.1) 
        : ClayTokens.brandPale;
    final iconColor = isDestructive ? ClayTokens.error : ClayTokens.brandMid;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ClayTokens.radiusLG),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(ClayTokens.radiusSM),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: ClayTokens.spaceMD),
            
            // Title text
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: ClayTokens.textBase,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            
            // Trailing arrow (hidden for destructive actions)
            Icon(
              Icons.chevron_right_rounded,
              color: isDestructive ? Colors.transparent : ClayTokens.textHint,
            ),
          ],
        ),
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
    home: const SettingsScreen(),
  ));
}