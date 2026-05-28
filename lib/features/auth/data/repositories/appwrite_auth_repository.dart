import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:skill_circle_app/core/constants/appwrite_storage_config.dart';
import 'package:skill_circle_app/features/auth/domain/entities/app_user.dart';
import 'package:skill_circle_app/features/auth/domain/exceptions/auth_failure.dart';
import 'package:skill_circle_app/features/auth/domain/repositories/auth_repository.dart';

class AppwriteAuthRepository implements AuthRepository {
  AppwriteAuthRepository(
    this._account,
    this._databases,
    this._config,
  );

  final Account _account;
  final Databases _databases;
  final AppwriteStorageConfig _config;

  final StreamController<AppUser?> _authStateController = StreamController<AppUser?>.broadcast();
  Future<AppUser?>? _bootstrapFuture;
  AppUser? _cachedUser;

  static const Duration _requestTimeout = Duration(seconds: 25);

  @override
  Stream<AppUser?> watchAuthState() async* {
    yield await _ensureBootstrapped();
    yield* _authStateController.stream;
  }

  @override
  AppUser? currentUser() => _cachedUser;

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return _authOperation(() async {
      await _account.createEmailPasswordSession(
        email: email.trim(),
        password: password,
      );

      final user = await _loadCurrentUser();
      if (user == null) {
        throw const AuthFailure('Unable to sign in.');
      }

      _emitAuthState(user);
      await _safeUpsertUserProfile(user);
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
      await _account.create(
        userId: ID.unique(),
        email: email.trim(),
        password: password,
        name: displayName?.trim().isNotEmpty == true ? displayName!.trim() : null,
      );

      await _account.createEmailPasswordSession(
        email: email.trim(),
        password: password,
      );

      final user = await _loadCurrentUser();
      if (user == null) {
        throw const AuthFailure('Unable to create account.');
      }

      _emitAuthState(user);
      await _safeUpsertUserProfile(user, displayName: displayName);
      return user;
    });
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    throw const AuthFailure('Google sign-in is not enabled for this build.');
  }

  @override
  Future<void> signOut() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (_) {
      // Ignore missing session state.
    }

    _cachedUser = null;
    _authStateController.add(null);
  }

  Future<AppUser?> _ensureBootstrapped() {
    return _bootstrapFuture ??= _loadCurrentUser();
  }

  Future<AppUser?> _loadCurrentUser() async {
    try {
      final user = await _account.get();
      final appUser = _mapUser(user);
      _cachedUser = appUser;
      if (appUser != null) {
        await _safeUpsertUserProfile(appUser);
      }
      return appUser;
    } on AppwriteException {
      _cachedUser = null;
      return null;
    }
  }

  Future<void> _safeUpsertUserProfile(
    AppUser user, {
    String? displayName,
  }) async {
    try {
      await _upsertUserProfile(user, displayName: displayName);
    } catch (_) {
      // Auth should still succeed even if profile sync fails.
    }
  }

  Future<void> _upsertUserProfile(
    AppUser user, {
    String? displayName,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final display = (displayName ?? user.displayName ?? 'Skill Circle Member').trim();
    final profile = <String, dynamic>{
      'displayName': display,
      'email': user.email ?? '',
      'role': 'student',
      'bio': '',
      'joinedSkills': const <String>[],
      'createdAt': now,
      'updatedAt': now,
    };

    if (user.photoUrl != null) {
      profile['photoUrl'] = user.photoUrl;
    }

    try {
      await _databases.createDocument(
        databaseId: _config.databaseId,
        collectionId: _config.usersCollectionId,
        documentId: user.id,
        data: profile,
        permissions: [
          Permission.read(Role.any()),
          Permission.update(Role.user(user.id)),
          Permission.delete(Role.user(user.id)),
        ],
      );
    } on AppwriteException catch (error) {
      if (error.code == 409) {
        final existing = await _databases.getDocument(
          databaseId: _config.databaseId,
          collectionId: _config.usersCollectionId,
          documentId: user.id,
        );
        final existingData = Map<String, dynamic>.from(existing.data as Map);
        profile['role'] = existingData['role'] ?? profile['role'];
        await _databases.updateDocument(
          databaseId: _config.databaseId,
          collectionId: _config.usersCollectionId,
          documentId: user.id,
          data: profile,
        );
      } else if (error.code == 400) {
        // Backward compatibility: some existing Appwrite schemas may not yet include `role`.
        final legacyProfile = Map<String, dynamic>.from(profile)..remove('role');
        try {
          await _databases.createDocument(
            databaseId: _config.databaseId,
            collectionId: _config.usersCollectionId,
            documentId: user.id,
            data: legacyProfile,
            permissions: [
              Permission.read(Role.any()),
              Permission.update(Role.user(user.id)),
              Permission.delete(Role.user(user.id)),
            ],
          );
        } on AppwriteException catch (legacyError) {
          if (legacyError.code == 409) {
            await _databases.updateDocument(
              databaseId: _config.databaseId,
              collectionId: _config.usersCollectionId,
              documentId: user.id,
              data: legacyProfile,
            );
          } else {
            rethrow;
          }
        }
      } else {
        rethrow;
      }
    }
  }

  void _emitAuthState(AppUser? user) {
    _cachedUser = user;
    _authStateController.add(user);
  }

  Future<AppUser> _authOperation(Future<AppUser> Function() operation) async {
    try {
      return await operation().timeout(_requestTimeout);
    } on TimeoutException catch (_) {
      throw const AuthFailure(
        'The request is taking too long. Please check your connection and try again.',
      );
    } on AppwriteException catch (error) {
      throw _mapAppwriteException(error);
    } on AuthFailure {
      rethrow;
    } catch (_) {
      throw const AuthFailure('Something went wrong. Please try again.');
    }
  }

  AuthFailure _mapAppwriteException(AppwriteException error) {
    switch (error.code) {
      case 400:
        return const AuthFailure('Enter valid credentials.', code: 'invalid-credentials');
      case 401:
        return const AuthFailure('Incorrect email or password.', code: 'unauthorized');
      case 404:
        return const AuthFailure('No account found for that email.', code: 'user-not-found');
      case 409:
        return const AuthFailure('An account with this email already exists.', code: 'email-already-in-use');
      case 429:
        return const AuthFailure('Too many attempts. Please wait and try again later.', code: 'too-many-requests');
      case 503:
        return const AuthFailure('Service unavailable. Please try again later.', code: 'service-unavailable');
      default:
        return AuthFailure(error.message ?? 'Unknown error', code: error.type ?? 'unknown');
    }
  }

  AppUser? _mapUser(models.User? user) {
    if (user == null) {
      return null;
    }

    return AppUser(
      id: user.$id,
      email: user.email,
      displayName: user.name.isNotEmpty ? user.name : null,
      photoUrl: null,
    );
  }
}
