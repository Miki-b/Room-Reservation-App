import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/hotel_model.dart';

class HotelRepository {
  Future<List<HotelModel>> fetchAllHotels() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('hotel_list').get();
    return snapshot.docs
        .map((doc) => HotelModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<HotelModel>> fetchNearbyHotels() async {
    // Placeholder: implement actual geolocation-based query if needed
    final snapshot = await FirebaseFirestore.instance
        .collection('hotel_list')
        .limit(5)
        .get();
    return snapshot.docs
        .map((doc) => HotelModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
