import 'package:firebase/data/models/hotel_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/hotel_repository.dart';
import '../../data/models/room_model.dart';
import '../../data/models/room_type_model.dart';
import '../components/my_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bookings/booking_card.dart';
import '../controllers/bookings_controller.dart';

class BookingsTabPage extends StatefulWidget {
  @override
  _BookingsTabPageState createState() => _BookingsTabPageState();
}

class _BookingsTabPageState extends State<BookingsTabPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Material(
          color: Theme.of(context).colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.onSurface,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            tabs: const [
              Tab(text: 'Booking Requests'),
              Tab(text: 'Bookings'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              BookingRequestsTab(),
              MyBookingsTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class BookingRequestsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingRequestsAsync = ref.watch(bookingRequestsProvider);
    return RefreshIndicator(
      onRefresh: () async {
        // Invalidate the provider to force a refresh
        ref.invalidate(bookingRequestsProvider);
      },
      child: bookingRequestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error loading booking requests',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(bookingRequestsProvider);
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
        data: (bookings) {
          if (bookings.isEmpty) {
            return ListView(
              children: [
                SizedBox(height: 100),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No booking requests found.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Pull down to refresh',
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return BookingCardLoader(booking: bookings[index]);
            },
          );
        },
      ),
    );
  }
}

class MyBookingsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myBookingsAsync = ref.watch(myBookingsProvider);
    return RefreshIndicator(
      onRefresh: () async {
        // Invalidate the provider to force a refresh
        ref.invalidate(myBookingsProvider);
      },
      child: myBookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error loading bookings',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(myBookingsProvider);
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
        data: (bookings) {
          if (bookings.isEmpty) {
            return ListView(
              children: [
                SizedBox(height: 100),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.confirmation_number,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No bookings found.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Pull down to refresh',
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return BookingCardLoader(booking: bookings[index]);
            },
          );
        },
      ),
    );
  }
}

// Loader widget to fetch hotel, room, and roomType for a booking
class BookingCardLoader extends StatelessWidget {
  final BookingModel booking;
  const BookingCardLoader({required this.booking, super.key});

  @override
  Widget build(BuildContext context) {
    final hotelRepo = HotelRepository();
    return FutureBuilder(
      future: Future.wait([
        hotelRepo.fetchHotelById(booking.hotelId),
        hotelRepo.fetchRoomById(booking.roomId),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: const ListTile(
              title: Text('Error loading booking details'),
              subtitle: Text('Please try again later'),
            ),
          );
        }
        final hotel = snapshot.data![0] as HotelModel?;
        final room = snapshot.data![1] as Room?;
        return FutureBuilder(
          future: room != null
              ? hotelRepo.fetchRoomTypeById(room.roomTypeId)
              : null,
          builder: (context, AsyncSnapshot<RoomType?> roomTypeSnap) {
            final roomType = roomTypeSnap.data;
            return BookingCard(
              booking: booking,
              hotel: hotel,
              room: room,
              roomType: roomType,
            );
          },
        );
      },
    );
  }
}
