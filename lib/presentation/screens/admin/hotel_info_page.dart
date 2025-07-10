import 'package:flutter/material.dart';
import '../../components/my_textfield.dart';
import 'admin_wizard_state.dart';

class HotelInfoPage extends StatefulWidget {
  final AdminWizardState state;
  const HotelInfoPage({super.key, required this.state});

  @override
  State<HotelInfoPage> createState() => HotelInfoPageState();
}

class HotelInfoPageState extends State<HotelInfoPage> {
  final _formKey = GlobalKey<FormState>();

  bool validate() {
    return _formKey.currentState?.validate() ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Hotel Information',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          MyTextfield(
            labelText: 'Hotel Name',
            controller: widget.state.nameController,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          MyTextfield(
            labelText: 'Hotel Email',
            controller: widget.state.emailController,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              final email = v.trim();
              final emailRegex = RegExp(r'.+@.+\..+');
              if (!emailRegex.hasMatch(email)) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 12),
          MyTextfield(
            labelText: 'Hotel Class',
            controller: widget.state.starsController,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          MyTextfield(
            labelText: 'Location',
            controller: widget.state.locationController,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          MyTextfield(
            labelText: 'Description',
            controller: widget.state.descriptionController,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
        ],
      ),
    );
  }
}
