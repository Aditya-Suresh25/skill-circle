import 'package:flutter/material.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data Models
// ─────────────────────────────────────────────────────────────────────────────
class BadgeData {
  final String title;
  final IconData icon;
  final String description;
  final double? progress; // 0.0 to 1.0. Null means fully achieved without a progress bar.
  final bool isLocked;

  BadgeData({
    required this.title,
    required this.icon,
    required this.description,
    this.progress,
    this.isLocked = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Sample Data
// ─────────────────────────────────────────────────────────────────────────────
final List<BadgeData> _sampleBadges = [
  BadgeData(
    title: 'First Post',
    icon: Icons.edit_document,
    description: 'Published your first post',
    progress: 1.0,
    isLocked: false,
  ),
  BadgeData(
    title: 'Active Member',
    icon: Icons.local_fire_department_rounded,
    description: 'Log in for 7 consecutive days',
    progress: 0.8,
    isLocked: false,
  ),
  BadgeData(
    title: 'Top Contributor',
    icon: Icons.workspace_premium_rounded,
    description: 'Reach 1,000 upvotes',
    progress: 0.35,
    isLocked: false,
  ),
  BadgeData(
    title: 'Helpful Reviewer',
    icon: Icons.rate_review_rounded,
    description: 'Comment on 50 posts',
    progress: 0.1,
    isLocked: true,
  ),
  BadgeData(
    title: 'Circle Founder',
    icon: Icons.hub_rounded,
    description: 'Create a new circle',
    progress: 0.0,
    isLocked: true,
  ),
  BadgeData(
    title: 'Event Host',
    icon: Icons.event_available_rounded,
    description: 'Host your first live event',
    progress: null, // Null hides the progress bar entirely
    isLocked: true,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Badge Screen
// ─────────────────────────────────────────────────────────────────────────────
class BadgeScreen extends StatelessWidget {
  const BadgeScreen({super.key});

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
          'My Badges',
          style: TextStyle(
            fontSize: ClayTokens.textLG,
            fontWeight: FontWeight.w800,
            color: ClayTokens.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ),

      // ── Body ────────────────────────────────────────────────────────────
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Screen Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: ClayTokens.spaceLG, vertical: ClayTokens.spaceSM),
            child: Text(
              'Earn badges by participating in circles and helping others.',
              style: TextStyle(
                fontSize: ClayTokens.textSM,
                color: ClayTokens.textSecond.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
          ),
          
          const SizedBox(height: ClayTokens.spaceSM),

          // Badge Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(
                ClayTokens.spaceLG, 
                ClayTokens.spaceXS, 
                ClayTokens.spaceLG, 
                ClayTokens.spaceXL * 2
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: ClayTokens.spaceMD,
                mainAxisSpacing: ClayTokens.spaceMD,
                childAspectRatio: 0.85, // Adjusts height of the card
              ),
              itemCount: _sampleBadges.length,
              itemBuilder: (context, index) {
                return _BadgeCard(badge: _sampleBadges[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Badge Card Component
// ─────────────────────────────────────────────────────────────────────────────
class _BadgeCard extends StatelessWidget {
  final BadgeData badge;

  const _BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    // Yellow accent palette for achieved badges
    const Color highlightColor = Color(0xFFF59E0B); // Amber/Yellow
    const Color highlightPale = Color(0xFFFEF3C7);
    
    final bool isAchieved = !badge.isLocked && (badge.progress == null || badge.progress! >= 1.0);

    return Container(
      padding: const EdgeInsets.all(ClayTokens.spaceMD),
      decoration: BoxDecoration(
        color: ClayTokens.surface,
        borderRadius: BorderRadius.circular(ClayTokens.radiusLG),
        // Add a subtle glowing yellow shadow if fully achieved, otherwise standard clay
        boxShadow: isAchieved 
            ? [
                BoxShadow(
                  color: highlightColor.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
                ...ClayTokens.clayShadow
              ]
            : ClayTokens.clayShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Badge Icon ──
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: badge.isLocked ? ClayTokens.pageBg : highlightPale,
              shape: BoxShape.circle,
              boxShadow: badge.isLocked ? null : ClayTokens.clayAvatar,
            ),
            child: Icon(
              badge.icon,
              size: 28,
              color: badge.isLocked ? ClayTokens.textHint : highlightColor,
            ),
          ),
          
          const SizedBox(height: ClayTokens.spaceMD),
          
          // ── Title ──
          Text(
            badge.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ClayTokens.textSM,
              fontWeight: FontWeight.w800,
              color: badge.isLocked ? ClayTokens.textHint : ClayTokens.textPrimary,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // ── Description ──
          Expanded(
            child: Text(
              badge.description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: ClayTokens.textSecond.withValues(alpha: badge.isLocked ? 0.5 : 0.8),
                height: 1.2,
              ),
            ),
          ),
          
          // ── Progress Indicator (Optional) ──
          if (badge.progress != null) ...[
            const SizedBox(height: ClayTokens.spaceSM),
            _buildProgressBar(
              progress: badge.progress!, 
              isLocked: badge.isLocked,
              highlightColor: highlightColor,
            ),
          ],
        ],
      ),
    );
  }

  // Custom rounded progress bar
  Widget _buildProgressBar({
    required double progress, 
    required bool isLocked, 
    required Color highlightColor,
  }) {
    return Container(
      height: 6,
      width: double.infinity,
      decoration: BoxDecoration(
        color: ClayTokens.pageBg,
        borderRadius: BorderRadius.circular(ClayTokens.radiusFull),
        // Inset shadow effect for the empty track
        boxShadow: [
          BoxShadow(
            color: ClayTokens.brandLight.withValues(alpha: 0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
            spreadRadius: -1,
          ),
        ],
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: isLocked ? ClayTokens.textHint : highlightColor,
            borderRadius: BorderRadius.circular(ClayTokens.radiusFull),
            boxShadow: isLocked 
                ? null 
                : [
                    BoxShadow(
                      color: highlightColor.withValues(alpha: 0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
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
    home: const BadgeScreen(),
  ));
}