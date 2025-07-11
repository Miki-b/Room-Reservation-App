import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/edit_profile_controller.dart';
import '../../widgets/profile_form_widget.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load user profile when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(editProfileControllerProvider.notifier).loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editProfileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          if (state.error != null || state.successMessage != null)
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                ref
                    .read(editProfileControllerProvider.notifier)
                    .clearMessages();
              },
            ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(EditProfileState state) {
    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading profile data...'),
          ],
        ),
      );
    }

    if (state.error != null && state.userProfile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Failed to load profile',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(editProfileControllerProvider.notifier)
                    .loadUserProfile();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: ProfileFormWidget(
          userProfile: state.userProfile,
          isLoading: state.isSaving,
          errorMessage: state.error,
          successMessage: state.successMessage,
          onSave: ({required String firstName, required String lastName, required String address, required String email, required String phone}) {
            ref.read(editProfileControllerProvider.notifier).updateProfile(
              firstName: firstName,
              lastName: lastName,
              address: address,
              email: email,
              phone: phone,
            );
          },
        ),
      ),
    );
  }
}
