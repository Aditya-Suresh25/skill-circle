import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/constants/app_config.dart';
import 'package:skill_circle_app/core/presentation/widgets/aurora_background.dart';
import 'package:skill_circle_app/core/services/app_router.dart';
import 'package:skill_circle_app/core/theme/app_theme.dart';
import 'package:skill_circle_app/features/notifications/presentation/widgets/notification_listener.dart';
import 'package:skill_circle_app/features/chat/presentation/providers/chat_providers.dart';

class SkillCircleApp extends ConsumerStatefulWidget {
  const SkillCircleApp({super.key, required this.config});

  final AppConfig config;

  @override
  ConsumerState<SkillCircleApp> createState() => _SkillCircleAppState();
}

class _SkillCircleAppState extends ConsumerState<SkillCircleApp> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onStateChange: _onStateChanged,
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  void _onStateChanged(AppLifecycleState state) {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final repo = ref.read(chatRepositoryProvider);
    if (state == AppLifecycleState.resumed) {
      repo.updateUserStatus(user.id, 'online');
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      repo.updateUserStatus(user.id, 'offline');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return NotificationSetupWidget(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: widget.config.showDebugBanner,
        title: widget.config.appName,
        theme: SkillCircleTheme.light(),
        builder: (context, child) {
          return AuroraBackground(
            child: child ?? const SizedBox.shrink(),
          );
        },
        routerConfig: router,
      ),
    );
  }
}