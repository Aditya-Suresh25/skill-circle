import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skill_circle_app/core/constants/app_routes.dart';

class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key, required this.child});

  final Widget child;

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.circles);
        break;
      case 1:
        context.go(AppRoutes.posts);
        break;
      case 2:
        context.go(AppRoutes.profile);
        break;
    }
  }

  int _currentIndex(BuildContext context) {
    final uri = GoRouterState.of(context).uri.toString();
    if (uri.startsWith(AppRoutes.profile)) {
      return 2;
    }
    if (uri.startsWith(AppRoutes.posts)) {
      return 1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) => _onItemTapped(context, index),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore),
                label: 'Circles',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.dynamic_feed_outlined),
                activeIcon: Icon(Icons.dynamic_feed),
                label: 'Feed',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
