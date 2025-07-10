import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../home/HomeScreen.dart';

class Book extends StatefulWidget {
  const Book({Key? key}) : super(key: key);

  @override
  State<Book> createState() => _BookState();
}

class _BookState extends State<Book> {
  late Hotels? allRooms;
  late String? location;
  late String? roomName;
  late String? roomPrice;
  late String? roomBeds;
  late String? roomAvailable;
  late String? roomSize;
  late dynamic roomImages;
  final List<RoomsTypes> multipleRooms = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      setState(() {
        allRooms = args['All rooms'];
        location = args['location'];
        roomName = args['Room name'];
        roomPrice = args['Room price'].toString();
        roomBeds = args['Room beds'].toString();
        roomAvailable = args['Room available'].toString();
        roomSize = args['Room roomSize'].toString();
        roomImages= args['Room images'];
      });
    });
  }

  void addRoom(RoomsTypes room) {
    setState(() {
      multipleRooms.add(room);
    });
  }

  void removeRoom(int index) {
    setState(() {
      multipleRooms.removeAt(index);
    });
  }

  double calculateTotalPrice() {
    double total = 0;
    for (var room in multipleRooms) {
      total += double.tryParse(room.roomPrice ?? '0') ?? 0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(roomName ?? 'Room Booking', style: TextStyle(color: Colors.black)),
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
              child: RoomsCard(
                roomsTypes: RoomsTypes(
                  location: location,
                  roomSize: roomSize,
                  roomAvailable: roomAvailable,
                  roomBeds: roomBeds,
                  roomName: roomName,
                  roomPrice: roomPrice,
                  roomimages: roomImages,
                ),
                multipleRooms: multipleRooms,
                removeRoom: removeRoom,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return SizedBox(
                        height: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Select Room types"),
                            Expanded(
                              child: ListView.builder(
                                itemCount: allRooms!.roomType.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      addRoom(RoomsTypes(
                                        location: allRooms!.location,
                                        roomName: allRooms!.roomType[index],
                                        roomPrice: allRooms!.price[index].toString(),
                                        roomBeds: allRooms!.noOfBeds[index].toString(),
                                        roomAvailable: allRooms!.availableRooms[index].toString(),
                                        roomSize: allRooms!.roomSize[index].toString(),
                                        roomimages: roomImages,
                                      ));
                                      Navigator.pop(context); // Close the bottom sheet after selection
                                    },
                                    child: Container(
                                      width: double.infinity,
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
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 100,
                                            height: 90,
                                            child: CachedNetworkImage(
                                               imageUrl: allRooms!.roomimages[index], // Assuming you have roomTypeImages in Hotels

                                              placeholder: (context, url) => CircularProgressIndicator(),
                                              errorWidget: (context, url, error) => Icon(Icons.error),
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
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(allRooms!.roomType[index], style: TextStyle(fontSize: 15)),
                                                        Row(
                                                          children: [
                                                            Text((allRooms!.price[index]).toString(), style: TextStyle(fontSize: 15)),
                                                            Text("/night", style: TextStyle(fontSize: 13, color: Colors.grey)),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      "Max Guests: adults , child",
                                                      style: TextStyle(color: Colors.grey, fontSize: 13),
                                                    ),
                                                    SizedBox(height: 15),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        offset: Offset(0, 1),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text('Add rooms'),
                  ),
                ),
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
                        Text('\$${calculateTotalPrice().toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15.0),
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/pay');
          },
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  offset: Offset(0, 1),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Book Now',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RoomsCard extends StatefulWidget {
  RoomsCard({super.key, required this.roomsTypes, required this.multipleRooms, required this.removeRoom});
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

  Future<void> _selectDate(BuildContext context, bool isCheckIn, int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? widget.multipleRooms[index].checkInDate : widget.multipleRooms[index].checkOutDate,
      firstDate: DateTime(2022), // Updated to include more years
      lastDate: DateTime(2025),  // Updated to extend the range
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn && picked.isBefore(widget.multipleRooms[index].checkOutDate)) {
          widget.multipleRooms[index].checkInDate = picked;
        } else if (!isCheckIn && picked.isAfter(widget.multipleRooms[index].checkInDate)) {
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
                            placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Icon(Icons.error),
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(widget.multipleRooms[index].roomName ?? 'Room Name', style: GoogleFonts.bebasNeue(fontSize: 25)),
                                    GestureDetector(
                                      onTap: () => widget.removeRoom(index),
                                      child: Icon(Icons.cancel_outlined, color: Colors.red.shade300),
                                    ),
                                  ],
                                ),
                                Text(widget.multipleRooms[index].location ?? 'Location', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                Text('Room Price: ${widget.multipleRooms[index].roomPrice} per night', style: TextStyle(fontSize: 10, color: Colors.grey)),
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
                                Text('Number of Beds: ${widget.multipleRooms[index].roomBeds}', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                Text('Available Rooms: ${widget.multipleRooms[index].roomAvailable}', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                Text('Room Size: ${widget.multipleRooms[index].roomSize}', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpanded = !isExpanded;
                              });
                            },
                            child: Center(
                              child: Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded),
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
                            Text("Check in", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                            GestureDetector(
                              onTap: () {
                                _selectDate(context, true, index);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(formatDate(widget.multipleRooms[index].checkInDate), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Check out", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                            GestureDetector(
                              onTap: () {
                                _selectDate(context, false, index);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(formatDate(widget.multipleRooms[index].checkOutDate), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
  RoomsTypes({
    required this.location,
    required this.roomSize,
    required this.roomAvailable,
    required this.roomBeds,
    required this.roomName,
    required this.roomPrice,
    required this.roomimages
  }) : checkInDate = DateTime.now(),
        checkOutDate = DateTime.now().add(Duration(days: 1)); // Initializing dates

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
