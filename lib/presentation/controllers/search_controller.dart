import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/hotel_model.dart';
import '../../data/repositories/hotel_repository.dart';
import '../../data/models/city_model.dart';
import '../../data/models/amenity_model.dart';

class SearchState {
  final List<HotelModel> hotels;
  final List<HotelModel> results;
  final bool isLoading;
  final String? error;
  final String query;
  final String? selectedCity;
  final Set<String> selectedAmenities;
  SearchState({
    this.hotels = const [],
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.query = '',
    this.selectedCity,
    this.selectedAmenities = const {},
  });
  SearchState copyWith({
    List<HotelModel>? hotels,
    List<HotelModel>? results,
    bool? isLoading,
    String? error,
    String? query,
    String? selectedCity,
    Set<String>? selectedAmenities,
  }) =>
      SearchState(
        hotels: hotels ?? this.hotels,
        results: results ?? this.results,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        query: query ?? this.query,
        selectedCity: selectedCity ?? this.selectedCity,
        selectedAmenities: selectedAmenities ?? this.selectedAmenities,
      );
}

final searchControllerProvider =
    StateNotifierProvider<SearchController, SearchState>((ref) {
  final repo = HotelRepository();
  return SearchController(repo);
});

class SearchController extends StateNotifier<SearchState> {
  final HotelRepository _repo;
  SearchController(this._repo) : super(SearchState()) {
    fetchHotels();
  }

  // Example: hardcoded cities and amenities (replace with fetch if needed)
  final List<String> availableCities = [
    'Addis Ababa',
    'Bahirdar',
    'Hawasa',
    'Mekele',
    'Bishoftu',
    'Gondor',
    'DireDawa'
  ];
  final List<String> availableAmenities = [
    'WiFi',
    '24-hour reception',
    'Swimming pool',
    'Breakfast offered'
  ];

  Future<void> fetchHotels() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final hotels = await _repo.fetchAllHotels();
      state = state.copyWith(hotels: hotels, results: hotels, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void search(String query) {
    state = state.copyWith(query: query);
    _filter();
  }

  void setCity(String? city) {
    state = state.copyWith(selectedCity: city);
    _filter();
  }

  void toggleAmenity(String amenity) {
    final newSet = Set<String>.from(state.selectedAmenities);
    if (newSet.contains(amenity)) {
      newSet.remove(amenity);
    } else {
      newSet.add(amenity);
    }
    state = state.copyWith(selectedAmenities: newSet);
    _filter();
  }

  void _filter() {
    final q = state.query.trim().toLowerCase();
    List<HotelModel> filtered = state.hotels;

    // Apply text search filter
    if (q.isNotEmpty) {
      filtered = filtered
          .where((h) =>
              h.name.toLowerCase().contains(q) ||
              h.location.toLowerCase().contains(q) ||
              h.description.toLowerCase().contains(q) ||
              h.amenityIds.any((a) => a.toLowerCase().contains(q)))
          .toList();
    }

    // Apply city filter (only if no text search is active or if city is explicitly selected)
    if (state.selectedCity != null && state.selectedCity!.isNotEmpty) {
      final cityLower = state.selectedCity!.toLowerCase();
      filtered = filtered.where((h) {
        final locationLower = h.location.toLowerCase();
        // Check if the city name appears in the location
        return locationLower.contains(cityLower) ||
            locationLower.contains('${cityLower},') ||
            locationLower.contains('${cityLower} ') ||
            locationLower.endsWith(cityLower);
      }).toList();
    }

    // Apply amenities filter
    if (state.selectedAmenities.isNotEmpty) {
      filtered = filtered
          .where((h) =>
              state.selectedAmenities.every((a) => h.amenityIds.contains(a)))
          .toList();
    }

    state = state.copyWith(results: filtered);
  }
}
