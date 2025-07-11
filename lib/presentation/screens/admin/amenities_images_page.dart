import 'package:flutter/material.dart';
import '../../components/my_button.dart';
import 'admin_wizard_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AmenitiesImagesPage extends StatefulWidget {
  final AdminWizardState state;
  const AmenitiesImagesPage({super.key, required this.state});

  @override
  State<AmenitiesImagesPage> createState() => AmenitiesImagesPageState();
}

class AmenitiesImagesPageState extends State<AmenitiesImagesPage> {
  final _formKey = GlobalKey<FormState>();
  String? _errorText;

  bool validate() {
    setState(() {
      _errorText = null;
      if (!widget.state.isCheckedWifi &&
          !widget.state.isCheckedReception &&
          !widget.state.isCheckedPool &&
          !widget.state.isCheckedBreakfast) {
        _errorText = 'Select at least one amenity.';
      } else if (widget.state.hotelImages.isEmpty) {
        _errorText = 'Add at least one hotel image.';
      } else if (widget.state.hotelLatLng.latitude == 0 &&
          widget.state.hotelLatLng.longitude == 0) {
        _errorText = 'Pick a hotel location.';
      }
    });
    return _errorText == null;
  }

  Future<void> pickHotelImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      final appDir = await getApplicationDocumentsDirectory();
      final validFiles = <File>[];
      for (final x in pickedFiles) {
        if (File(x.path).existsSync()) {
          final fileName =
              'hotel_${DateTime.now().millisecondsSinceEpoch}_${x.name}';
          final savedFile = await File(x.path).copy('${appDir.path}/$fileName');
          validFiles.add(savedFile);
        }
      }
      widget.state.hotelImages.addAll(validFiles);
      // Optionally, show an error if some files were missing
      // if (validFiles.length != pickedFiles.length) {
      //   // Show error message to user
      // }
    }
  }

  Future<void> pickLocation(BuildContext context) async {
    // This assumes you have a map picker route set up at '/map' that returns a LatLng
    final result = await Navigator.pushNamed(context, '/map');
    if (result is LatLng) {
      setState(() {
        widget.state.hotelLatLng = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Amenities & Images',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: Text('WiFi'),
            value: widget.state.isCheckedWifi,
            onChanged: (bool? value) {
              setState(() {
                widget.state.isCheckedWifi = value!;
              });
            },
          ),
          CheckboxListTile(
            title: Text('24-hour reception'),
            value: widget.state.isCheckedReception,
            onChanged: (bool? value) {
              setState(() {
                widget.state.isCheckedReception = value!;
              });
            },
          ),
          CheckboxListTile(
            title: Text('Swimming pool'),
            value: widget.state.isCheckedPool,
            onChanged: (bool? value) {
              setState(() {
                widget.state.isCheckedPool = value!;
              });
            },
          ),
          CheckboxListTile(
            title: Text('Breakfast offered'),
            value: widget.state.isCheckedBreakfast,
            onChanged: (bool? value) {
              setState(() {
                widget.state.isCheckedBreakfast = value!;
              });
            },
          ),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(_errorText!, style: TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 16),
          Text('Hotel Images', style: TextStyle(fontWeight: FontWeight.bold)),
          MyButton(
            buttonText: 'Pick Hotel Images',
            onTap: pickHotelImages,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: List.generate(widget.state.hotelImages.length, (index) {
              return Stack(
                children: [
                  Image.file(
                    widget.state.hotelImages[index]!,
                    height: 100,
                    width: 100,
                  ),
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          widget.state.hotelImages[index] = null;
                        });
                      },
                      child: Icon(Icons.remove_circle, color: Colors.red),
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 16),
          Text('Share location', style: TextStyle(fontWeight: FontWeight.bold)),
          MyButton(
            buttonText: 'Share location',
            onTap: () => pickLocation(context),
          ),
          const SizedBox(height: 16),
          Text(
              'Hotel Location: ${widget.state.hotelLatLng.latitude}, ${widget.state.hotelLatLng.longitude}'),
        ],
      ),
    );
  }
}
