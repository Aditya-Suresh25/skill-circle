import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/features/profile/domain/entities/profile.dart';
import 'package:skill_circle_app/features/profile/domain/repositories/profile_repository.dart';

/// StateNotifier for managing profile state and operations
class ProfileController extends StateNotifier<AsyncValue<Profile?>> {
  ProfileController(this._profileRepository)
      : super(const AsyncValue.loading());

  final ProfileRepository _profileRepository;

  /// Fetch user profile
  Future<void> fetchUserProfile(String userId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _profileRepository.getUserProfile(userId),
    );
  }

  /// Create initial profile after signup
  Future<void> createProfile(Profile profile) async {
    state = const AsyncValue.loading();
    try {
      await _profileRepository.createUserProfile(profile);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update profile fields (name, bio, joined_skills)
  Future<void> updateProfile(String userId, Map<String, dynamic> updates) async {
    final currentProfile = state.valueOrNull;
    if (currentProfile == null) return;

    state = const AsyncValue.loading();
    try {
      await _profileRepository.updateUserProfile(userId, updates);

      // Update local state with new values
      final updatedProfile = currentProfile.copyWith(
        displayName: updates['displayName'] ?? currentProfile.displayName,
        bio: updates['bio'] ?? currentProfile.bio,
        joinedSkills: updates['joinedSkills'] ?? currentProfile.joinedSkills,
      );
      state = AsyncValue.data(updatedProfile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Upload profile image
  Future<String?> uploadProfileImage(String userId, File imageFile) async {
    try {
      final downloadUrl =
          await _profileRepository.uploadProfileImage(userId, imageFile);

      // Update local state with new photo URL
      final currentProfile = state.valueOrNull;
      if (currentProfile != null) {
        final updatedProfile = currentProfile.copyWith(
          photoUrl: downloadUrl,
        );
        state = AsyncValue.data(updatedProfile);
      }

      return downloadUrl;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Delete profile image
  Future<void> deleteProfileImage(String userId) async {
    try {
      await _profileRepository.deleteProfileImage(userId);

      // Update local state to remove photo URL
      final currentProfile = state.valueOrNull;
      if (currentProfile != null) {
        final updatedProfile = currentProfile.copyWith(photoUrl: null);
        state = AsyncValue.data(updatedProfile);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
