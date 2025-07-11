import 'package:flutter/material.dart';
import '../components/my_textfield.dart';
import '../../data/models/user_profile_model.dart';

class ProfileFormWidget extends StatefulWidget {
  final UserProfileModel? userProfile;
  final Function({
    required String firstName,
    required String lastName,
    required String address,
    required String email,
    required String phone,
  }) onSave;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const ProfileFormWidget({
    Key? key,
    this.userProfile,
    required this.onSave,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  }) : super(key: key);

  @override
  State<ProfileFormWidget> createState() => _ProfileFormWidgetState();
}

class _ProfileFormWidgetState extends State<ProfileFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(ProfileFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userProfile != widget.userProfile) {
      _updateControllers();
    }
  }

  void _initializeControllers() {
    _firstNameController =
        TextEditingController(text: widget.userProfile?.firstName ?? '');
    _lastNameController =
        TextEditingController(text: widget.userProfile?.lastName ?? '');
    _addressController =
        TextEditingController(text: widget.userProfile?.address ?? '');
    _emailController =
        TextEditingController(text: widget.userProfile?.email ?? '');
    _phoneController =
        TextEditingController(text: widget.userProfile?.phone ?? '');
  }

  void _updateControllers() {
    _firstNameController.text = widget.userProfile?.firstName ?? '';
    _lastNameController.text = widget.userProfile?.lastName ?? '';
    _addressController.text = widget.userProfile?.address ?? '';
    _emailController.text = widget.userProfile?.email ?? '';
    _phoneController.text = widget.userProfile?.phone ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        address: _addressController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyTextfield(
            labelText: 'First Name',
            controller: _firstNameController,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Enter first name' : null,
          ),
          SizedBox(height: 16),
          MyTextfield(
            labelText: 'Last Name',
            controller: _lastNameController,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Enter last name' : null,
          ),
          SizedBox(height: 16),
          MyTextfield(
            labelText: 'Address',
            controller: _addressController,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Enter address' : null,
          ),
          SizedBox(height: 16),
          MyTextfield(
            labelText: 'Email',
            controller: _emailController,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Enter email' : null,
          ),
          SizedBox(height: 16),
          MyTextfield(
            labelText: 'Phone Number',
            controller: _phoneController,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Enter phone number' : null,
          ),
          SizedBox(height: 24),
          _buildMessageWidget(),
          SizedBox(height: 16),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildMessageWidget() {
    if (widget.successMessage != null) {
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Expanded(
                child: Text(widget.successMessage!,
                    style: TextStyle(color: Colors.green))),
          ],
        ),
      );
    }

    if (widget.errorMessage != null) {
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red),
        ),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Expanded(
                child: Text(widget.errorMessage!,
                    style: TextStyle(color: Colors.red))),
          ],
        ),
      );
    }

    return SizedBox.shrink();
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : _handleSave,
        child: widget.isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text('Save Changes'),
      ),
    );
  }
}
