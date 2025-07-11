import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../data/models/hotel_model.dart';

class HotelsMap extends StatefulWidget {
  final List<HotelModel> allHotels;

  HotelsMap({super.key, required this.allHotels});

  @override
  State<HotelsMap> createState() => _HotelsMapState();
}

class _HotelsMapState extends State<HotelsMap> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _setMarkers();
  }

  void _setMarkers() {
    final markers = widget.allHotels.map((hotel) {
      return Marker(
        markerId: MarkerId(hotel.id),
        position: LatLng(hotel.latitude, hotel.longitude),
        infoWindow: InfoWindow(
          title: hotel.name,
          snippet: hotel.description,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/HotelProfile',
              arguments: hotel,
            );
          },
        ),
      );
    }).toSet();
    setState(() {
      _markers = markers;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
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
        markers: _markers,
        myLocationEnabled: true,
      ),
    );
  }
}
