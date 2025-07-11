import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../profile/Favourites.dart';
import '../profile/Settings.dart';
import '../../../firestore.dart';
import 'homee.dart';
import '../admin/admin_screen.dart';
import '../../components/city_card.dart';
import '../../components/hotel_card.dart';
import 'package:lottie/lottie.dart';
import '../../components/app_drawer.dart';
import '../../components/hotel_card_shimmer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/home_controller.dart';
import '../../../data/models/hotel_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../components/bookings_tab_page.dart';

//Setting set=new Setting(onHotelsFetched: (List<Hotels> hotels) {  },);
class HomeScreen extends ConsumerStatefulWidget {
  HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int pageIndex = 0;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(homeControllerProvider.notifier).fetchAll());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);
    final pages = [
      HomeContent(
        nearby: state.nearbyHotels,
        allhotel: state.allHotels,
        isLoading: state.isLoading,
        searchQuery: searchQuery,
        onSearch: (q) => setState(() => searchQuery = q),
      ),
      BookingsTabPage(),
      AdminScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.yellow[10],
      appBar: AppBar(
        toolbarHeight: 100,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Consumer(builder: (context, ref, _) {
            final userAsync = ref.watch(userInfoProvider);
            return userAsync.when(
              loading: () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hey', style: Theme.of(context).textTheme.headlineSmall),
                  Text("Find your Hotel",
                      style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
              error: (err, stack) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hey', style: Theme.of(context).textTheme.headlineSmall),
                  Text("Find your Hotel",
                      style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
              data: (user) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.firstName != null && user!.firstName.isNotEmpty
                        ? 'Hey, ${user.firstName}!'
                        : 'Hey',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "Find your Hotel",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            );
          }),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.notifications, size: 30),
          )
        ],
        elevation: 2,
      ),
      drawer: const AppDrawer(),
      body: pages[pageIndex],
      bottomNavigationBar: Container(
        height: 72,
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavBarItem(
              icon: pageIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
              label: 'Home',
              selected: pageIndex == 0,
              onTap: () => setState(() => pageIndex = 0),
            ),
            _NavBarItem(
              icon: pageIndex == 1
                  ? Icons.book_online_rounded
                  : Icons.book_online_outlined,
              label: 'Bookings',
              selected: pageIndex == 1,
              onTap: () => setState(() => pageIndex = 1),
            ),
            _NavBarItem(
              icon: pageIndex == 2
                  ? Icons.settings_rounded
                  : Icons.settings_outlined,
              label: 'Settings',
              selected: pageIndex == 2,
              onTap: () => setState(() => pageIndex = 2),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent(
      {required this.nearby,
      super.key,
      required this.allhotel,
      required this.isLoading,
      required this.searchQuery,
      required this.onSearch});
  final List<HotelModel> nearby;
  final List<HotelModel> allhotel;
  final bool isLoading;
  final String searchQuery;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    final List<String> cities = [
      'Addis Ababa',
      'Bahirdar',
      'Hawasa',
      'Mekele',
      'Bishoftu',
      'Gondor',
      'DireDawa'
    ];
    final filteredHotels = searchQuery.isEmpty
        ? allhotel
        : allhotel
            .where(
                (h) => h.name.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar above banner
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/search');
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: IgnorePointer(
                  child: TextField(
                    onChanged: onSearch,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Search hotels, cities, amenities... ',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ),
            // Banner with text and Lottie
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/HotelMap', arguments: allhotel);
              },
              child: Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, 2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Center(
                          child: Text(
                            'Search by location',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Lottie.asset('assets/banner_lottie.json',
                            fit: BoxFit.contain),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text("Cities", style: Theme.of(context).textTheme.titleMedium),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: cities
                    .map((city) => CityCard(
                          city: city,
                          imageAsset: 'assets/$city.jpg',
                          onTap: () {
                            // Navigate to search page with city filter
                            Navigator.pushNamed(context, '/search',
                                arguments: city);
                          },
                        ))
                    .toList(),
              ),
            ),
            SizedBox(height: 20),
            Text("Near you", style: Theme.of(context).textTheme.titleMedium),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: isLoading
                    ? List.generate(3, (_) => const HotelCardShimmer())
                    : nearby
                        .map((hotel) => HotelCard(
                              name: hotel.name,
                              location: hotel.location.toString(),
                              stars:
                                  4, // Default or fetch from another property if available
                              imageUrl: hotel.images.isNotEmpty
                                  ? hotel.images[0]
                                  : '',
                              onTap: () {
                                Navigator.pushNamed(context, '/HotelProfile',
                                    arguments: hotel);
                              },
                            ))
                        .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavBarItem(
      {required this.icon,
      required this.label,
      required this.selected,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    final color = selected
        ? (Theme.of(context).colorScheme.secondary ??
            Theme.of(context).colorScheme.primary)
        : Colors.grey;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 30, color: color),
              SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      color: color,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }
}
