import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addBooking(BookingModel booking) async {
    await _firestore.collection('booking_requests').add(booking.toMap());
  }

  Future<bool> isRoomAvailable(
      String roomId, DateTime start, DateTime end) async {
    final snapshot = await _firestore
        .collection('booking_requests')
        .where('roomId', isEqualTo: roomId)
        .where('status', whereNotIn: ['cancelled', 'rejected']).get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final DateTime bookedStart = (data['startDate'] as Timestamp).toDate();
      final DateTime bookedEnd = (data['endDate'] as Timestamp).toDate();
      if (!(end.isBefore(bookedStart) || start.isAfter(bookedEnd))) {
        // Overlap
        return false;
      }
    }
    return true;
  }

  Future<int> countOverlappingBookingsForRoomType(
      String roomTypeId, DateTime start, DateTime end) async {
    final snapshot = await _firestore
        .collection('booking_requests')
        .where('roomTypeId', isEqualTo: roomTypeId)
        .where('status', whereNotIn: ['cancelled', 'rejected']).get();
    int count = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final DateTime bookedStart = (data['startDate'] as Timestamp).toDate();
      final DateTime bookedEnd = (data['endDate'] as Timestamp).toDate();
      if (!(end.isBefore(bookedStart) || start.isAfter(bookedEnd))) {
        count++;
      }
    }
    return count;
  }

  Future<String?> findAvailableRoomInstance(
      String roomTypeId, DateTime start, DateTime end) async {
    // Fetch all rooms of this type
    final roomsSnapshot = await _firestore
        .collection('rooms')
        .where('roomTypeId', isEqualTo: roomTypeId)
        .where('status', isEqualTo: 'available')
        .get();
    for (var roomDoc in roomsSnapshot.docs) {
      final roomId = roomDoc.id;
      final available = await isRoomAvailable(roomId, start, end);
      if (available) {
        return roomId;
      }
    }
    return null; // No available room instance
  }

  Future<List<BookingModel>> getBookingRequests(String userId) async {
    final snapshot = await _firestore
        .collection('booking_requests')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
        .where((booking) =>
            booking.status != 'cancelled' && booking.status != 'rejected')
        .toList();
  }

  Future<List<BookingModel>> getMyBookings(String userId) async {
    final snapshot = await _firestore
        .collection('booking_requests')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'approved')
        .where('paymentStatus', isEqualTo: 'paid')
        .get();
    return snapshot.docs
        .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
