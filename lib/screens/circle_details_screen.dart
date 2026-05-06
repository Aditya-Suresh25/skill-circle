import 'package:flutter/material.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data Models
// ─────────────────────────────────────────────────────────────────────────────
class PostData {
  final String username;
  final String userAvatarName; // Used to generate initials/colors
  final String title;
  final String contentPreview;
  final int likes;
  final int comments;

  PostData({
    required this.username,
    required this.userAvatarName,
    required this.title,
    required this.contentPreview,
    required this.likes,
    required this.comments,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Sample Data
// ─────────────────────────────────────────────────────────────────────────────
final List<PostData> _samplePosts = [
  PostData(
    username: 'Sarah Jenkins',
    userAvatarName: 'Sarah',
    title: 'Best architecture for a new Flutter app in 2026?',
    contentPreview: 'I am starting a new scaleable project and wondering if Riverpod + Clean Architecture is still the way to go, or if there are newer patterns worth exploring...',
    likes: 124,
    comments: 32,
  ),
  PostData(
    username: 'Marcus Doe',
    userAvatarName: 'Marcus',
    title: 'Just published my first package on pub.dev! 🎉',
    contentPreview: 'It took a while, but I finally open-sourced the animated claymorphism buttons I built for my startup. Let me know what you think!',
    likes: 342,
    comments: 89,
  ),
  PostData(
    username: 'Elena R.',
    userAvatarName: 'Elena',
    title: 'How do you handle deep linking securely?',
    contentPreview: 'Running into some issues with Android App Links verifying properly. Does anyone have a good checklist or resource for debugging this?',
    likes: 45,
    comments: 12,
  ),
  PostData(
    username: 'Alex Chen',
    userAvatarName: 'Alex',
    title: 'State of WebAssembly in Flutter',
    contentPreview: 'Testing the latest Wasm compilation on the master channel and the performance bumps are incredible. Here are my benchmarks compared to standard JS compilation.',
    likes: 210,
    comments: 54,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Circle Details Screen
// ─────────────────────────────────────────────────────────────────────────────
class CircleDetailsScreen extends StatelessWidget {
  final String circleName;
  final String description;
  final int memberCount;
  final IconData circleIcon;

  const CircleDetailsScreen({
    super.key,
    this.circleName = 'Flutter Developers',
    this.description = 'A community for developers building beautiful native apps with Flutter. Share tips, packages, and architecture discussions.',
    this.memberCount = 24800,
    this.circleIcon = Icons.flutter_dash_rounded,
  });

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }

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
        title: Text(
          circleName,
          style: const TextStyle(
            fontSize: ClayTokens.textLG,
            fontWeight: FontWeight.w800,
            color: ClayTokens.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, color: ClayTokens.textPrimary),
            onPressed: () {},
          ),
        ],
      ),

      // ── Body ────────────────────────────────────────────────────────────
      body: Column(
        children: [
          // ── Top Section (Circle Info) ───────────────────────────────────
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(ClayTokens.spaceMD),
            padding: const EdgeInsets.all(ClayTokens.spaceLG),
            decoration: BoxDecoration(
              color: ClayTokens.surface,
              borderRadius: BorderRadius.circular(ClayTokens.radiusLG),
              boxShadow: ClayTokens.clayShadow,
            ),
            child: Column(
              children: [
                // Circle Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: ClayTokens.brandPale,
                    shape: BoxShape.circle,
                    boxShadow: ClayTokens.clayAvatar,
                  ),
                  child: Icon(circleIcon, size: 32, color: ClayTokens.brand),
                ),
                const SizedBox(height: ClayTokens.spaceMD),
                
                // Circle Name
                Text(
                  circleName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: ClayTokens.textXL,
                    fontWeight: FontWeight.w800,
                    color: ClayTokens.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: ClayTokens.spaceXS),
                
                // Member Count
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.people_alt_rounded, size: 14, color: ClayTokens.textHint),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatCount(memberCount)} members',
                      style: const TextStyle(
                        fontSize: ClayTokens.textSM,
                        fontWeight: FontWeight.w600,
                        color: ClayTokens.textHint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ClayTokens.spaceMD),

                // Description
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ClayTokens.textSM,
                    color: ClayTokens.textSecond.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // ── Main Section Header ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: ClayTokens.spaceLG, vertical: ClayTokens.spaceXS),
            child: Row(
              children: [
                const Text(
                  'Recent Posts',
                  style: TextStyle(
                    fontSize: ClayTokens.textLG,
                    fontWeight: FontWeight.w800,
                    color: ClayTokens.textPrimary,
                  ),
                ),
                const Spacer(),
                Icon(Icons.filter_list_rounded, size: 20, color: ClayTokens.textSecond.withValues(alpha: 0.7)),
              ],
            ),
          ),

          // ── Main Section (Posts List) ───────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(
                left: ClayTokens.spaceMD,
                right: ClayTokens.spaceMD,
                bottom: ClayTokens.spaceXL * 2, // Space for scrolling past the bottom
              ),
              itemCount: _samplePosts.length,
              itemBuilder: (context, index) {
                return PostCard(post: _samplePosts[index]);
              },
            ),
          ),
        ],
      ),
      
      // ── Floating Action Button ──────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: ClayTokens.brand,
        elevation: 4,
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable PostCard Widget
// ─────────────────────────────────────────────────────────────────────────────
class PostCard extends StatelessWidget {
  final PostData post;

