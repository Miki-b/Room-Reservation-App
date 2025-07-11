import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String id;
  final String hotelId;
  final String roomTypeId;
  final String roomNumber;
  final String status; // e.g. 'available', 'booked', 'maintenance'
  final DateTime createdAt;

  Room({
    required this.id,
    required this.hotelId,
    required this.roomTypeId,
    required this.roomNumber,
    required this.status,
    required this.createdAt,
  });

  factory Room.fromMap(Map<String, dynamic> map, String id) {
    return Room(
      id: id,
      hotelId: map['hotelId'] ?? '',
      roomTypeId: map['roomTypeId'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      status: map['status'] ?? 'available',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hotelId': hotelId,
      'roomTypeId': roomTypeId,
      'roomNumber': roomNumber,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
