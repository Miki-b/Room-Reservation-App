import 'package:cloud_firestore/cloud_firestore.dart';

class HotelModel {
  final String id;
  final String name;
  final String location;
  final String description;
  final List<String> images;
  final List<String> amenityIds;
  final String ownerId;
  final DateTime createdAt;
  final int stars;
  final String paymentMethodId;
  final String paymentAccountNumber;
  final double latitude;
  final double longitude;

  HotelModel({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.images,
    required this.amenityIds,
    required this.ownerId,
    required this.createdAt,
    required this.stars,
    required this.paymentMethodId,
    required this.paymentAccountNumber,
    required this.latitude,
    required this.longitude,
  });

  factory HotelModel.fromMap(Map<String, dynamic> map, String id) {
    return HotelModel(
      id: id,
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      amenityIds: List<String>.from(map['amenityIds'] ?? []),
      ownerId: map['ownerId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      stars: map['stars'] ?? 4,
      paymentMethodId: map['paymentMethodId'] ?? '',
      paymentAccountNumber: map['paymentAccountNumber'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'images': images,
      'amenityIds': amenityIds,
      'ownerId': ownerId,
      'createdAt': createdAt,
      'stars': stars,
      'paymentMethodId': paymentMethodId,
      'paymentAccountNumber': paymentAccountNumber,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
