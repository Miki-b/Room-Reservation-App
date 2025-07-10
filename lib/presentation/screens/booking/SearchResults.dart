import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../home/HomeScreen.dart';
import '../hotel/hotels.dart';

class SearchResults extends StatefulWidget {
  final Hotels hotel;

  SearchResults({required this.hotel, Key? key}) : super(key: key);

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  Widget buildStars(int rating) {
    List<Widget> stars = [];
    for (var i = 0; i < rating; i++) {
      stars.add(Icon(Icons.star, color: Colors.amber, size: 15));
    }
    return Row(
      children: stars,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: GestureDetector(
        onTap: () {
          print(widget.hotel);
          Navigator.pushNamed(
            context,
            '/HotelProfile',
            arguments: widget.hotel,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Container(
                      height: 108,
                      width: 260,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(widget.hotel.imageUrls[0]),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                          child: Container(
                            height: 50,
                            width: 100,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(widget.hotel.imageUrls[1]),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 0.0),
                          child: Container(
                            height: 50,
                            width: 100,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(widget.hotel.imageUrls[2]),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.hotel.hotelname,
                      style: GoogleFonts.bebasNeue(
                        fontSize: 25,
                      ),
                    ),
                    Text(
                      widget.hotel.location,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                    buildStars(widget.hotel.hotelStar),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
