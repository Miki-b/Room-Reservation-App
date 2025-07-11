import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MapState {
  final LatLng? currentLocation;
  final bool loading;
  final String? error;
  final Marker? marker;
  MapState({this.currentLocation, this.loading = false, this.error, this.marker});
  MapState copyWith({LatLng? currentLocation, bool? loading, String? error, Marker? marker}) => MapState(
    currentLocation: currentLocation ?? this.currentLocation,
    loading: loading ?? this.loading,
    error: error,
    marker: marker ?? this.marker,
  );
}

class MapController extends StateNotifier<MapState> {
  MapController() : super(MapState());

  Future<void> checkPermissionsAndGetCurrentLocation() async {
    state = state.copyWith(loading: true, error: null);
    var status = await Permission.location.request();
    if (status.isGranted) {
      try {
        final pos = await Geolocator.getCurrentPosition();
        final latLng = LatLng(pos.latitude, pos.longitude);
        state = state.copyWith(currentLocation: latLng, loading: false);
      } catch (e) {
        state = state.copyWith(error: e.toString(), loading: false);
      }
    } else {
      state = state.copyWith(error: 'Location permission denied', loading: false);
    }
  }

  void setMarker(LatLng location) {
    state = state.copyWith(marker: Marker(markerId: MarkerId('selected'), position: location));
  }
}

final mapControllerProvider = StateNotifierProvider<MapController, MapState>((ref) => MapController()); 