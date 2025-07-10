import 'package:flutter/material.dart';
import '../../components/my_textfield.dart';
import '../../components/my_button.dart';
import 'admin_wizard_state.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RoomTypesPage extends StatefulWidget {
  final AdminWizardState state;
  const RoomTypesPage({super.key, required this.state});

  @override
  State<RoomTypesPage> createState() => RoomTypesPageState();
}

class RoomTypesPageState extends State<RoomTypesPage> {
  final _formKey = GlobalKey<FormState>();
  String? _errorText;

  bool validate() {
    setState(() {
      _errorText = null;
      for (int i = 0; i < widget.state.typeofRooms; i++) {
        if (widget.state.roomImages.length <= i ||
            widget.state.roomImages[i] == null) {
          _errorText = 'Please pick an image for each room type.';
          break;
        }
      }
    });
    return (_formKey.currentState?.validate() ?? false) && _errorText == null;
  }

  late final TextEditingController typesOfRoomsController;

  @override
  void initState() {
    super.initState();
    typesOfRoomsController =
        TextEditingController(text: widget.state.typeofRooms.toString());
  }

  @override
  void dispose() {
    typesOfRoomsController.dispose();
    super.dispose();
  }

  Future<void> pickRoomImage(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && File(pickedFile.path).existsSync()) {
      setState(() {
        widget.state.roomImages[index] = File(pickedFile.path);
      });
    } else {
      // Optionally, show error message to user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Room Types', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          MyTextfield(
            labelText: 'Types of rooms available in numbers',
            controller: typesOfRoomsController,
            onChanged: (value) {
              setState(() {
                widget.state.typeofRooms = int.tryParse(value) ?? 0;
                widget.state
                    .initializeRoomControllers(widget.state.typeofRooms);
              });
            },
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              final n = int.tryParse(v);
              if (n == null || n <= 0) return 'Enter a valid number';
              return null;
            },
          ),
          const SizedBox(height: 16),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(_errorText!, style: TextStyle(color: Colors.red)),
            ),
          if (widget.state.typeofRooms > 0)
            Column(
              children: List.generate(widget.state.typeofRooms, (index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Room Type ${index + 1}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 12),
                        MyTextfield(
                          labelText: 'Room Type Name',
                          controller: widget.state.roomTypeControllers[index],
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        MyTextfield(
                          labelText: 'Room Type Description',
                          controller: widget
                              .state.roomTypeDescriptionControllers[index],
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        MyTextfield(
                          labelText: 'Price',
                          controller: widget.state.priceControllers[index],
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            final n = double.tryParse(v);
                            if (n == null || n <= 0)
                              return 'Enter a valid price';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        MyButton(
                          buttonText: 'Pick Image for Room Type ${index + 1}',
                          onTap: () => pickRoomImage(index),
                        ),
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
                                    setState(() {
                                      widget.state.roomImages[index] = null;
                                    });
                                  },
                                  child: Icon(Icons.remove_circle,
                                      color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}
