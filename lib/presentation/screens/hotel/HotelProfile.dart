import 'package:firebase/data/models/hotel_model.dart';
import 'package:firebase/data/models/room_type_model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../components/room_type_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/booking_cart_controller.dart';
import '../../controllers/room_type_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'hotel_map_screen.dart';

class HotelProfile extends ConsumerStatefulWidget {
  const HotelProfile({super.key});

  @override
  ConsumerState<HotelProfile> createState() => _HotelProfileState();
}

class _HotelProfileState extends ConsumerState<HotelProfile> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final HotelModel hotel =
        ModalRoute.of(context)!.settings.arguments as HotelModel;
    Future.microtask(() {
      final controller = ref.read(roomTypeControllerProvider.notifier);
      controller.fetch(hotel.id);
    });
  }

  Widget buildStars(int count) {
    return Row(
      children: List.generate(
          count, (i) => Icon(Icons.star, color: Colors.amber, size: 18)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final HotelModel hotel =
        ModalRoute.of(context)!.settings.arguments as HotelModel;
    final roomTypeState = ref.watch(roomTypeControllerProvider);
    print(
        'HotelProfile: Room types fetched: ${roomTypeState.roomTypes.map((r) => r.name).toList()}');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final cart = ref.watch(bookingCartProvider);
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.shopping_cart_outlined),
                    onPressed: () {
                      Navigator.pushNamed(context, '/book');
                    },
                  ),
                  if (cart.isNotEmpty)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cart.length}',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(icon: Icon(Icons.favorite_border), onPressed: () {}),
          IconButton(icon: Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          // Image carousel
          Container(
            height: 220,
            child: PageView.builder(
              itemCount: hotel.images.length,
              itemBuilder: (context, i) => CachedNetworkImage(
                imageUrl: hotel.images[i],
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) =>
                    Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hotel.name,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          buildStars(hotel.stars),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 16,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                              SizedBox(width: 4),
                              Text(hotel.location,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HotelMapScreen(
                              latitude: hotel.latitude,
                              longitude: hotel.longitude,
                              hotelName: hotel.name,
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.map),
                      label: Text('Location'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(hotel.description,
                    style: Theme.of(context).textTheme.bodyMedium),
                SizedBox(height: 16),
                Text('Amenities',
                    style: Theme.of(context).textTheme.titleMedium),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: hotel.amenityIds
                        .map((a) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Chip(
                                avatar: Icon(_amenityIcon(a),
                                    size: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                                label: Text(a),
                                backgroundColor: Colors.grey[100],
                              ),
                            ))
                        .toList(),
                  ),
                ),
                SizedBox(height: 24),
                Text('Room Types',
                    style: Theme.of(context).textTheme.titleMedium),
                if (roomTypeState.loading)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (roomTypeState.error != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error: ${roomTypeState.error}'),
                  )
                else if (roomTypeState.roomTypes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('No room types found.'),
                  )
                else
                  Column(
                    children: roomTypeState.roomTypes
                        .map((room) => RoomTypeCard(
                              room: room,
                              onAdd: (room) {
                                ref
                                    .read(bookingCartProvider.notifier)
                                    .add(room);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Added to booking cart')),
                                );
                              },
                            ))
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData? _amenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case '24-hour reception':
        return Icons.access_time;
      case 'swimming pool':
        return Icons.pool;
      case 'breakfast offered':
        return Icons.free_breakfast;
      default:
        return Icons.check_circle_outline;
    }
  }
}
