import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/room_type_model.dart';

class CartRoom {
  final RoomType room;
  DateTime checkInDate;
  DateTime checkOutDate;
  CartRoom({
    required this.room,
    required this.checkInDate,
    required this.checkOutDate,
  });
}

class BookingCartController extends StateNotifier<List<CartRoom>> {
  BookingCartController() : super([]);
  void add(RoomType room, {DateTime? checkIn, DateTime? checkOut}) {
    final now = DateTime.now();
    state = [
      ...state,
      CartRoom(
        room: room,
        checkInDate: checkIn ?? now,
        checkOutDate: checkOut ?? now.add(Duration(days: 1)),
      ),
    ];
  }

  void remove(CartRoom cartRoom) {
    state = state.where((r) => r.room.id != cartRoom.room.id).toList();
  }

  void clear() {
    state = [];
  }

  void updateCheckInDate(CartRoom cartRoom, DateTime newDate) {
    state = [
      for (final r in state)
        if (r.room.id == cartRoom.room.id)
          CartRoom(
              room: r.room, checkInDate: newDate, checkOutDate: r.checkOutDate)
        else
          r
    ];
  }

  void updateCheckOutDate(CartRoom cartRoom, DateTime newDate) {
    state = [
      for (final r in state)
        if (r.room.id == cartRoom.room.id)
          CartRoom(
              room: r.room, checkInDate: r.checkInDate, checkOutDate: newDate)
        else
          r
    ];
  }
}

final bookingCartProvider =
    StateNotifierProvider<BookingCartController, List<CartRoom>>(
        (ref) => BookingCartController());
