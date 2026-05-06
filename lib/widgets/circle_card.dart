import 'package:flutter/material.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bento Clay Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ClayTokens.brand),
        useMaterial3: true,
      ),
      home: const BentoCircleDemoScreen(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HELPER: Avatar / Accent Generation
// ══════════════════════════════════════════════════════════════════════════════

Color _accentFromName(String name) {
  const accents = [
    Color(0xFF7C3AED),
    Color(0xFF8B5CF6),
    Color(0xFF6D28D9),
    Color(0xFF9333EA),
    Color(0xFF7E22CE),
    Color(0xFFA855F7),
  ];
  final idx = name.codeUnits.fold(0, (a, b) => a + b) % accents.length;
  return accents[idx];
}

class _CircleAvatar extends StatelessWidget {
  final String name;
  final double size;

  const _CircleAvatar({required this.name, this.size = 46});

  @override
  Widget build(BuildContext context) {
    final accent = _accentFromName(name);
    final initials = name.trim().isEmpty
        ? '?'
        : name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: 0.12),
        boxShadow: ClayTokens.clayAvatar,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.38,
            fontWeight: FontWeight.w800,
            color: accent,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

/// Reusable bento-style circle card used across screens.
class BentoCircleCard extends StatelessWidget {
  final String circleName;
  final int memberCount;
  final String tag;
  final bool joined;
  final VoidCallback? onJoin;

  const BentoCircleCard({
    super.key,
    required this.circleName,
    required this.memberCount,
    required this.tag,
    this.joined = false,
    this.onJoin,
  });

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentFromName(circleName);

    return Container(
      decoration: BoxDecoration(
        color: ClayTokens.surface,
        borderRadius: BorderRadius.circular(ClayTokens.radiusLG),
        boxShadow: ClayTokens.clayShadow,
      ),
      padding: const EdgeInsets.all(ClayTokens.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CircleAvatar(name: circleName, size: 42),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(ClayTokens.radiusFull),
                ),
                child: Text(
                  tag.toUpperCase(),
                  style: TextStyle(
                    fontSize: ClayTokens.textXS,
                    fontWeight: FontWeight.w700,
                    color: accent,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: ClayTokens.spaceSM),
          Text(
            circleName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: ClayTokens.textBase,
              fontWeight: FontWeight.w800,
              color: ClayTokens.textPrimary,
              height: 1.2,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(
                Icons.people_alt_rounded,
                size: 14,
                color: ClayTokens.textHint,
              ),
              const SizedBox(width: 4),
              Text(
                '${_formatCount(memberCount)} members',
                style: const TextStyle(
                  fontSize: ClayTokens.textXS,
                  color: ClayTokens.textHint,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: ClayTokens.spaceSM),
          SizedBox(
            height: 34,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onJoin,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: joined ? ClayTokens.brandPale : ClayTokens.brand,
                foregroundColor: joined ? ClayTokens.brandDeep : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ClayTokens.radiusFull),
                  side: joined
                      ? BorderSide(
                          color: ClayTokens.brandLight.withValues(alpha: 0.7),
                          width: 1.2,
                        )
                      : BorderSide.none,
                ),
              ),
              child: Text(
                joined ? 'Joined' : 'Join',
                style: const TextStyle(
                  fontSize: ClayTokens.textSM,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// COMPONENT: Hero Banner (Mimics "Scan now" top banner)
// ══════════════════════════════════════════════════════════════════════════════

class HeroBentoCard extends StatelessWidget {
  const HeroBentoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ClayTokens.spaceLG),
      decoration: BoxDecoration(
        color: ClayTokens.surface,
        borderRadius: BorderRadius.circular(ClayTokens.radiusXL),
        boxShadow: ClayTokens.clayShadow,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Join a circle to get full access to expert tips and live discussions powered by our community.',
                  style: TextStyle(
                    fontSize: ClayTokens.textSM,
                    color: ClayTokens.textSecond.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: ClayTokens.spaceMD),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ClayTokens.spaceMD,
                    vertical: ClayTokens.spaceSM,
                  ),
                  decoration: BoxDecoration(
                    color: ClayTokens.brandPale,
                    borderRadius: BorderRadius.circular(ClayTokens.radiusFull),
                    boxShadow: ClayTokens.clayAvatar,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Explore now',
                        style: TextStyle(
                          fontSize: ClayTokens.textSM,
                          fontWeight: FontWeight.w700,
                          color: ClayTokens.textPrimary,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 16, color: ClayTokens.textPrimary),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: ClayTokens.spaceMD),
          Expanded(
            flex: 2,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Abstract decoration replacing the image
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: ClayTokens.brandLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
                  ),
                ),
                const _CircleAvatar(name: 'Global Tech', size: 64),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// COMPONENT: Small Grid Box (Mimics 4-column categories)
// ══════════════════════════════════════════════════════════════════════════════

class CategoryBentoBox extends StatelessWidget {
  final String label;
  final IconData icon;

  const CategoryBentoBox({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ClayTokens.surface,
        borderRadius: BorderRadius.circular(ClayTokens.radiusLG),
        boxShadow: ClayTokens.clayShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 28,
            color: ClayTokens.brandMid,
          ),
          const SizedBox(height: ClayTokens.spaceSM),
          Text(
            label,
            style: const TextStyle(
              fontSize: ClayTokens.textXS,
              fontWeight: FontWeight.w700,
              color: ClayTokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// COMPONENT: Large Trending Card (Mimics "Bestsellers" bottom cards)
// ══════════════════════════════════════════════════════════════════════════════

class TrendingBentoCard extends StatelessWidget {
  final String title;
  final String tag;

  const TrendingBentoCard({super.key, required this.title, required this.tag});

  @override
  Widget build(BuildContext context) {
    final accent = _accentFromName(title);

    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: ClayTokens.spaceMD, bottom: ClayTokens.spaceMD),
      padding: const EdgeInsets.all(ClayTokens.spaceLG),
      decoration: BoxDecoration(
        color: ClayTokens.surface,
        borderRadius: BorderRadius.circular(ClayTokens.radiusXL),
        boxShadow: ClayTokens.clayShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ClayTokens.brand.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(ClayTokens.radiusFull),
                ),
                child: Text(
                  'NEW',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: ClayTokens.brandDeep,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: ClayTokens.spaceXS),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(ClayTokens.radiusFull),
                ),
                child: Text(
                  tag.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: accent,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Center(
            child: _CircleAvatar(name: title, size: 80),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: ClayTokens.textLG,
              fontWeight: FontWeight.w800,
              color: ClayTokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DEMO SCREEN: Assembling the complete Layout
// ══════════════════════════════════════════════════════════════════════════════

class BentoCircleDemoScreen extends StatelessWidget {
  const BentoCircleDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClayTokens.pageBg,
      body: Stack(
        children: [
          // Scrolling Body
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120), // Space for floating nav
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. App Bar Area
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      ClayTokens.spaceLG,
                      ClayTokens.spaceLG,
                      ClayTokens.spaceLG,
                      ClayTokens.spaceMD,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome to',
                              style: TextStyle(
                                fontSize: ClayTokens.textLG,
                                color: ClayTokens.textSecond,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'SKILL CIRCLES',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: ClayTokens.textPrimary,
                                letterSpacing: -1.0,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: ClayTokens.surface,
                            shape: BoxShape.circle,
                            boxShadow: ClayTokens.clayAvatar,
                          ),
                          child: const Icon(Icons.person_rounded, color: ClayTokens.brandMid),
                        ),
                      ],
                    ),
                  ),

                  // 2. Hero Banner
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: ClayTokens.spaceLG),
                    child: HeroBentoCard(),
                  ),
                  const SizedBox(height: ClayTokens.spaceXL),

                  // 3. Grid Categories (4 columns, 2 rows)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: ClayTokens.spaceLG),
                    child: GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: ClayTokens.spaceMD,
                      mainAxisSpacing: ClayTokens.spaceMD,
                      childAspectRatio: 0.85,
                      children: const [
                        CategoryBentoBox(label: 'Tech', icon: Icons.computer_rounded),
                        CategoryBentoBox(label: 'Design', icon: Icons.brush_rounded),
                        CategoryBentoBox(label: 'Business', icon: Icons.trending_up_rounded),
                        CategoryBentoBox(label: 'Code', icon: Icons.code_rounded),
                        CategoryBentoBox(label: 'AI', icon: Icons.smart_toy_rounded),
                        CategoryBentoBox(label: 'Music', icon: Icons.music_note_rounded),
                        CategoryBentoBox(label: 'Art', icon: Icons.palette_rounded),
                        CategoryBentoBox(label: 'Gaming', icon: Icons.sports_esports_rounded),
                      ],
                    ),
                  ),
                  const SizedBox(height: ClayTokens.spaceXL),

                  // 4. Section Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: ClayTokens.spaceLG),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Trending',
                          style: TextStyle(
                            fontSize: ClayTokens.textXL,
                            fontWeight: FontWeight.w800,
                            color: ClayTokens.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: ClayTokens.surface,
                            borderRadius: BorderRadius.circular(ClayTokens.radiusFull),
                            boxShadow: ClayTokens.clayShadow,
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'See all',
                                style: TextStyle(
                                  fontSize: ClayTokens.textXS,
                                  fontWeight: FontWeight.w700,
                                  color: ClayTokens.textPrimary,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_rounded, size: 14),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: ClayTokens.spaceMD),

                  // 5. Bottom Horizontal List
                  SizedBox(
                    height: 240,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: ClayTokens.spaceLG),
                      clipBehavior: Clip.none,
                      children: const [
                        TrendingBentoCard(title: 'Flutter Devs', tag: 'High demand'),
                        TrendingBentoCard(title: 'UI/UX Pro', tag: 'Design'),
                        TrendingBentoCard(title: 'Indie Hackers', tag: 'Startup'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 6. Floating Navigation Pill (Mimicking the image's bottom nav)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: ClayTokens.spaceXL),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: ClayTokens.spaceLG, vertical: 12),
                decoration: BoxDecoration(
                  color: ClayTokens.surface.withValues(alpha: 0.6), // Glassy clay feel
                  borderRadius: BorderRadius.circular(ClayTokens.radiusFull),
                  boxShadow: ClayTokens.clayShadow,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _NavIcon(icon: Icons.home_rounded, label: 'Home', isActive: true),
                    const SizedBox(width: ClayTokens.spaceXL),
                    _NavIcon(icon: Icons.grid_view_rounded, label: 'Explore'),
                    const SizedBox(width: ClayTokens.spaceXL),
                    _NavIcon(icon: Icons.shopping_bag_outlined, label: 'Saved'),
                    const SizedBox(width: ClayTokens.spaceXL),
                    _NavIcon(icon: Icons.search_rounded, label: 'Search'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _NavIcon({required this.icon, required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? ClayTokens.brand : ClayTokens.textHint,
          size: 24,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? ClayTokens.brand : ClayTokens.textHint,
          ),
        ),
      ],
    );
  }
}