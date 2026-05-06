import 'package:flutter/material.dart';
import 'package:skill_circle_app/utils/color_theme.dart';
import 'package:skill_circle_app/widgets/post_card.dart';
import 'package:skill_circle_app/widgets/circle_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Screen
// ─────────────────────────────────────────────────────────────────────────────
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClayTokens.pageBg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // ── Top Section: Welcome Header ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  ClayTokens.spaceLG,
                  ClayTokens.spaceLG,
                  ClayTokens.spaceLG,
                  ClayTokens.spaceMD,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Avatar
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: ClayTokens.brandPale,
                        shape: BoxShape.circle,
                        boxShadow: ClayTokens.clayAvatar,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Center(
                        child: Text(
                          'A', // Initials
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: ClayTokens.brand,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: ClayTokens.spaceMD),

                    // Welcome Message
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(
                              fontSize: ClayTokens.textSM,
                              fontWeight: FontWeight.w600,
                              color: ClayTokens.textHint,
                            ),
                          ),
                          Text(
                            'Akshay',
                            style: TextStyle(
                              fontSize: ClayTokens.textLG,
                              fontWeight: FontWeight.w800,
                              color: ClayTokens.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Notification Icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: ClayTokens.surface,
                        borderRadius: BorderRadius.circular(ClayTokens.radiusSM),
                        boxShadow: ClayTokens.clayShadow,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.notifications_none_rounded, color: ClayTokens.textPrimary, size: 22),
                          Positioned(
                            top: 10,
                            right: 12,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: ClayTokens.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 1. Trending Posts (Horizontal Scroll) ────────────────────────
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: ClayTokens.spaceLG, vertical: ClayTokens.spaceSM),
                    child: Text(
                      'Trending Discussions',
                      style: TextStyle(
                        fontSize: ClayTokens.textLG,
                        fontWeight: FontWeight.w800,
                        color: ClayTokens.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 200, // Fixed height for horizontal list
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: ClayTokens.spaceLG, vertical: ClayTokens.spaceXS),
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none, // Allows clay shadows to render properly
                      itemCount: 3,
                      separatorBuilder: (context, index) => const SizedBox(width: ClayTokens.spaceMD),
                      itemBuilder: (context, index) {
                        return const SizedBox(
                          width: 300, // Fixed width for horizontal cards
                          child: PostCard(
                            username: 'Sarah Jenkins',
                            title: 'Is Clean Architecture overkill for startups?',
                            contentPreview: 'I see a lot of debate about this. What are the best pragmatic approaches for MVPs?',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: ClayTokens.spaceMD)),

            // ── 2. Recommended Circles (Horizontal Scroll) ───────────────────
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: ClayTokens.spaceLG, vertical: ClayTokens.spaceSM),
                    child: Text(
                      'Recommended For You',
                      style: TextStyle(
                        fontSize: ClayTokens.textLG,
                        fontWeight: FontWeight.w800,
                        color: ClayTokens.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 190,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: ClayTokens.spaceLG, vertical: ClayTokens.spaceXS),
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      itemCount: 4,
                      separatorBuilder: (context, index) => const SizedBox(width: ClayTokens.spaceMD),
                      itemBuilder: (context, index) {
                        final circles = ['UI/UX Design', 'Indie Hackers', 'Open Source', 'Flutter Devs'];
                        return SizedBox(
                          width: 160,
                          child: BentoCircleCard(
                            circleName: circles[index],
                            memberCount: 1200 * (index + 1),
                            tag: 'Suggested',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: ClayTokens.spaceMD)),

            // ── 3. Recent Posts Header ────────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: ClayTokens.spaceLG, vertical: ClayTokens.spaceSM),
                child: Text(
                  'Recent Posts',
                  style: TextStyle(
                    fontSize: ClayTokens.textLG,
                    fontWeight: FontWeight.w800,
                    color: ClayTokens.textPrimary,
                  ),
                ),
              ),
            ),

            // ── 3. Recent Posts List (Vertical Scroll) ────────────────────────
            SliverPadding(
              padding: const EdgeInsets.only(
                left: ClayTokens.spaceLG,
                right: ClayTokens.spaceLG,
                bottom: ClayTokens.spaceXL * 3, // Extra padding for bottom nav bar
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return const PostCard(
                      username: 'Marcus Doe',
                      title: 'Just published my first package! 🎉',
                      contentPreview: 'It took a while, but I finally open-sourced the animated claymorphism buttons I built.',
                    );
                  },
                  childCount: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: const DashboardScreen(),
  ));
}