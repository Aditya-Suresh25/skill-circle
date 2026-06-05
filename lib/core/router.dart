import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skill_circle_app/features/splash/splash_page.dart';
import 'package:skill_circle_app/features/auth/login_page.dart';
import 'package:skill_circle_app/features/dashboard/dashboard_shell.dart';
import 'package:skill_circle_app/features/circles/circles_page.dart';
import 'package:skill_circle_app/features/circles/circle_detail_page.dart';
import 'package:skill_circle_app/features/circles/create_circle_page.dart';
import 'package:skill_circle_app/features/ai_writer/ai_writer_page.dart';
import 'package:skill_circle_app/features/profile/profile_page.dart';
import 'package:skill_circle_app/features/mentor/mentor_page.dart';
import 'package:skill_circle_app/features/admin/admin_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => DashboardShell(child: child),
        routes: [
          GoRoute(
            path: '/circles',
            builder: (context, state) => const CirclesPage(),
          ),
          GoRoute(
            path: '/ai-writer',
            builder: (context, state) => const AiWriterPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/mentor',
            builder: (context, state) => const MentorPage(),
          ),
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/circle/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CircleDetailPage(circleId: id);
        },
      ),
      GoRoute(
        path: '/create-circle',
        builder: (context, state) => const CreateCirclePage(),
      ),
    ],
  );
});
