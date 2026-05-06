import 'package:flutter/material.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

class NotificationTile extends StatelessWidget {
  final IconData icon;
  final String message;
  final String timestamp;

  const NotificationTile({
    super.key,
    required this.icon,
    required this.message,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: ClayTokens.surface,
      margin: const EdgeInsets.only(bottom: ClayTokens.spaceSM),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
          boxShadow: ClayTokens.clayShadow, // Maintains the soft 3D theme
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Required: Padding 12
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Left: Notification Icon ─────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: ClayTokens.brandPale,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: ClayTokens.brandMid,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 12), // Required: Clean spacing
              
              // ── Middle: Notification Message ────────────────────────────────
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: ClayTokens.textSM,
                    fontWeight: FontWeight.w600,
                    color: ClayTokens.textPrimary,
                    height: 1.3,
                  ),
                ),
              ),
              
              const SizedBox(width: 12), // Required: Clean spacing
              
              // ── Right: Timestamp ────────────────────────────────────────────
              Text(
                timestamp,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: ClayTokens.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}