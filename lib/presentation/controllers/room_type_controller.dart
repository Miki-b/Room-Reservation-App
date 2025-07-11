import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/room_type_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomTypeRepository {
  Future<List<RoomType>> fetchRoomTypes(String hotelId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('room_types')
        .where('hotelId', isEqualTo: hotelId)
        .get();
    return snapshot.docs
        .map((doc) => RoomType.fromMap(doc.data(), doc.id))
        .toList();
  }
}

class RoomTypeState {
  final List<RoomType> roomTypes;
  final bool loading;
  final String? error;
  RoomTypeState({this.roomTypes = const [], this.loading = false, this.error});
  RoomTypeState copyWith({List<RoomType>? roomTypes, bool? loading, String? error}) =>
      RoomTypeState(
        roomTypes: roomTypes ?? this.roomTypes,
        loading: loading ?? this.loading,
        error: error,
      );
}

class RoomTypeController extends StateNotifier<RoomTypeState> {
  final RoomTypeRepository repo;
  RoomTypeController(this.repo) : super(RoomTypeState());

  Future<void> fetch(String hotelId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final types = await repo.fetchRoomTypes(hotelId);
      state = state.copyWith(roomTypes: types, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }
}

final roomTypeControllerProvider = StateNotifierProvider<RoomTypeController, RoomTypeState>((ref) {
  return RoomTypeController(RoomTypeRepository());
}); 