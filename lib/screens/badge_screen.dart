import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/services/app_router.dart';
import 'package:skill_circle_app/features/profile/presentation/providers/profile_providers.dart';
import 'package:skill_circle_app/models/badge_model.dart' as shared_models;
import 'package:skill_circle_app/utils/color_theme.dart';

class BadgeScreen extends ConsumerWidget {
  const BadgeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authStateProvider).valueOrNull;
    final badgesAsync = authUser == null
        ? const AsyncValue<List<shared_models.BadgeModel>>.data(<shared_models.BadgeModel>[])
        : ref.watch(userBadgesProvider(authUser.id));

    return Scaffold(
      backgroundColor: ClayTokens.pageBg,
      appBar: AppBar(
        backgroundColor: ClayTokens.pageBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ClayTokens.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
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
      body: Padding(
        padding: const EdgeInsets.all(ClayTokens.spaceLG),
        child: authUser == null
            ? const Center(child: Text('Sign in to see your badges.'))
            : badgesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Text('Failed to load badges: $error', textAlign: TextAlign.center),
                ),
                data: (badges) {
                  if (badges.isEmpty) {
                    return const Center(child: Text('No badges yet. Start participating to unlock them.'));
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Earn badges by participating in circles and helping others.',
                        style: TextStyle(
                          fontSize: ClayTokens.textSM,
                          color: ClayTokens.textSecond.withValues(alpha: 0.85),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: ClayTokens.spaceMD),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.only(bottom: ClayTokens.spaceXL * 2),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: ClayTokens.spaceMD,
                            mainAxisSpacing: ClayTokens.spaceMD,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: badges.length,
                          itemBuilder: (context, index) => _BadgeCard(badge: badges[index]),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge});

  final shared_models.BadgeModel badge;

  @override
  Widget build(BuildContext context) {
    const Color highlightColor = Color(0xFFF59E0B);
    const Color highlightPale = Color(0xFFFEF3C7);
    final bool isAchieved = !badge.isLocked && (badge.progress == null || badge.progress! >= 1.0);

    return Container(
      padding: const EdgeInsets.all(ClayTokens.spaceMD),
      decoration: BoxDecoration(
        color: ClayTokens.surface,
        borderRadius: BorderRadius.circular(ClayTokens.radiusLG),
        boxShadow: isAchieved
            ? [
                BoxShadow(
                  color: highlightColor.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
                ...ClayTokens.clayShadow,
              ]
            : ClayTokens.clayShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: badge.isLocked ? ClayTokens.pageBg : highlightPale,
              shape: BoxShape.circle,
              boxShadow: badge.isLocked ? null : ClayTokens.clayAvatar,
            ),
            child: Icon(
              _iconForKey(badge.iconKey),
              size: 28,
              color: badge.isLocked ? ClayTokens.textHint : highlightColor,
            ),
          ),
          const SizedBox(height: ClayTokens.spaceMD),
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
                    ),
                  ],
          ),
        ),
      ),
    );
  }

  IconData _iconForKey(String key) {
    switch (key) {
      case 'comment':
        return Icons.rate_review_rounded;
      case 'circle':
        return Icons.hub_rounded;
      case 'group':
        return Icons.groups_rounded;
      case 'trophy':
        return Icons.workspace_premium_rounded;
      case 'profile':
        return Icons.person_rounded;
      case 'post':
      default:
        return Icons.edit_document;
    }
  }
}

void main() {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BadgeScreen(),
      ),
    ),
  );
}
