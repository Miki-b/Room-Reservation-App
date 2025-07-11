import 'package:flutter/material.dart';
import '../../components/my_textfield.dart';
import 'admin_wizard_state.dart';
import '../../controllers/payment_method_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'map_picker_screen.dart';

class HotelInfoPage extends ConsumerStatefulWidget {
  final AdminWizardState state;
  const HotelInfoPage({super.key, required this.state});

  @override
  HotelInfoPageState createState() => HotelInfoPageState();
}

class HotelInfoPageState extends ConsumerState<HotelInfoPage> {
  String? selectedPaymentMethodId;
  final _formKey = GlobalKey<FormState>();

  bool validate() {
    return _formKey.currentState?.validate() ?? false;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(paymentMethodControllerProvider.notifier).fetch());
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentMethodControllerProvider);
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
          Row(
            children: [
              Expanded(
                child: MyTextfield(
                  labelText: 'Location',
                  controller: widget.state.locationController,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final picked = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MapPickerScreen()),
                  );
                  if (picked != null) {
                    widget.state.hotelLatLng = picked;
                    setState(() {});
                  }
                },
                child: Text('Pick on Map'),
              ),
            ],
          ),
          if (widget.state.hotelLatLng.latitude != 0 ||
              widget.state.hotelLatLng.longitude != 0)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                  'Selected: (${widget.state.hotelLatLng.latitude.toStringAsFixed(5)}, ${widget.state.hotelLatLng.longitude.toStringAsFixed(5)})'),
            ),
          const SizedBox(height: 12),
          MyTextfield(
            labelText: 'Description',
            controller: widget.state.descriptionController,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payment Method',
                  style: Theme.of(context).textTheme.titleMedium),
              if (paymentState.loading)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                )
              else if (paymentState.error != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Error: ${paymentState.error}',
                      style: TextStyle(color: Colors.red)),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedPaymentMethodId,
                      items: paymentState.methods
                          .map((m) => DropdownMenuItem(
                                value: m.methodId,
                                child: Text(m.methodName),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethodId = value;
                          widget.state.selectedPaymentMethodId = value;
                        });
                      },
                      decoration:
                          InputDecoration(labelText: 'Select Payment Method'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    if (selectedPaymentMethodId != null)
                      MyTextfield(
                        labelText: 'Account Number',
                        controller: TextEditingController(
                            text: widget.state.selectedPaymentAccountNumber ??
                                ''),
                        onChanged: (v) =>
                            widget.state.selectedPaymentAccountNumber = v,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
