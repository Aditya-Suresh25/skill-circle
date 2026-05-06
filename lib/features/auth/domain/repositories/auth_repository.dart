import 'package:skill_circle_app/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> watchAuthState();
  AppUser? currentUser();
  Future<AppUser> signInWithEmailAndPassword({required String email, required String password});
  Future<AppUser> registerWithEmailAndPassword({required String email, required String password, String? displayName});
  Future<AppUser> signInWithGoogle();
  Future<void> signOut();
}