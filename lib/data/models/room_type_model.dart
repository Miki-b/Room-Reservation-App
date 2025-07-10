import 'package:cloud_firestore/cloud_firestore.dart';

class RoomType {
  final String id;
  final String hotelId;
  final String name;
  final String description;
  final String image;
  final int count; // Number of rooms of this type in this hotel
  final double price;
  final List<String> amenityIds;
  final List<String> images;
  final DateTime createdAt;

  RoomType({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.description,
    required this.image,
    required this.count,
    required this.price,
    required this.amenityIds,
    required this.images,
    required this.createdAt,
  });

  factory RoomType.fromMap(Map<String, dynamic> map, String id) {
    return RoomType(
      id: id,
      hotelId: map['hotelId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      image: map['image'] ?? '',
      count: map['count'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      amenityIds: List<String>.from(map['amenityIds'] ?? []),
      images: List<String>.from(map['images'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hotelId': hotelId,
      'name': name,
      'description': description,
      'image': image,
      'count': count,
      'price': price,
      'amenityIds': amenityIds,
      'images': images,
      'createdAt': createdAt,
    };
  }
}
