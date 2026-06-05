import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/constants/app_config.dart';
import 'package:skill_circle_app/core/router.dart';
import 'package:skill_circle_app/core/theme.dart';
import 'package:skill_circle_app/core/widgets/glass.dart';

class SkillCircleApp extends ConsumerStatefulWidget {
  const SkillCircleApp({super.key, required this.config});

  final AppConfig config;

  @override
  ConsumerState<SkillCircleApp> createState() => _SkillCircleAppState();
}

class _SkillCircleAppState extends ConsumerState<SkillCircleApp> {
  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: widget.config.showDebugBanner,
      title: widget.config.appName,
      theme: SkillCircleTheme.light(),
      darkTheme: SkillCircleTheme.dark(),
      themeMode: themeMode,
      builder: (context, child) {
        return AuroraBackground(
          child: child ?? const SizedBox.shrink(),
        );
      },
      routerConfig: router,
    );
  }
}
