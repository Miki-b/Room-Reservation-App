import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/map_controller.dart';

class Maps extends ConsumerStatefulWidget {
  const Maps({super.key});
  @override
  ConsumerState<Maps> createState() => _MapsState();
}

class _MapsState extends ConsumerState<Maps> {
  late GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref
        .read(mapControllerProvider.notifier)
        .checkPermissionsAndGetCurrentLocation());
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _selectedLocation(LatLng location) {
    ref.read(mapControllerProvider.notifier).setMarker(location);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapControllerProvider);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Chapa Integration')),
        body: state.loading
            ? Center(child: CircularProgressIndicator())
            : GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: state.currentLocation ?? LatLng(9.0192, 38.7525),
                  zoom: 13,
                ),
                markers: state.marker != null ? {state.marker!} : {},
                myLocationEnabled: true,
                onLongPress: _selectedLocation,
              ),
      ),
    );
  }
}
