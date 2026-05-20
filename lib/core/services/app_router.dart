import 'dart:async';

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
import 'package:skill_circle_app/features/skill_circles/presentation/pages/create_circle_screen.dart';
import 'package:skill_circle_app/features/skill_circles/presentation/pages/circle_detail_screen.dart';
import 'package:skill_circle_app/features/skill_circles/presentation/pages/skill_circles_page.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AppwriteAuthRepository(
    ref.read(appwriteAccountProvider),
    ref.read(appwriteDatabasesProvider),
    ref.read(appwriteStorageConfigProvider),
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