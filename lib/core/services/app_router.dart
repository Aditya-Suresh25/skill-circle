import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skill_circle_app/core/constants/app_routes.dart';
import 'package:skill_circle_app/core/presentation/widgets/main_shell_page.dart';
import 'package:skill_circle_app/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:skill_circle_app/features/auth/domain/entities/app_user.dart';
import 'package:skill_circle_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:skill_circle_app/features/auth/presentation/pages/login_page.dart';
import 'package:skill_circle_app/features/auth/presentation/pages/register_page.dart';
import 'package:skill_circle_app/features/auth/presentation/pages/splash_page.dart';
import 'package:skill_circle_app/features/comments/presentation/pages/comments_page.dart';
import 'package:skill_circle_app/features/posts/presentation/pages/posts_page.dart';
import 'package:skill_circle_app/features/profile/presentation/pages/profile_page.dart';
import 'package:skill_circle_app/features/skill_circles/presentation/pages/create_circle_screen.dart';
import 'package:skill_circle_app/features/skill_circles/presentation/pages/circle_detail_screen.dart';
import 'package:skill_circle_app/features/skill_circles/presentation/pages/skill_circles_page.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(
    FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  ),
);

final authStateProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(authRepositoryProvider).watchAuthState(),
);

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    redirect: (context, state) {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final user = authState.valueOrNull ??
          (firebaseUser == null
              ? null
              : AppUser(
                  id: firebaseUser.uid,
                  email: firebaseUser.email,
                  displayName: firebaseUser.displayName,
                  photoUrl: firebaseUser.photoURL,
                ));

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

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.createCircle,
        builder: (context, state) => const CreateCircleScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShellPage(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const SkillCirclesPage(),
          ),
          GoRoute(
            path: '/skill-circles/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return CircleDetailScreen(circleId: id);
            },
          ),
          GoRoute(
            path: AppRoutes.circles,
            builder: (context, state) => const SkillCirclesPage(),
          ),
          GoRoute(
            path: AppRoutes.posts,
            builder: (context, state) => const PostsPage(),
          ),
          GoRoute(
            path: AppRoutes.comments,
            builder: (context, state) => const CommentsPage(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfilePage(),
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