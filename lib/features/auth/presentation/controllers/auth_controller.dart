import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/services/app_router.dart';
import 'package:skill_circle_app/features/auth/domain/exceptions/auth_failure.dart';
import 'package:skill_circle_app/features/profile/presentation/providers/profile_providers.dart';
import 'package:skill_circle_app/features/skill_circles/presentation/providers/skill_circles_providers.dart';

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._ref) : super(const AsyncData<void>(null));

  final Ref _ref;

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await _ref.read(authRepositoryProvider).signInWithEmailAndPassword(
            email: email,
            password: password,
          );
    });
  }

  Future<void> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await _ref.read(authRepositoryProvider).registerWithEmailAndPassword(
            email: email,
            password: password,
            displayName: displayName,
          );
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await _ref.read(authRepositoryProvider).signInWithGoogle();
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await _ref.read(authRepositoryProvider).signOut();
      _ref.invalidate(profileControllerProvider);
      _ref.invalidate(skillCirclesControllerProvider);
    });
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>(
  (ref) => AuthController(ref),
);

String authFailureMessage(Object error) {
  if (error is AuthFailure) {
    return error.message;
  }

  return error.toString();
}