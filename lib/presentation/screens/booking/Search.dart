import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/my_textfield.dart';
import '../../components/hotel_card.dart';
import '../../components/hotel_card_shimmer.dart';
import '../../components/search_hotel_card.dart';
import '../../components/search_filter_drawer.dart';
import '../../controllers/search_controller.dart';

class Search extends ConsumerStatefulWidget {
  const Search({super.key});
  @override
  ConsumerState<Search> createState() => _SearchState();
}

class _SearchState extends ConsumerState<Search> {
  final _searchController = TextEditingController();
  final List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    // Check if we received a city argument and set it as the search query
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        // If it's a city name, set it as the search query and filter
        _searchController.text = args;
        ref.read(searchControllerProvider.notifier).search(args);
        ref.read(searchControllerProvider.notifier).setCity(args);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchControllerProvider);
    final notifier = ref.read(searchControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Hotels'),
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unified search field with button
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: MyTextfield(
                      labelText: 'Search by hotel, city, or amenity',
                      controller: _searchController,
                      onChanged: (q) {
                        // Clear results when user starts typing
                        if (q.isEmpty) {
                          ref
                              .read(searchControllerProvider.notifier)
                              .search('');
                          ref
                              .read(searchControllerProvider.notifier)
                              .setCity(null);
                        }
                      },
                      prefixIcon: Icon(Icons.search,
                          color: Theme.of(context).colorScheme.secondary),
                      // Suffix icon as search button
                      suffixIcon: IconButton(
                        icon: Icon(Icons.arrow_forward,
                            color: Theme.of(context).colorScheme.secondary),
                        onPressed: () {
                          final searchQuery = _searchController.text.trim();
                          if (searchQuery.isNotEmpty) {
                            // Clear city filter when doing a text search
                            ref
                                .read(searchControllerProvider.notifier)
                                .setCity(null);
                            ref
                                .read(searchControllerProvider.notifier)
                                .search(searchQuery);
                            if (!_recentSearches.contains(searchQuery)) {
                              setState(
                                  () => _recentSearches.insert(0, searchQuery));
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: Icon(Icons.filter_list,
                        color: Theme.of(context).colorScheme.secondary),
                    label: Text('Filter',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onPressed: () async {
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) => SearchFilterDrawer(
                          cities: ref
                              .read(searchControllerProvider.notifier)
                              .availableCities,
                          selectedCity: state.selectedCity,
                          amenities: ref
                              .read(searchControllerProvider.notifier)
                              .availableAmenities,
                          selectedAmenities: state.selectedAmenities,
                          onCitySelected: (city) {
                            ref
                                .read(searchControllerProvider.notifier)
                                .setCity(city);
                          },
                          onAmenityToggled: (amenity) {
                            ref
                                .read(searchControllerProvider.notifier)
                                .toggleAmenity(amenity);
                          },
                          onClear: () {
                            ref
                                .read(searchControllerProvider.notifier)
                                .setCity(null);
                            for (final a in state.selectedAmenities) {
                              ref
                                  .read(searchControllerProvider.notifier)
                                  .toggleAmenity(a);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            if (_recentSearches.isNotEmpty && state.query.isEmpty)
              Wrap(
                spacing: 8,
                children: _recentSearches
                    .map((q) => ActionChip(
                          label: Text(q),
                          onPressed: () {
                            _searchController.text = q;
                            ref
                                .read(searchControllerProvider.notifier)
                                .setCity(null);
                            notifier.search(q);
                          },
                        ))
                    .toList(),
              ),
            SizedBox(height: 12),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (state.isLoading) {
                    return ListView.builder(
                      itemCount: 5,
                      itemBuilder: (_, i) => const HotelCardShimmer(),
                    );
                  }
                  if (state.error != null) {
                    return Center(child: Text('Error: ${state.error}'));
                  }
                  if (state.results.isEmpty) {
                    return Center(
                      child: Text(
                        'No hotels found.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: state.results.length,
                    itemBuilder: (context, i) {
                      final hotel = state.results[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: SearchHotelCard(
                          name: hotel.name,
                          location: hotel.location,
                          stars: hotel.amenityIds
                              .length, // Replace with hotel class if available
                          images: hotel.images,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/HotelProfile',
                              arguments: hotel,
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
