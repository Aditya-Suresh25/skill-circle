import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/providers/appwrite_storage_providers.dart';
import 'package:skill_circle_app/features/auth/data/repositories/appwrite_auth_repository.dart';
import 'package:skill_circle_app/features/auth/domain/entities/app_user.dart';
import 'package:skill_circle_app/features/auth/domain/repositories/auth_repository.dart';

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
