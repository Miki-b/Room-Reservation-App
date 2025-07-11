import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';
import 'bookings_controller.dart';

class BookingState {
  final bool isLoading;
  final String? error;
  final bool success;
  BookingState({this.isLoading = false, this.error, this.success = false});
  BookingState copyWith({bool? isLoading, String? error, bool? success}) =>
      BookingState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        success: success ?? this.success,
      );
}

final bookingControllerProvider =
    StateNotifierProvider<BookingController, BookingState>((ref) {
  final repo = BookingRepository();
  return BookingController(repo, ref);
});

class BookingController extends StateNotifier<BookingState> {
  final BookingRepository _repo;
  final Ref _ref;
  BookingController(this._repo, this._ref) : super(BookingState());

  Future<void> bookRoom({
    required String userId,
    required String hotelId,
    required String roomTypeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      // Find an available room instance for the given type and dates
      final availableRoomId =
          await _repo.findAvailableRoomInstance(roomTypeId, startDate, endDate);
      if (availableRoomId == null) {
        state = state.copyWith(
            isLoading: false,
            error: 'No available rooms of this type for the selected dates.',
            success: false);
        return;
      }
      final booking = BookingModel(
        id: '',
        userId: userId,
        roomId: availableRoomId,
        hotelId: hotelId,
        startDate: startDate,
        endDate: endDate,
        status: 'unapproved',
        createdAt: DateTime.now(),
        paymentStatus: 'unpaid',
      );
      await _repo.addBooking(booking);

      // Invalidate the booking requests provider to refresh the list
      _ref.invalidate(bookingRequestsProvider);

      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state =
          state.copyWith(isLoading: false, error: e.toString(), success: false);
    }
  }
}
