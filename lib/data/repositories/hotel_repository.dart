import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/hotel_model.dart';
import '../models/room_type_model.dart';
import '../models/room_model.dart';

class HotelRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> addRoomType(RoomType roomType, File? image) async {
    String imageUrl = '';
    if (image != null) {
      if (!await image.exists()) {
        throw Exception(
            'Room type image file does not exist: \'${image.path}\'');
      }
      final ref =
          _storage.ref().child('room_types/${image.path.split('/').last}');
      await ref.putFile(image);
      imageUrl = await ref.getDownloadURL();
    }
    final doc = await _firestore.collection('room_types').add(
          roomType.toMap()..['image'] = imageUrl,
        );
    return doc.id;
  }

  Future<List<String>> uploadHotelImages(List<File?> images) async {
    List<String> urls = [];
    for (var image in images) {
      if (image != null) {
        if (!await image.exists()) {
          throw Exception('Hotel image file does not exist: \'${image.path}\'');
        }
        final ref =
            _storage.ref().child('hotels/${image.path.split('/').last}');
        await ref.putFile(image);
        urls.add(await ref.getDownloadURL());
      }
    }
    return urls;
  }

  Future<String> addHotel(HotelModel hotel) async {
    final doc = await _firestore.collection('hotel_list').add(hotel.toMap());
    return doc.id;
  }

  Future<List<HotelModel>> fetchAllHotels() async {
    final snapshot = await _firestore.collection('hotel_list').get();
    return snapshot.docs
        .map((doc) => HotelModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<HotelModel?> fetchHotelById(String hotelId) async {
    final doc = await _firestore.collection('hotel_list').doc(hotelId).get();
    if (doc.exists) {
      return HotelModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<Room?> fetchRoomById(String roomId) async {
    final doc = await _firestore.collection('rooms').doc(roomId).get();
    if (doc.exists) {
      return Room.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<RoomType?> fetchRoomTypeById(String roomTypeId) async {
    final doc = await _firestore.collection('room_types').doc(roomTypeId).get();
    if (doc.exists) {
      return RoomType.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<String> addRoom(Room room) async {
    final doc = await _firestore.collection('rooms').add(room.toMap());
    return doc.id;
  }
}
