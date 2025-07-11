import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/hotel_model.dart';
import 'hotel_repository.dart';

class HomeState {
  final List<HotelModel> allHotels;
  final List<HotelModel> nearbyHotels;
  final bool isLoading;
  final String? error;
  HomeState({
    this.allHotels = const [],
    this.nearbyHotels = const [],
    this.isLoading = false,
    this.error,
  });
  HomeState copyWith({
    List<HotelModel>? allHotels,
    List<HotelModel>? nearbyHotels,
    bool? isLoading,
    String? error,
  }) =>
      HomeState(
        allHotels: allHotels ?? this.allHotels,
        nearbyHotels: nearbyHotels ?? this.nearbyHotels,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class HomeController extends StateNotifier<HomeState> {
  final HotelRepository repo;
  HomeController(this.repo) : super(HomeState());

  Future<void> fetchAll() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final all = await repo.fetchAllHotels();
      final nearby = await repo.fetchNearbyHotels();
      state = state.copyWith(
          allHotels: all, nearbyHotels: nearby, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final homeControllerProvider =
    StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController(HotelRepository());
});