  const PostCard({super.key, required this.post});

  /// Generates a consistent accent color based on username (dry helper)
  Color _accentFromName(String name) {
    const accents = [
      Color(0xFF7C3AED), Color(0xFF8B5CF6), Color(0xFF6D28D9),
      Color(0xFF9333EA), Color(0xFF7E22CE), Color(0xFFA855F7),
    ];
    final idx = name.codeUnits.fold(0, (a, b) => a + b) % accents.length;
    return accents[idx];
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentFromName(post.userAvatarName);
    final initials = post.userAvatarName.isNotEmpty 
        ? post.userAvatarName.substring(0, 1).toUpperCase() 
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: ClayTokens.spaceMD),
      padding: const EdgeInsets.all(16.0), // Required padding: 16
      decoration: BoxDecoration(
        color: ClayTokens.surface,
        borderRadius: BorderRadius.circular(ClayTokens.radiusMD), // Required: Rounded corners
        boxShadow: ClayTokens.clayShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Avatar & Username ──
          Row(
            children: [
              // User Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Username
              Text(
                post.username,
                style: const TextStyle(
                  fontSize: ClayTokens.textSM,
                  fontWeight: FontWeight.w700,
                  color: ClayTokens.textPrimary,
                ),
              ),
              const Spacer(),
              const Icon(Icons.more_vert_rounded, size: 18, color: ClayTokens.textHint),
            ],
          ),
          
          const SizedBox(height: 12), // Clean spacing
          
          // ── Title ──
          Text(
            post.title,
            style: const TextStyle(
              fontSize: ClayTokens.textBase,
              fontWeight: FontWeight.w800,
              color: ClayTokens.textPrimary,
              height: 1.2,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // ── Content Preview ──
          Text(
            post.contentPreview,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ClayTokens.textSM,
              color: ClayTokens.textSecond.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // ── Action Bar: Likes & Comments ──
          Row(
            children: [
              _PostActionButton(
                icon: Icons.favorite_border_rounded,
                count: post.likes,
                color: ClayTokens.error,
              ),
              const SizedBox(width: 24),
              _PostActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                count: post.comments,
                color: ClayTokens.textSecond,
              ),
              const Spacer(),
              const Icon(Icons.share_rounded, size: 18, color: ClayTokens.textHint),
            ],
          )
        ],
      ),
    );
  }
}

class _PostActionButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;

  const _PostActionButton({
    required this.icon,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color.withValues(alpha: 0.8)),
        const SizedBox(width: 6),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ClayTokens.textSecond.withValues(alpha: 0.9),
          ),
        ),
      ],
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
    home: const CircleDetailsScreen(),
  ));
}