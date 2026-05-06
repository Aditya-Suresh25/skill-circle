import 'package:flutter/material.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Sample Data Models
// ─────────────────────────────────────────────────────────────────────────────
class StudentQuery {
  final String studentName;
  final String avatarInitial;
  final String queryText;
  final String timeAgo;

  StudentQuery({
    required this.studentName,
    required this.avatarInitial,
    required this.queryText,
    required this.timeAgo,
  });
}

class HighlightedPost {
  final String title;
  final String circleName;
  final int views;

  HighlightedPost({
    required this.title,
    required this.circleName,
    required this.views,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Sample Data
// ─────────────────────────────────────────────────────────────────────────────
final List<StudentQuery> _activeQueries = [
  StudentQuery(
    studentName: 'Rahul D.',
    avatarInitial: 'R',
    queryText: 'Can you review my final year project architecture? I am stuck on the database schema.',
    timeAgo: '15m ago',
  ),
  StudentQuery(
    studentName: 'Sneha P.',
    avatarInitial: 'S',
    queryText: 'Is it better to use Nuxt or vanilla Vue for an SEO-heavy application?',
    timeAgo: '1h ago',
  ),
];

final List<HighlightedPost> _importantPosts = [
  HighlightedPost(
    title: 'Top 10 Backend Patterns for 2026',
    circleName: 'Web Development',
    views: 1205,
  ),
  HighlightedPost(
    title: 'Understanding the event loop in Node.js',
    circleName: 'JavaScript Masters',
    views: 840,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Mentor Dashboard Screen
// ─────────────────────────────────────────────────────────────────────────────
class MentorDashboard extends StatelessWidget {
  const MentorDashboard({super.key});

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
          'Mentor Dashboard',
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
            // 1. Discussion Management Panel
            _buildSectionTitle('Management Panel', Icons.admin_panel_settings_rounded),
            const SizedBox(height: ClayTokens.spaceSM),
            _buildManagementPanel(),

            const SizedBox(height: ClayTokens.spaceXL),

            // 2. Student Queries List
            _buildSectionTitle('Pending Queries', Icons.help_outline_rounded),
            const SizedBox(height: ClayTokens.spaceSM),
            _buildQueriesSection(),

            const SizedBox(height: ClayTokens.spaceXL),

            // 3. Highlighted Important Posts
            _buildSectionTitle('Highlighted Posts', Icons.push_pin_rounded),
            const SizedBox(height: ClayTokens.spaceSM),
            _buildHighlightedPostsSection(),
            
            const SizedBox(height: ClayTokens.spaceXL),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Section Builders
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: ClayTokens.brandMid),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: ClayTokens.textLG,
            fontWeight: FontWeight.w800,
            color: ClayTokens.textPrimary,
          ),
        ),
      ],
    );
  }

  // ── Management Panel ──
  Widget _buildManagementPanel() {
    return Container(
      padding: const EdgeInsets.all(ClayTokens.spaceMD),
      decoration: BoxDecoration(
        color: ClayTokens.surface,
        borderRadius: BorderRadius.circular(ClayTokens.radiusLG),
        boxShadow: ClayTokens.clayShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ManagementCard(
                  title: 'Flagged',
                  count: '3',
                  icon: Icons.flag_rounded,
                  color: ClayTokens.error,
                ),
              ),
              const SizedBox(width: ClayTokens.spaceMD),
              Expanded(
                child: _ManagementCard(
                  title: 'Approvals',
                  count: '12',
                  icon: Icons.verified_user_rounded,
                  color: ClayTokens.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: ClayTokens.spaceMD),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: ClayTokens.brandPale,
              borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.forum_rounded, color: ClayTokens.brand, size: 18),
                SizedBox(width: 8),
                Text(
                  'Manage Active Discussions',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: ClayTokens.brandDeep,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ── Student Queries Section ──
  Widget _buildQueriesSection() {
    return Container(
      decoration: BoxDecoration(
        color: ClayTokens.surface,
        borderRadius: BorderRadius.circular(ClayTokens.radiusLG),
        boxShadow: ClayTokens.clayShadow,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(0),
        itemCount: _activeQueries.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: ClayTokens.pageBg),
        itemBuilder: (context, index) {
          final query = _activeQueries[index];
          return Padding(
            padding: const EdgeInsets.all(ClayTokens.spaceMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: ClayTokens.brandMid.withValues(alpha: 0.15),
                      child: Text(
                        query.avatarInitial,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: ClayTokens.brandDeep,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      query.studentName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: ClayTokens.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      query.timeAgo,
                      style: const TextStyle(
                        fontSize: 11,
                        color: ClayTokens.textHint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  query.queryText,
                  style: TextStyle(
                    fontSize: ClayTokens.textSM,
                    color: ClayTokens.textSecond.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Dismiss', style: TextStyle(color: ClayTokens.textHint)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ClayTokens.brandMid,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ClayTokens.radiusFull),
                        ),
                      ),
                      child: const Text('Reply'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Highlighted Posts Section ──
  Widget _buildHighlightedPostsSection() {
    return Container(
      decoration: BoxDecoration(
        color: ClayTokens.surface,
        borderRadius: BorderRadius.circular(ClayTokens.radiusLG),
        boxShadow: ClayTokens.clayShadow,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(0),
        itemCount: _importantPosts.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: ClayTokens.pageBg),
        itemBuilder: (context, index) {
          final post = _importantPosts[index];
          return ListTile(
            contentPadding: const EdgeInsets.all(ClayTokens.spaceMD),
            title: Text(
              post.title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: ClayTokens.textPrimary,
                fontSize: ClayTokens.textBase,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.hub_rounded, size: 14, color: ClayTokens.textHint),
                  const SizedBox(width: 4),
                  Text(
                    post.circleName,
                    style: const TextStyle(color: ClayTokens.textHint, fontSize: 12),
                  ),
                  const Spacer(),
                  const Icon(Icons.visibility_rounded, size: 14, color: ClayTokens.textHint),
                  const SizedBox(width: 4),
                  Text(
                    '${post.views}',
                    style: const TextStyle(color: ClayTokens.textHint, fontSize: 12),
                  ),
                ],
              ),
            ),
            trailing: const Icon(Icons.chevron_right_rounded, color: ClayTokens.textHint),
            onTap: () {},
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-components
// ─────────────────────────────────────────────────────────────────────────────

class _ManagementCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;

  const _ManagementCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ClayTokens.spaceSM),
      decoration: BoxDecoration(
        color: ClayTokens.pageBg,
        borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              Text(
                count,
                style: TextStyle(
                  fontSize: ClayTokens.textXL,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: ClayTokens.spaceSM),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: ClayTokens.textSecond,
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
    home: const MentorDashboard(),
  ));
}