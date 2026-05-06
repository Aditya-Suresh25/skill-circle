import 'package:flutter/material.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data Model
// ─────────────────────────────────────────────────────────────────────────────
class AdminControl {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final int notificationCount;

  AdminControl({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.notificationCount = 0,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Sample Data
// ─────────────────────────────────────────────────────────────────────────────
final List<AdminControl> _adminControls = [
  AdminControl(
    title: 'Manage Users',
    subtitle: 'Roles, bans & invites',
    icon: Icons.people_alt_rounded,
    iconColor: ClayTokens.brandMid,
    notificationCount: 3,
  ),
  AdminControl(
    title: 'Manage Circles',
    subtitle: 'Categories & settings',
    icon: Icons.hub_rounded,
    iconColor: ClayTokens.brand,
  ),
  AdminControl(
    title: 'Moderate Posts',
    subtitle: 'Flagged content review',
    icon: Icons.admin_panel_settings_rounded,
    iconColor: ClayTokens.error,
    notificationCount: 12,
  ),
  AdminControl(
    title: 'View Reports',
    subtitle: 'System analytics',
    icon: Icons.analytics_rounded,
    iconColor: ClayTokens.success,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Admin Dashboard Screen
// ─────────────────────────────────────────────────────────────────────────────
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

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
          'Admin Dashboard',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top System Status ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(ClayTokens.spaceLG),
              child: Container(
                padding: const EdgeInsets.all(ClayTokens.spaceMD),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [ClayTokens.textPrimary, ClayTokens.textSecond],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(ClayTokens.radiusLG),
                  boxShadow: ClayTokens.clayShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.security_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: ClayTokens.spaceMD),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'System Status: Healthy',
                            style: TextStyle(
                              fontSize: ClayTokens.textBase,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'All services are running normally.',
                            style: TextStyle(
                              fontSize: ClayTokens.textSM,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Section Header ────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: ClayTokens.spaceLG),
              child: Text(
                'Quick Controls',
                style: TextStyle(
                  fontSize: ClayTokens.textLG,
                  fontWeight: FontWeight.w800,
                  color: ClayTokens.textPrimary,
                ),
              ),
            ),
            
            const SizedBox(height: ClayTokens.spaceSM),

            // ── Admin Controls Grid ───────────────────────────────────────
            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: ClayTokens.spaceLG, vertical: ClayTokens.spaceSM),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: ClayTokens.spaceMD,
                mainAxisSpacing: ClayTokens.spaceMD,
                childAspectRatio: 0.9, // Gives the cards a slightly taller, square proportion
              ),
              itemCount: _adminControls.length,
              itemBuilder: (context, index) {
                return _AdminControlCard(control: _adminControls[index]);
              },
            ),
            
            const SizedBox(height: ClayTokens.spaceXL * 2), // Bottom spacing
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Admin Control Card Component
// ─────────────────────────────────────────────────────────────────────────────
class _AdminControlCard extends StatelessWidget {
  final AdminControl control;

  const _AdminControlCard({required this.control});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to specific admin section
      },
      child: Container(
        padding: const EdgeInsets.all(ClayTokens.spaceMD),
        decoration: BoxDecoration(
          color: ClayTokens.surface,
          borderRadius: BorderRadius.circular(ClayTokens.radiusLG),
          boxShadow: ClayTokens.clayShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon & Notification Badge Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: control.iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(control.icon, color: control.iconColor, size: 26),
                ),
                if (control.notificationCount > 0)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: ClayTokens.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${control.notificationCount}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            
            const Spacer(),
            
            // Text Content
            Text(
              control.title,
              style: const TextStyle(
                fontSize: ClayTokens.textBase,
                fontWeight: FontWeight.w800,
                color: ClayTokens.textPrimary,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              control.subtitle,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: ClayTokens.textHint.withValues(alpha: 0.9),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
    home: const AdminDashboard(),
  ));
}