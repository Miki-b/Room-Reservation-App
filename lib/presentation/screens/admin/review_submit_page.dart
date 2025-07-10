import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/my_button.dart';
import 'admin_wizard_state.dart';
import '../../controllers/admin_controller.dart';
import 'dart:io';

class ReviewSubmitPage extends ConsumerStatefulWidget {
  final AdminWizardState state;
  const ReviewSubmitPage({super.key, required this.state});

  @override
  ConsumerState<ReviewSubmitPage> createState() => _ReviewSubmitPageState();
}

class _ReviewSubmitPageState extends ConsumerState<ReviewSubmitPage> {
  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminControllerProvider);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Review & Submit',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Text('Hotel Name: ${widget.state.nameController.text}'),
        Text('Hotel Email: ${widget.state.emailController.text}'),
        Text('Hotel Class: ${widget.state.starsController.text}'),
        Text('Location: ${widget.state.locationController.text}'),
        Text('Description: ${widget.state.descriptionController.text}'),
        const SizedBox(height: 16),
        Text('Room Types', style: TextStyle(fontWeight: FontWeight.bold)),
        if (widget.state.typeofRooms > 0)
          Column(
            children: List.generate(widget.state.typeofRooms, (index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Room Type ${index + 1}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Name: ${widget.state.roomTypeControllers[index].text}'),
                  Text(
                      'Description: ${widget.state.roomTypeDescriptionControllers[index].text}'),
                  Text('Price: ${widget.state.priceControllers[index].text}'),
                  const SizedBox(height: 8),
                  if (widget.state.roomImages[index] != null)
                    Stack(
                      children: [
                        Image.file(
                          widget.state.roomImages[index]!,
                          height: 100,
                          width: 100,
                        ),
                        Positioned(
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              // TODO: Remove image logic
                            },
                            child: Icon(Icons.remove_circle, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                ],
              );
            }),
          ),
        const SizedBox(height: 16),
        Text('Amenities', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('WiFi: ${widget.state.isCheckedWifi ? 'Yes' : 'No'}'),
        Text(
            '24-hour reception: ${widget.state.isCheckedReception ? 'Yes' : 'No'}'),
        Text('Swimming pool: ${widget.state.isCheckedPool ? 'Yes' : 'No'}'),
        Text(
            'Breakfast offered: ${widget.state.isCheckedBreakfast ? 'Yes' : 'No'}'),
        const SizedBox(height: 16),
        if (adminState.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(adminState.error!, style: TextStyle(color: Colors.red)),
          ),
        if (adminState.success)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text('Hotel added successfully!',
                style: TextStyle(color: Colors.green)),
          ),
        MyButton(
          buttonText: adminState.isLoading ? 'Submitting...' : 'Submit',
          onTap: adminState.isLoading
              ? null
              : () async {
                  final facilities = <String>[];
                  if (widget.state.isCheckedWifi) facilities.add('WiFi');
                  if (widget.state.isCheckedReception)
                    facilities.add('24-hour reception');
                  if (widget.state.isCheckedPool)
                    facilities.add('Swimming pool');
                  if (widget.state.isCheckedBreakfast)
                    facilities.add('Breakfast offered');
                  await ref.read(adminControllerProvider.notifier).submitHotel(
                        hotelName: widget.state.nameController.text,
                        hotelEmail: widget.state.emailController.text,
                        facilities: facilities,
                        roomTypes: List.generate(widget.state.typeofRooms,
                            (i) => widget.state.roomTypeControllers[i].text),
                        // Not used in new model
                        prices: List.generate(
                            widget.state.typeofRooms,
                            (i) =>
                                double.tryParse(
                                    widget.state.priceControllers[i].text) ??
                                0),
                        hotelImages: widget.state.hotelImages.cast<File?>(),
                        roomImages: widget.state.roomImages.cast<File?>(),
                        location: widget.state.locationController.text,
                        
                        description: widget.state.descriptionController.text,
                        roomTypeDescriptions: List.generate(
                            widget.state.typeofRooms,
                            (i) => widget
                                .state.roomTypeDescriptionControllers[i].text),
                      );
                },
        ),
      ],
    );
  }
}
