import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/hotel_model.dart';
import '../models/room_type_model.dart';

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
}
