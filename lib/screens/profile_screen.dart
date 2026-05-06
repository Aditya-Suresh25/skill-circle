import 'package:flutter/material.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Profile Screen
// ─────────────────────────────────────────────────────────────────────────────
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
          'Profile',
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
        padding: const EdgeInsets.all(ClayTokens.spaceMD), // Required: Padding 16
        child: Column(
          children: [
            const SizedBox(height: ClayTokens.spaceSM),

            // ── Top Section: Avatar, Name & Role ──────────────────────────
            _buildTopProfileSection(),

            const SizedBox(height: ClayTokens.spaceXL),

            // ── Stats Section ─────────────────────────────────────────────
            _buildStatsSection(),

            const SizedBox(height: ClayTokens.spaceXL),

            // ── Options Section ───────────────────────────────────────────
            _buildOptionsSection(),

            const SizedBox(height: ClayTokens.spaceXL),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Component Builders
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildTopProfileSection() {
    return Column(
      children: [
        // Profile Avatar
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: ClayTokens.brandPale,
            shape: BoxShape.circle,
            boxShadow: ClayTokens.clayAvatar,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: const Center(
            child: Text(
              'A',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: ClayTokens.brand,
              ),
            ),
          ),
        ),
        const SizedBox(height: ClayTokens.spaceMD),

        // Username
        const Text(
          'Akshay',
          style: TextStyle(
            fontSize: ClayTokens.textXL,
            fontWeight: FontWeight.w800,
            color: ClayTokens.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: ClayTokens.spaceXS),

        // Role Label (Student)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: ClayTokens.brand.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(ClayTokens.radiusFull),
            border: Border.all(color: ClayTokens.brand.withValues(alpha: 0.2)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school_rounded, size: 16, color: ClayTokens.brand),
              SizedBox(width: 6),
              Text(
                'Student',
                style: TextStyle(
                  fontSize: ClayTokens.textSM,
                  fontWeight: FontWeight.w700,
                  color: ClayTokens.brandDeep,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(child: _StatCard(label: 'Posts', value: '12')),
        const SizedBox(width: ClayTokens.spaceMD),
        Expanded(child: _StatCard(label: 'Circles', value: '5')),
        const SizedBox(width: ClayTokens.spaceMD),
        Expanded(child: _StatCard(label: 'Badges', value: '3')),
      ],
    );
  }

  Widget _buildOptionsSection() {
    return Container(
      decoration: BoxDecoration(
        color: ClayTokens.surface,
        borderRadius: BorderRadius.circular(ClayTokens.radiusLG),
        boxShadow: ClayTokens.clayShadow,
      ),
      child: Column(
        children: [
          _OptionTile(
            icon: Icons.person_outline_rounded,
            title: 'Edit Profile',
            onTap: () {},
          ),
          Divider(height: 1, color: ClayTokens.pageBg, indent: 56, endIndent: 16),
          _OptionTile(
            icon: Icons.workspace_premium_outlined,
            title: 'View Badges',
            onTap: () {},
          ),
          Divider(height: 1, color: ClayTokens.pageBg, indent: 56, endIndent: 16),
          _OptionTile(
            icon: Icons.logout_rounded,
            title: 'Logout',
            isDestructive: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-components
// ─────────────────────────────────────────────────────────────────────────────

/// Custom claymorphism card for displaying profile statistics
class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: ClayTokens.spaceMD),
      decoration: BoxDecoration(
        color: ClayTokens.surface,
        borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
        boxShadow: ClayTokens.clayShadow,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: ClayTokens.textXL,
              fontWeight: FontWeight.w800,
              color: ClayTokens.brandDeep,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: ClayTokens.textXS,
              fontWeight: FontWeight.w600,
              color: ClayTokens.textHint,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom ListTile for the options menu
class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDestructive;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? ClayTokens.error : ClayTokens.textPrimary;
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
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: ClayTokens.textBase,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
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
    home: const ProfileScreen(),
  ));
}