import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../home/HomeScreen.dart';
import '../../../firestore.dart';

class HotelsMap extends StatefulWidget {
  final List<Hotels> allHotels;

  HotelsMap({super.key, required this.allHotels});

  @override
  State<HotelsMap> createState() => _HotelsMapState();
}

class _HotelsMapState extends State<HotelsMap> {
  late GoogleMapController _mapController;
  final Map<String, Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initMarkers();
  }

  void _initMarkers() {
    for (final hotel in widget.allHotels) {
      final marker = Marker(
        markerId: MarkerId(hotel.hotelname),
        position: LatLng(hotel.latitude, hotel.longitude),
        infoWindow: InfoWindow(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/HotelProfile',
              arguments: hotel,

            );
          },
          title: hotel.hotelname,
          snippet: hotel.email,
        ),
      );
      _markers[hotel.hotelname] = marker;
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      // Markers are already initialized in initState
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotels Location'),
        elevation: 2,
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(9.0192, 38.7525),
          zoom: 13,
        ),
        markers: _markers.values.toSet(),
        myLocationEnabled: true,
      ),
    );
  }
}
