import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../home/HomeScreen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/booking_cart_controller.dart';
import '../../components/room_type_card.dart';
import '../hotel/HotelProfile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/booking_controller.dart';

class Book extends ConsumerWidget {
  const Book({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(bookingCartProvider);
    double calculateTotalPrice() {
      double total = 0;
      for (var cartRoom in cart) {
        total += cartRoom.room.price;
      }
      return total;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Room Booking', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.favorite_border),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.share),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cart.length,
                itemBuilder: (context, index) {
                  final cartRoom = cart[index];
                  final room = cartRoom.room;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        ListTile(
                          leading: room.image.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: room.image,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : null,
                          title: Text(room.name),
                          subtitle:
                              Text('ETB ${room.price.toStringAsFixed(2)}'),
                          trailing: IconButton(
                            icon: Icon(Icons.remove_circle_outline,
                                color: Colors.red),
                            onPressed: () {
                              ref
                                  .read(bookingCartProvider.notifier)
                                  .remove(cartRoom);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Text("Check-in: "),
                                TextButton(
                                  onPressed: () async {
                                    final now = DateTime.now();
                                    final initialDate =
                                        cartRoom.checkInDate.isBefore(now)
                                            ? now
                                            : cartRoom.checkInDate;
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: initialDate,
                                      firstDate: now,
                                      lastDate: now.add(Duration(days: 365)),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              onPrimary: Colors.white,
                                              onSurface: Colors.black,
                                              secondary: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                            ),
                                            textButtonTheme:
                                                TextButtonThemeData(
                                              style: TextButton.styleFrom(
                                                foregroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                              ),
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null) {
                                      ref
                                          .read(bookingCartProvider.notifier)
                                          .updateCheckInDate(cartRoom, picked);
                                    }
                                  },
                                  child: Text(
                                    DateFormat('yyyy-MM-dd')
                                        .format(cartRoom.checkInDate),
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Text("Check-out: "),
                                TextButton(
                                  onPressed: () async {
                                    final minCheckOut = cartRoom.checkInDate
                                        .add(Duration(days: 1));
                                    final initialDate = cartRoom.checkOutDate
                                            .isAfter(minCheckOut)
                                        ? cartRoom.checkOutDate
                                        : minCheckOut;
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: initialDate,
                                      firstDate: minCheckOut,
                                      lastDate: DateTime.now()
                                          .add(Duration(days: 366)),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              onPrimary: Colors.white,
                                              onSurface: Colors.black,
                                              secondary: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                            ),
                                            textButtonTheme:
                                                TextButtonThemeData(
                                              style: TextButton.styleFrom(
                                                foregroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                              ),
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null) {
                                      ref
                                          .read(bookingCartProvider.notifier)
                                          .updateCheckOutDate(cartRoom, picked);
                                    }
                                  },
                                  child: Text(
                                    DateFormat('yyyy-MM-dd')
                                        .format(cartRoom.checkOutDate),
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    offset: Offset(0, 1),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Price"),
                        Text('ETB ${calculateTotalPrice().toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: cart.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(15.0),
              child: Consumer(
                builder: (context, ref, _) => ElevatedButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('You must be logged in to book.')),
                      );
                      return;
                    }
                    final bookingController =
                        ref.read(bookingControllerProvider.notifier);
                    String? errorMessage;
                    for (var cartRoom in cart) {
                      try {
                        await bookingController.bookRoom(
                          userId: user.uid,
                          hotelId: cartRoom.room.hotelId,
                          roomTypeId: cartRoom.room.id,
                          startDate: cartRoom.checkInDate,
                          endDate: cartRoom.checkOutDate,
                        );
                      } catch (e) {
                        errorMessage = e.toString();
                        break;
                      }
                    }
                    final state = ref.read(bookingControllerProvider);
                    String? errorToShow =
                        errorMessage; // from exception, if any

                    // If no exception, but booking failed, check state for error
                    if (errorToShow == null &&
                        !state.success &&
                        state.error != null) {
                      errorToShow = state.error;
                    }

                    if (errorToShow == null && state.success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Booking request sent! Await approval.')),
                      );
                      // Optionally clear cart or navigate
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Booking failed: ${errorToShow ?? "Please try again."}')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Book (${cart.length})'),
                ),
              ),
            )
          : null,
    );
  }
}

class RoomsCard extends StatefulWidget {
  RoomsCard(
      {super.key,
      required this.roomsTypes,
      required this.multipleRooms,
      required this.removeRoom});
  RoomsTypes roomsTypes;
  List<RoomsTypes> multipleRooms;
  final Function(int) removeRoom;

  @override
  State<RoomsCard> createState() => _RoomsCardState();
}

class _RoomsCardState extends State<RoomsCard> {
  @override
  void initState() {
    super.initState();
    widget.multipleRooms.add(widget.roomsTypes);
  }

  Widget buildStars(int rating) {
    List<Widget> stars = [];
    for (var i = 0; i < rating; i++) {
      stars.add(Icon(Icons.star, color: Colors.amber, size: 15));
    }
    return Row(
      children: stars,
    );
  }

  Future<void> _selectDate(
      BuildContext context, bool isCheckIn, int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn
          ? widget.multipleRooms[index].checkInDate
          : widget.multipleRooms[index].checkOutDate,
      firstDate: DateTime(2022), // Updated to include more years
      lastDate: DateTime(2025), // Updated to extend the range
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn &&
            picked.isBefore(widget.multipleRooms[index].checkOutDate)) {
          widget.multipleRooms[index].checkInDate = picked;
        } else if (!isCheckIn &&
            picked.isAfter(widget.multipleRooms[index].checkInDate)) {
          widget.multipleRooms[index].checkOutDate = picked;
        } else {
          // Show an error message or handle invalid date selection
          print("Invalid date selection");
        }
      });
    }
  }

  String formatDate(DateTime date) {
    String suffix;
    int day = date.day;

    if (day >= 11 && day <= 13) {
      suffix = 'th';
    } else {
      switch (day % 10) {
        case 1:
          suffix = 'st';
          break;
        case 2:
          suffix = 'nd';
          break;
        case 3:
          suffix = 'rd';
          break;
        default:
          suffix = 'th';
      }
    }

    String month = DateFormat('MMMM').format(date);
    return '$day$suffix $month, ${date.year}';
  }

  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        itemCount: widget.multipleRooms.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    offset: Offset(0, 1),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 90,
                        child: Container(
                          width: 150,
                          height: 150,
                          child: CachedNetworkImage(
                            imageUrl: widget.multipleRooms[index].roomimages,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        widget.multipleRooms[index].roomName ??
                                            'Room Name',
                                        style: GoogleFonts.bebasNeue(
                                            fontSize: 25)),
                                    GestureDetector(
                                      onTap: () => widget.removeRoom(index),
                                      child: Icon(Icons.cancel_outlined,
                                          color: Colors.red.shade300),
                                    ),
                                  ],
                                ),
                                Text(
                                    widget.multipleRooms[index].location ??
                                        'Location',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey)),
                                Text(
                                    'Room Price: ${widget.multipleRooms[index].roomPrice} per night',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey)),
                                SizedBox(height: 15),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isExpanded)
                            Column(
                              children: [
                                Text(
                                    'Number of Beds: ${widget.multipleRooms[index].roomBeds}',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey)),
                                Text(
                                    'Available Rooms: ${widget.multipleRooms[index].roomAvailable}',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey)),
                                Text(
                                    'Room Size: ${widget.multipleRooms[index].roomSize}',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpanded = !isExpanded;
                              });
                            },
                            child: Center(
                              child: Icon(isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Check in",
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold)),
                            GestureDetector(
                              onTap: () {
                                _selectDate(context, true, index);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                    formatDate(widget
                                        .multipleRooms[index].checkInDate),
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Check out",
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold)),
                            GestureDetector(
                              onTap: () {
                                _selectDate(context, false, index);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                    formatDate(widget
                                        .multipleRooms[index].checkOutDate),
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class RoomsTypes {
  RoomsTypes(
      {required this.location,
      required this.roomSize,
      required this.roomAvailable,
      required this.roomBeds,
      required this.roomName,
      required this.roomPrice,
      required this.roomimages})
      : checkInDate = DateTime.now(),
        checkOutDate =
            DateTime.now().add(Duration(days: 1)); // Initializing dates

  String? location;
  String? roomName;
  String? roomPrice;
  String? roomBeds;
  String? roomAvailable;
  String? roomSize;
  dynamic roomimages;
  DateTime checkInDate;
  DateTime checkOutDate;
}
