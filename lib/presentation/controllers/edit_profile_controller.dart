import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/repositories/user_profile_repository.dart';

class EditProfileState {
  final bool isLoading;
  final bool isSaving;
  final UserProfileModel? userProfile;
  final String? error;
  final String? successMessage;

  EditProfileState({
    this.isLoading = false,
    this.isSaving = false,
    this.userProfile,
    this.error,
    this.successMessage,
  });

  EditProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    UserProfileModel? userProfile,
    String? error,
    String? successMessage,
  }) {
    return EditProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      userProfile: userProfile ?? this.userProfile,
      error: error,
      successMessage: successMessage,
    );
  }
}

class EditProfileController extends StateNotifier<EditProfileState> {
  final UserProfileRepository _repository;

  EditProfileController(this._repository) : super(EditProfileState());

  Future<void> loadUserProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final profile = await _repository.getUserProfile();
      state = state.copyWith(
        isLoading: false,
        userProfile: profile,
        error: profile == null ? 'User profile not found' : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String address,
    required String email,
    required String phone,
  }) async {
    if (state.userProfile == null) {
      state = state.copyWith(error: 'No profile data available');
      return;
    }

    state = state.copyWith(isSaving: true, error: null, successMessage: null);

    try {
      await _repository.updateUserProfileFields(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        address: address.trim(),
        email: email.trim(),
        phone: phone.trim(),
      );

      // Update local state with new data
      final updatedProfile = state.userProfile!.copyWith(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        address: address.trim(),
        email: email.trim(),
        phone: phone.trim(),
      );

      state = state.copyWith(
        isSaving: false,
        userProfile: updatedProfile,
        successMessage: 'Profile updated successfully!',
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to update profile: $e',
      );
    }
  }

  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

final editProfileControllerProvider =
    StateNotifierProvider<EditProfileController, EditProfileState>((ref) {
  final repository = UserProfileRepository();
  return EditProfileController(repository);
});
