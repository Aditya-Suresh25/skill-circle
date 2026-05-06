import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/constants/app_config.dart';
import 'package:skill_circle_app/core/services/app_router.dart';
import 'package:skill_circle_app/core/theme/app_theme.dart';
import 'package:skill_circle_app/features/notifications/presentation/widgets/notification_listener.dart';

class SkillCircleApp extends ConsumerWidget {
  const SkillCircleApp({super.key, required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return NotificationSetupWidget(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: config.showDebugBanner,
        title: config.appName,
        theme: SkillCircleTheme.light(),
        routerConfig: router,
      ),
    );
  }
}