import 'package:flutter/material.dart';
import 'package:skill_circle_app/screens/admin_dashboard.dart';
import 'package:skill_circle_app/screens/badge_screen.dart';
import 'package:skill_circle_app/screens/circle_details_screen.dart';
import 'package:skill_circle_app/screens/circles_screen.dart';
import 'package:skill_circle_app/screens/create_post_screen.dart';
import 'package:skill_circle_app/screens/dashboard_screen.dart';
import 'package:skill_circle_app/screens/home_screen.dart';
import 'package:skill_circle_app/screens/login_screen.dart';
import 'package:skill_circle_app/screens/mentor_dashboard.dart';
import 'package:skill_circle_app/screens/notifications_screen.dart';
import 'package:skill_circle_app/screens/post_details_screen.dart';
import 'package:skill_circle_app/screens/profile_screen.dart';
import 'package:skill_circle_app/screens/register_screen.dart';
import 'package:skill_circle_app/screens/settings_screen.dart';

class AppRoutes {
  // Route names
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String home = '/home';
  static const String circles = '/circles';
  static const String circleDetails = '/circle-details';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String createPost = '/create-post';
  static const String postDetails = '/post-details';
  static const String adminDashboard = '/admin-dashboard';
  static const String mentorDashboard = '/mentor-dashboard';
  static const String badges = '/badges';

  /// Generate route based on route name and arguments
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );
      case AppRoutes.dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case AppRoutes.circles:
        return MaterialPageRoute(
          builder: (_) => const CirclesScreen(),
          settings: settings,
        );
      case AppRoutes.circleDetails:
        final circleName = settings.arguments as String? ?? 'Unknown Circle';
        return MaterialPageRoute(
          builder: (_) => CircleDetailsScreen(circleName: circleName),
          settings: settings,
        );
      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );
      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      case AppRoutes.notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
          settings: settings,
        );
      case AppRoutes.createPost:
        return MaterialPageRoute(
          builder: (_) => const CreatePostScreen(),
          settings: settings,
        );
      case AppRoutes.postDetails:
        final postId = settings.arguments as String? ?? '1';
        return MaterialPageRoute(
          builder: (_) => PostDetailsScreen(postId: postId),
          settings: settings,
        );
      case AppRoutes.adminDashboard:
        return MaterialPageRoute(
          builder: (_) => const AdminDashboard(),
          settings: settings,
        );
      case AppRoutes.mentorDashboard:
        return MaterialPageRoute(
          builder: (_) => const MentorDashboard(),
          settings: settings,
        );
      case AppRoutes.badges:
        return MaterialPageRoute(
          builder: (_) => const BadgeScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
    }
  }
}
