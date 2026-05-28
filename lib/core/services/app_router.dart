import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skill_circle_app/core/constants/app_routes.dart';
import 'package:skill_circle_app/core/providers/appwrite_storage_providers.dart';
import 'package:skill_circle_app/core/presentation/widgets/main_shell_page.dart';
import 'package:skill_circle_app/features/auth/data/repositories/appwrite_auth_repository.dart';
import 'package:skill_circle_app/features/auth/domain/entities/app_user.dart';
import 'package:skill_circle_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:skill_circle_app/features/auth/presentation/pages/login_page.dart';
import 'package:skill_circle_app/features/auth/presentation/pages/register_page.dart';
import 'package:skill_circle_app/features/auth/presentation/pages/splash_page.dart';
import 'package:skill_circle_app/features/comments/presentation/pages/comments_page.dart';
import 'package:skill_circle_app/features/posts/presentation/pages/posts_page.dart';
import 'package:skill_circle_app/features/profile/presentation/pages/profile_page.dart';
import 'package:skill_circle_app/features/profile/presentation/providers/profile_providers.dart';
import 'package:skill_circle_app/features/skill_circles/presentation/pages/create_circle_screen.dart';
import 'package:skill_circle_app/features/skill_circles/presentation/pages/circle_detail_screen.dart';
import 'package:skill_circle_app/features/skill_circles/presentation/pages/skill_circles_page.dart';
import 'package:skill_circle_app/features/mentor/presentation/pages/mentor_dashboard_page.dart';
import 'package:skill_circle_app/features/mentor/presentation/pages/mentor_signup_page.dart';
import 'package:skill_circle_app/features/mentor/presentation/providers/mentor_providers.dart';
import 'package:skill_circle_app/features/admin/presentation/pages/admin_dashboard_page.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AppwriteAuthRepository(
    ref.read(appwriteAccountProvider),
    ref.read(appwriteDatabasesProvider),
    ref.read(appwriteStorageConfigProvider),
  ),
);

final routerAuthStateProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(authRepositoryProvider).watchAuthState(),
);

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(routerAuthStateProvider);
  final mentorProfile = ref.watch(currentMentorProfileProvider);
  final currentProfile = ref.watch(currentProfileProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: GoRouterRefreshStream(ref.watch(authRepositoryProvider).watchAuthState()),
    redirect: (context, state) {
      if (authState.isLoading) {
        return null;
      }

      final user = authState.valueOrNull;

      final isLoggedIn = user != null;
      final isOnAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.splash;

      // Redirect to login if not logged in and not already on a public auth page
      if (!isLoggedIn) {
        if (state.matchedLocation != AppRoutes.login &&
            state.matchedLocation != AppRoutes.register) {
          return AppRoutes.login;
        }
      }

      // Redirect to home if logged in and on auth page
      if (isLoggedIn && isOnAuthRoute) {
        return AppRoutes.home;
      }

      // Mentor route guard: if user navigates to mentor dashboard but has no mentor profile, send to signup
      if (state.matchedLocation == AppRoutes.mentorDashboard) {
        final hasMentor = mentorProfile is AsyncData && mentorProfile.value != null;
        if (!hasMentor) return AppRoutes.mentorSignup;
      }

      if (state.matchedLocation == AppRoutes.adminDashboard) {
        if (currentProfile.isLoading) {
          return null;
        }
        final profile = currentProfile.valueOrNull;
        if (profile == null) {
          return isLoggedIn ? AppRoutes.home : AppRoutes.login;
        }
        if (profile.role.toLowerCase() != 'admin') {
          return AppRoutes.home;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => _transitionPage(state, const SplashPage()),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => _transitionPage(state, const LoginPage()),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) => _transitionPage(state, const RegisterPage()),
      ),
      GoRoute(
        path: AppRoutes.createCircle,
        pageBuilder: (context, state) => _transitionPage(state, const CreateCircleScreen()),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShellPage(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => _transitionPage(state, const SkillCirclesPage()),
          ),
          GoRoute(
            path: '/skill-circles/:id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return _transitionPage(state, CircleDetailScreen(circleId: id));
            },
          ),
          GoRoute(
            path: AppRoutes.circles,
            pageBuilder: (context, state) => _transitionPage(state, const SkillCirclesPage()),
          ),
          GoRoute(
            path: AppRoutes.posts,
            pageBuilder: (context, state) => _transitionPage(state, const PostsPage()),
          ),
          GoRoute(
            path: AppRoutes.comments,
            pageBuilder: (context, state) => _transitionPage(state, const CommentsPage()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) => _transitionPage(state, const ProfilePage()),
          ),
          GoRoute(
            path: AppRoutes.mentorSignup,
            pageBuilder: (context, state) => _transitionPage(state, const MentorSignupPage()),
          ),
          GoRoute(
            path: AppRoutes.mentorDashboard,
            pageBuilder: (context, state) => _transitionPage(state, const MentorDashboardPage()),
          ),
          GoRoute(
            path: AppRoutes.adminDashboard,
            pageBuilder: (context, state) => _transitionPage(state, const AdminDashboardPage()),
          ),
        ],
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

CustomTransitionPage<void> _transitionPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, pageChild) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      final slide = Tween<Offset>(begin: const Offset(0.02, 0.03), end: Offset.zero).animate(fade);
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: pageChild),
      );
    },
  );
}