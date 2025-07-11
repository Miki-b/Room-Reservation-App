import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HotelMapScreen extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String hotelName;
  const HotelMapScreen(
      {Key? key,
      required this.latitude,
      required this.longitude,
      required this.hotelName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LatLng hotelLatLng = LatLng(latitude, longitude);
    return Scaffold(
      appBar: AppBar(title: Text(hotelName)),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: hotelLatLng,
          zoom: 16,
        ),
        markers: {
          Marker(
            markerId: MarkerId('hotel'),
            position: hotelLatLng,
            infoWindow: InfoWindow(title: hotelName),
          ),
        },
      ),
    );
  }
}
