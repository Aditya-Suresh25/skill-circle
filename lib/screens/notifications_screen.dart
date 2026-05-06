import 'package:flutter/material.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data Models
// ─────────────────────────────────────────────────────────────────────────────
enum NotificationType { comment, badge, update }

class NotificationData {
  final NotificationType type;
  final String message;
  final String timeAgo;
  final bool isUnread;

  NotificationData({
    required this.type,
    required this.message,
    required this.timeAgo,
    this.isUnread = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Sample Data
// ─────────────────────────────────────────────────────────────────────────────
final List<NotificationData> _sampleNotifications = [
  NotificationData(
    type: NotificationType.comment,
    message: 'Sarah Jenkins commented on your post "Best architecture for a new app?"',
    timeAgo: '2m',
    isUnread: true,
  ),
  NotificationData(
    type: NotificationType.badge,
    message: 'Congratulations! You earned the "Top Contributor" badge in Flutter Developers.',
    timeAgo: '1h',
    isUnread: true,
  ),
  NotificationData(
    type: NotificationType.update,
    message: 'UI/UX Design circle has pinned a new announcement.',
    timeAgo: '3h',
  ),
  NotificationData(
    type: NotificationType.comment,
    message: 'Marcus Doe replied to your comment: "Riverpod is definitely still..."',
    timeAgo: '1d',
  ),
  NotificationData(
    type: NotificationType.update,
    message: 'Web Development circle updated their weekly reading list.',
    timeAgo: '2d',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Notifications Screen
// ─────────────────────────────────────────────────────────────────────────────
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
          'Notifications',
          style: TextStyle(
            fontSize: ClayTokens.textLG,
            fontWeight: FontWeight.w800,
            color: ClayTokens.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, color: ClayTokens.brand),
            tooltip: 'Mark all as read',
            onPressed: () {},
          ),
        ],
      ),

      // ── Body ────────────────────────────────────────────────────────────
      body: ListView.separated(
        padding: const EdgeInsets.all(ClayTokens.spaceMD),
        itemCount: _sampleNotifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: ClayTokens.spaceMD),
        itemBuilder: (context, index) {
          final notif = _sampleNotifications[index];
          return _NotificationCard(notification: notif);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification Card Component
// ─────────────────────────────────────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final NotificationData notification;

  const _NotificationCard({required this.notification});

  // Maps notification type to specific styling
  Widget _buildIcon() {
    IconData iconData;
    Color iconColor;
    Color bgColor;

    switch (notification.type) {
      case NotificationType.comment:
        iconData = Icons.chat_bubble_rounded;
        iconColor = ClayTokens.brandMid;
        bgColor = ClayTokens.brandMid.withValues(alpha: 0.15);
        break;
      case NotificationType.badge:
        iconData = Icons.emoji_events_rounded;
        iconColor = const Color(0xFFF59E0B); // Golden amber for badge
        bgColor = const Color(0xFFF59E0B).withValues(alpha: 0.15);
        break;
      case NotificationType.update:
        iconData = Icons.campaign_rounded;
        iconColor = ClayTokens.success;
        bgColor = ClayTokens.success.withValues(alpha: 0.15);
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: ClayTokens.clayAvatar,
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Claymorphism style Card
    return Container(
      padding: const EdgeInsets.all(12.0), // Required: Padding 12
      decoration: BoxDecoration(
        color: notification.isUnread ? ClayTokens.surface : ClayTokens.pageBg,
        borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
        boxShadow: notification.isUnread ? ClayTokens.clayShadow : null,
        border: notification.isUnread 
            ? Border.all(color: ClayTokens.brandLight.withValues(alpha: 0.3), width: 1)
            : Border.all(color: Colors.transparent),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: _buildIcon(),
        title: Text(
          notification.message,
          style: TextStyle(
            fontSize: ClayTokens.textSM,
            fontWeight: notification.isUnread ? FontWeight.w700 : FontWeight.w500,
            color: ClayTokens.textPrimary,
            height: 1.3,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              notification.timeAgo,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: ClayTokens.textHint,
              ),
            ),
            if (notification.isUnread) ...[
              const SizedBox(height: 6),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: ClayTokens.brand,
                  shape: BoxShape.circle,
                ),
              ),
            ]
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
    home: const NotificationsScreen(),
  ));
}