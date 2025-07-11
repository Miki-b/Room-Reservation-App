import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';

final bookingRequestsProvider =
    AsyncNotifierProvider<BookingRequestsNotifier, List<BookingModel>>(
        BookingRequestsNotifier.new);

final myBookingsProvider =
    AsyncNotifierProvider<MyBookingsNotifier, List<BookingModel>>(
        MyBookingsNotifier.new);

class BookingRequestsNotifier extends AsyncNotifier<List<BookingModel>> {
  @override
  Future<List<BookingModel>> build() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    return await BookingRepository().getBookingRequests(user.uid);
  }
}

class MyBookingsNotifier extends AsyncNotifier<List<BookingModel>> {
  @override
  Future<List<BookingModel>> build() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    return await BookingRepository().getMyBookings(user.uid);
  }
}
