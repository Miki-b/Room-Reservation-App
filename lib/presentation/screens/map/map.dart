import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class Maps extends StatefulWidget {
  const Maps({super.key});

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  void showPopupMessage(String title, String message, bool success) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (success) Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _kGoogle = const CameraPosition(
    target: LatLng(9.0192, 38.7525),
    zoom: 13,
  );
  LatLng _currentLocation = LatLng(0, 0);
  LatLng? _location;
  Marker? _marker;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndGetCurrentLocation();
  }

  Future<void> _checkPermissionsAndGetCurrentLocation() async {
    // Request location permission
    var status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      // Handle the case where permission is denied
      print("Location permission denied");
    }
  }

  Future<Position> _getCurrentLocation() async {
    await Geolocator.requestPermission().then((value) {
    }).onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR" + error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _selectedLocation(LatLng location) {
    setState(() {
      _location = location;
      _marker = Marker(
        markerId: MarkerId('selected-location'),
        position: location,
      );
    });
    print("\n\nSelected location: $_location  \n\n");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green[700],
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose your hotel location'),
              Text(
                'Long press on the location you want to set',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w200,
                  fontSize: 10,
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
          elevation: 2,
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: _kGoogle,
          markers: _marker != null ? {_marker!} : {},
          myLocationEnabled: true,
          onLongPress: _selectedLocation,
        ),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 350,
                  height: 100,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.teal[500]!),
                    ),
                    onPressed: () {
                      if(_location != null)
                      Navigator.pop(context, _location);
                      else{
                      showPopupMessage('location not selected', 'long press on the location you want to select', false);
                      }
                    }
                       , // Disable button if _location is null
                    child: Text(
                      'Set location',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            _getCurrentLocation().then((value) async {
              print(value.latitude.toString() + " " + value.longitude.toString());

              CameraPosition cameraPosition = new CameraPosition(
                target: LatLng(value.latitude, value.longitude),
                zoom: 18,
              );
              final GoogleMapController controller = await _controller.future;
              controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
              setState(() {});
            });
          },
          child: Icon(Icons.location_searching),
          backgroundColor: Colors.teal[500],
        ),
      ),
    );
  }
}
