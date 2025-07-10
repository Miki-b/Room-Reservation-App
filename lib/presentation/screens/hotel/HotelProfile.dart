import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../home/HomeScreen.dart';
import 'hotels.dart';

class HotelProfile extends StatefulWidget {
  const HotelProfile({super.key});

  @override
  State<HotelProfile> createState() => _HotelProfileState();
}

class _HotelProfileState extends State<HotelProfile> {
  bool isExpanded = false;

  Widget buildStars(int rating) {
    List<Widget> stars = [];
    for (var i = 0; i < rating; i++) {
      stars.add(Icon(Icons.star, color: Colors.amber, size: 15));
    }
    return Row(
      children: stars,
    );
  }

  List<Widget> buildFacilities(List<int> facility) {
    List<Widget> facilities = [];

    for (var i = 0; i < facility.length; i++) {
      if (facility[i] == 1) {
        facilities.add(Icon(Icons.wifi, size: 32));
      } else if (facility[i] == 2) {
        facilities.add(Icon(Icons.pool, color: Colors.blue.shade700, size: 32));
      } else if (facility[i] == 3) {
        facilities.add(Icon(Icons.local_laundry_service, color: Colors.grey.shade800, size: 32));
      } else if (facility[i] == 4) {
        facilities.add(Icon(Icons.restaurant, color: Colors.yellow.shade600, size: 32));
      } else if (facility[i] == 6) {
        facilities.add(Icon(Icons.twenty_four_mp, color: Colors.blue.shade800, size: 32));
      } else if (facility[i] == 7) {
        facilities.add(Icon(Icons.local_parking, color: Colors.green.shade500, size: 32));
      } else if (facility[i] == 8) {
        facilities.add(Icon(Icons.spa, color: Colors.orangeAccent, size: 32));
      }
    }
    return facilities;
  }

  final List<int> facility = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

  @override
  Widget build(BuildContext context) {
    final Hotels args = ModalRoute.of(context)!.settings.arguments as Hotels; // Receive the hotel object
    final String hotelName = args.hotelname;
    final String hotellocation = args.location;
    final int hotelStar = args.hotelStar;
    final List<dynamic> imageUrls = args.imageUrls;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
      body: Container(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    offset: Offset(0, 4),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: imageUrls.map((url) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 150,
                              height: 150,
                              child: CachedNetworkImage(
                                imageUrl: url,
                                placeholder: (context, url) => CircularProgressIndicator(),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hotelName,
                                style: GoogleFonts.bebasNeue(fontSize: 25),
                              ),
                              Text(
                                hotellocation,
                                style: GoogleFonts.bebasNeue(fontSize: 10),
                              ),
                              buildStars(hotelStar),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Container(
                            width: 140,
                            height: 39,
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
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  'Go to Location',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: buildFacilities(facility).map((icons) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 60,
                              height: 60,
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
                                child: icons,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: args.roomType.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/Book',arguments: {
                          'All rooms':args,
                          'location':args.location,
                          'Room name':args.roomType[index],
                          'Room price':args.price[index],
                          'Room beds':args.noOfBeds[index],
                          'Room available':args.availableRooms[index],
                          'Room roomSize':args.roomSize[index],
                          'Room images':args.roomimages[index]
                        });
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
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 100,
                                  height: 90,

                                  child: CachedNetworkImage(
                                    imageUrl: args.roomimages[index], // Assuming you have roomTypeImages in Hotels
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
                                              Text(args.roomType[index], style: TextStyle(fontSize: 15)),
                                              Row(
                                                children: [
                                                  Text((args.price[index]).toString(), style: TextStyle(fontSize: 15)),
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
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(width: 150),
                                              Column(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue.shade900,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Center(
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                                        child: Text(
                                                          "Reserve",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
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
                                      Text(
                                        "Here is the detailed information about the hotel. This section expands when 'See More' is clicked.",
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isExpanded = !isExpanded;
                                        });
                                      },
                                      child: Center(
                                        child: Icon(
                                          isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
