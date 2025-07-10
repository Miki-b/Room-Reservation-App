import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Hotel {
  String hotelName;
  String hotelEmail;
  List<String> roomType;
  List<int> noOfBeds;
  List<double> price;
  List<double> roomSize;
  List<int> availableRooms;
  List<String> facilities;
  GeoPoint hotelLocation;

  Hotel({
    required this.hotelName,
    required this.hotelEmail,
    required this.roomType,
    required this.noOfBeds,
    required this.price,
    required this.roomSize,
    required this.availableRooms,
    required this.facilities,
    required this.hotelLocation,
  });

  toJson() {
    return {
      'name': hotelName,
      'email': hotelEmail,
      'roomType':roomType,
      'beds':noOfBeds,
      'price':price,
      'size':roomSize,
      'roomsAvailable':availableRooms,
      'facilities':facilities,
      'location':hotelLocation
    };
  }
}