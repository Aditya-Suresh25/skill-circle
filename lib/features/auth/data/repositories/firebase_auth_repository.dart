import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:skill_circle_app/features/auth/domain/entities/app_user.dart';
import 'package:skill_circle_app/features/auth/domain/exceptions/auth_failure.dart';
import 'package:skill_circle_app/features/auth/domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(
    this._auth, {
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;
  static const Duration _requestTimeout = Duration(seconds: 25);
  bool _googleInitialized = false;

  @override
  Stream<AppUser?> watchAuthState() {
    return _auth.authStateChanges().map(_mapUser);
  }

  @override
  AppUser? currentUser() => _mapUser(_auth.currentUser);

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return _authOperation(() async {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = _mapUser(credential.user);
      if (user == null) {
        throw const AuthFailure('Unable to sign in.');
      }

      return user;
    });
  }

  @override
  Future<AppUser> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return _authOperation(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await credential.user?.updateDisplayName(displayName?.trim());
      await credential.user?.reload();

      final user = _mapUser(_auth.currentUser);
      if (user == null) {
        throw const AuthFailure('Unable to create account.');
      }

      // Create initial user profile in Firestore
      try {
        await _createUserProfile(user, email, displayName);
      } catch (e) {
        // Log the error but don't fail the signup
        // User can complete profile later
      }

      return user;
    });
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    return _authOperation(() async {
      if (!_googleSignIn.supportsAuthenticate()) {
        throw const AuthFailure('Google sign-in is not supported on this platform.');
      }

      await _ensureGoogleInitialized();

      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = _mapUser(userCredential.user);
      if (user == null) {
        throw const AuthFailure('Unable to sign in with Google.');
      }

      // Create user profile if it doesn't exist (for first-time Google signin)
      try {
        final docSnapshot =
            await _firestore.collection('users').doc(user.id).get();
        if (!docSnapshot.exists) {
          await _createUserProfile(user, user.email, user.displayName);
        }
      } catch (e) {
        // Log the error but don't fail the signin
      }

      return user;
    });
  }

  @override
  Future<void> signOut() async {
    await _ensureGoogleInitialized();
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Create initial user profile in Firestore
  Future<void> _createUserProfile(
    AppUser user,
    String? email,
    String? displayName,
  ) async {
    await _firestore.collection('users').doc(user.id).set(
      {
        'displayName': displayName ?? user.displayName ?? 'Skill Circle Member',
        'email': email ?? user.email ?? '',
        'photoUrl': user.photoUrl,
        'joinedSkills': [],
        'bio': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) {
      return;
    }

    await _googleSignIn.initialize();
    _googleInitialized = true;
  }

  Future<AppUser> _authOperation(Future<AppUser> Function() operation) async {
    try {
      return await operation().timeout(_requestTimeout);
    } on TimeoutException {
      throw const AuthFailure('The request is taking too long. Please check your connection and try again.');
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseException(error);
    } on AuthFailure {
      rethrow;
    } on FirebaseException catch (error) {
      throw AuthFailure(
        'Firebase error: ${error.message ?? 'Unknown error'}',
        code: error.code,
      );
    } catch (_) {
      throw const AuthFailure('Something went wrong. Please try again.');
    }
  }

  AuthFailure _mapFirebaseException(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return const AuthFailure('Enter a valid email address.', code: 'invalid-email');
      case 'user-not-found':
        return const AuthFailure('No account found for that email.', code: 'user-not-found');
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthFailure('Incorrect email or password.', code: 'wrong-password');
      case 'email-already-in-use':
        return const AuthFailure('An account with this email already exists.', code: 'email-already-in-use');
      case 'weak-password':
        return const AuthFailure('Use a stronger password.', code: 'weak-password');
      case 'network-request-failed':
        return const AuthFailure('Network error. Check your connection and try again.', code: 'network-request-failed');
      case 'too-many-requests':
        return const AuthFailure('Too many attempts. Please wait and try again later.', code: 'too-many-requests');
      case 'user-disabled':
        return const AuthFailure('This account has been disabled.', code: 'user-disabled');
      default:
        return AuthFailure(error.message ?? 'Authentication failed.', code: error.code);
    }
  }

  AppUser? _mapUser(User? user) {
    if (user == null) {
      return null;
    }

    return AppUser(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}