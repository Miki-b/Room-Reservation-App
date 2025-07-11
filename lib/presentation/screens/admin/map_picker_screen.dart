import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({Key? key}) : super(key: key);

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pick Hotel Location')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(9.0192, 38.7525), // Default to Addis Ababa
              zoom: 13,
            ),
            onLongPress: (latLng) {
              setState(() {
                selectedLocation = latLng;
              });
            },
            markers: selectedLocation != null
                ? {
                    Marker(
                        markerId: MarkerId('selected'),
                        position: selectedLocation!)
                  }
                : {},
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: selectedLocation == null
                  ? null
                  : () {
                      Navigator.pop(context, selectedLocation);
                    },
              child: Text('Set Location'),
            ),
          ),
        ],
      ),
    );
  }
}
