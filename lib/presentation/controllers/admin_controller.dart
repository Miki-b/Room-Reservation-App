import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/hotel_model.dart';
import '../../data/models/room_type_model.dart';
import '../../data/repositories/hotel_repository.dart';

class AdminState {
  final bool isLoading;
  final String? error;
  final bool success;
  AdminState({this.isLoading = false, this.error, this.success = false});
  AdminState copyWith({bool? isLoading, String? error, bool? success}) =>
      AdminState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        success: success ?? this.success,
      );
}

final adminControllerProvider =
    StateNotifierProvider<AdminController, AdminState>((ref) {
  final repo = HotelRepository();
  return AdminController(repo);
});

class AdminController extends StateNotifier<AdminState> {
  final HotelRepository _repo;
  AdminController(this._repo) : super(AdminState());

  Future<void> submitHotel({
    required String hotelName,
    required String hotelEmail,
    required List<String> facilities,
    required List<String> roomTypes,
    required List<double> prices,
    required List<File?> hotelImages,
    required List<File?> roomImages,
    required String location,
    required String description,
    required List<String> roomTypeDescriptions,
  }) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      // 1. Upload hotel images
      final hotelImageUrls = await _repo.uploadHotelImages(hotelImages);
      // 2. Create hotel
      final hotel = HotelModel(
        id: '',
        name: hotelName,
        location: location,
        description: description,
        images: hotelImageUrls,
        amenityIds: facilities,
        ownerId: '', // Set this from FirebaseAuth if needed
        createdAt: DateTime.now(),
      );
      final hotelId = await _repo.addHotel(hotel);
      // 3. Create room types (groups)
      for (int i = 0; i < roomTypes.length; i++) {
        final roomType = RoomType(
          id: '',
          hotelId: hotelId,
          name: roomTypes[i],
          description: roomTypeDescriptions[i],
          image: '', // Will be set after upload
          count: 1, // Default to 1 per type
          price: prices[i],
          amenityIds: facilities,
          images: [], // Add room images if needed
          createdAt: DateTime.now(),
        );
        await _repo.addRoomType(roomType, roomImages[i]);
      }
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state =
          state.copyWith(isLoading: false, error: e.toString(), success: false);
    }
  }
}
