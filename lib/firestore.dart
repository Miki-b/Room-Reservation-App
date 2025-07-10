import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

import 'presentation/screens/home/HomeScreen.dart';

import 'presentation/screens/hotel/Hotels.dart';  // Assuming you have this Hotels class definition in a separate file

class FirestoreService {

  static Future<String> getPlacemarks(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);

      String address = '';

      if (placemarks.isNotEmpty) {
        // Get the last Placemark from the reversed list
        Placemark placemark = placemarks.reversed.last;

        // Extract the city (locality) and country
        String? city = placemark.locality;
        String? country = placemark.country;

        // Concatenate city and country if they are not null
        if (city != null && country != null) {
          address = '$city, $country';
        } else if (city != null) {
          address = city;
        } else if (country != null) {
          address = country;
        }
      }

      print("Your Address for ($lat, $long) is: $address");

      return address;
    } catch (e) {
      print("Error getting placemarks: $e");
      return "No Address";
    }
  }


  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const double _radius = 5000; // Radius in meters (5 km)

  static List<String> tokenizeAndNormalize(String sentence) {
    // Convert to lowercase
    String lowercased = sentence.toLowerCase();

    // Remove punctuation and split into tokens
    RegExp tokenPattern = RegExp(r'\b\w+\b'); // Regex to match words
    Iterable<Match> matches = tokenPattern.allMatches(lowercased);

    List<String> tokens = matches.map((match) => match.group(0)!).toList();

    return tokens;
  }

  static Future<List<Hotels>> fetchNearbyHotels() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      double userLat = position.latitude;
      double userLon = position.longitude;

      QuerySnapshot snapshot = await _firestore.collection("hotels").get();
      List<Hotels> nearbyHotels = [];

      for (var doc in snapshot.docs) {
        GeoPoint geoPoint = doc['location'];
        double distance = await calculateDistance(userLat, userLon, geoPoint.latitude, geoPoint.longitude);

        if (distance <= _radius) {
          nearbyHotels.add(Hotels(
            id: doc.id,
            hotelname: doc['name'],
            email: doc['email'],
            roomType: List<String>.from(doc['roomType']),
            noOfBeds: List<int>.from(doc['beds']),
            price: List<double>.from(doc['price']),
            roomSize: List<double>.from(doc['size']),
            availableRooms: List<int>.from(doc['roomsAvailable']),
            facilities: List<String>.from(doc['facilities']),
            latitude: geoPoint.latitude,
            longitude: geoPoint.longitude,
            hotelStar: 4, // Adjust this line if the star rating is stored in Firestore
            imageUrls: List<dynamic>.from(doc['imageUrls']),
            tokens: tokenizeAndNormalize(doc['name']),
            location: await getPlacemarks(geoPoint.latitude, geoPoint.longitude),roomimages: doc['roomImageUrls'],
          ));
        }
      }
      return nearbyHotels;
    } catch (e) {
      print('Error fetching nearby hotels1: $e');
      return [];
    }
  }

  static Future<List<Hotels>> allHotels() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection("hotels").get();
      List<Hotels> allHotels = [];

      for (var doc in snapshot.docs) {
        GeoPoint geoPoint = doc['location'];
        allHotels.add(Hotels(
          id: doc.id,
          hotelname: doc['name'],
          email: doc['email'],
          roomType: List<String>.from(doc['roomType']),
          noOfBeds: List<int>.from(doc['beds']),
          price: List<double>.from(doc['price']),
          roomSize: List<double>.from(doc['size']),
          availableRooms: List<int>.from(doc['roomsAvailable']),
          facilities: List<String>.from(doc['facilities']),
          latitude: geoPoint.latitude,
          longitude: geoPoint.longitude,
          hotelStar: 4, // Adjust this line if the star rating is stored in Firestore
          imageUrls: List<dynamic>.from(doc['imageUrls']),
          tokens: tokenizeAndNormalize(doc['name']), location: await getPlacemarks(geoPoint.latitude, geoPoint.longitude), roomimages: doc['roomImageUrls'],
        ));
      }
      print("All hotels: $allHotels");
      return allHotels;
    } catch (e) {
      print('Error fetching all hotels2: $e');
      return [];
    }
  }

  static Future<double> calculateDistance(double lat1, double lon1, double lat2, double lon2) async {
    const double p = 0.017453292519943295; // Pi/180
    final double a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 1000; // 2 * R; R = 6371 km, converted to meters.
  }
}
