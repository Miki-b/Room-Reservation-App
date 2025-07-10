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
//Setting set=new Setting(onHotelsFetched: (List<Hotels> hotels) {  },);
class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Hotels> allHotels = [];
  List<Hotels> searchedHotel =[];
  int pageIndex = 0;
  List<Hotels> nearbyHotels = [];

  @override
  void initState() {
    super.initState();
    fetchNearbyHotels();
    AllHotels();
    searchedHotel=[];
  }

  Future<void> AllHotels() async {
    List<Hotels> hotels = await FirestoreService.allHotels();
    setState(() {
      allHotels = hotels;
    });
  }
  Future<void> fetchNearbyHotels() async {
    List<Hotels> hotels = await FirestoreService.fetchNearbyHotels();
    setState(() {
      nearbyHotels = hotels;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeContent(nearby: nearbyHotels, allhotel: allHotels,),
      Favourites(),
      Setting(
        onHotelsFetched: (List<Hotels> hotels) {
          setState(() {
            nearbyHotels = hotels;
          });
        },
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.yellow[10],
      appBar: AppBar(
        toolbarHeight: 100,
        title: Row(
          children: [
            Icon(Icons.menu, size: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hey',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 30,
                    ),
                  ),
                  Text(
                    "Find your Hotel",
                    style: GoogleFonts.bebasNeue(
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.notifications, size: 30),
          )
        ],
        elevation: 2,
      ),
      body: pages[pageIndex],
      bottomNavigationBar: Container(
        height: 72,
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    pageIndex = 0;
                  });
                },
                icon: pageIndex == 0
                    ? const Icon(
                  Icons.home,
                  size: 25,
                )
                    : const Icon(
                  Icons.home_outlined,
                  size: 25,
                ),
              ),
              Text('Home',style: TextStyle(fontSize: 15),)
            ]),
            Column(children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    pageIndex = 1;
                  });
                },
                icon: pageIndex == 1
                    ? const Icon(
                  Icons.favorite,
                  size: 25,
                )
                    : const Icon(
                  Icons.favorite_border,
                  size: 25,
                ),
              ),
              Text('Favourites',style: TextStyle(fontSize: 15),)
            ]),
            Column(children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    pageIndex = 2;
                  });
                },
                icon: pageIndex == 2
                    ? const Icon(
                  Icons.settings,
                  size: 25,
                )
                    : const Icon(
                  Icons.settings_outlined,
                  size: 25,
                ),
              ),
              Text('Settings',style: TextStyle(fontSize: 15),)
            ]),
          ],
        ),
      ),
    );
  }
}
class HomeContent extends StatelessWidget {

  const HomeContent({required this.nearby, super.key, required this.allhotel});
  final List<Hotels> nearby;
  final List<Hotels> allhotel;

  //final List<String> cities;

  @override
  Widget build(BuildContext context) {

    final List<String> cities=['Addis Ababa','Bahirdar','Hawasa','Mekele','Bishoftu','Gondor','DireDawa'];
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, '/search');
            },
            child: Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 3),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [SizedBox(width: 40), Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Icon(Icons.search),
                )],
              ),
            ),
          ),
          SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Cities"),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: cities.map((city) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CityCard(city: city, allhotel: allhotel,),
                  )).toList(),
                ),
              ),
              Text("Near you"),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: nearby.map((hotel) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: HotelsCard(hotel: hotel),
                  )).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class CityCard extends StatelessWidget {
  const CityCard({required this.city, super.key, required this.allhotel});
  final String city;
  final List<Hotels> allhotel;

  Widget buildStars(int rating) {
    return Row(
      children: List.generate(rating, (index) => Icon(Icons.star, color: Colors.amber, size: 10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Hotels> searchedHotel =[];
    Future<void> Searched(String key) async {
      key=key+", Ethiopia";
      for(var hotels in allhotel){
        if(hotels.location==key) {
          searchedHotel.add(hotels);
        }
      }
    }
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          await Searched(city);
          Navigator.pushReplacementNamed(context, '/search',arguments: searchedHotel);
        },
        child: Container(
          width: 150,
          height: 140,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 75,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/${city}.jpg"),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(city, style: GoogleFonts.bebasNeue(
                      fontSize: 15,
                    )),
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
class HotelsCard extends StatelessWidget {
  const HotelsCard({required this.hotel, super.key});
  final Hotels hotel;

  Widget buildStars(int rating) {
    return Row(
      children: List.generate(rating, (index) => Icon(Icons.star, color: Colors.amber, size: 10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/HotelProfile',
            arguments: hotel,
          );
        },
        child: Container(
          width: 150,
          height: 140,
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
              Container(
                height: 75,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(hotel.imageUrls[0]),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hotel.hotelname, style: GoogleFonts.bebasNeue(
                      fontSize: 15,
                    )),
                    Text(hotel.location.toString(), style: GoogleFonts.bebasNeue(
                      fontSize: 10,color: Colors.grey,
                    )),
                    buildStars(hotel.hotelStar),
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
class Hotels {
  Hotels({
    required this.id,
    required this.hotelname,
    required this.tokens,
    required this.email,
    required this.roomType,
    required this.noOfBeds,
    required this.price,
    required this.roomSize,
    required this.availableRooms,
    required this.facilities,
    required this.latitude,
    required this.longitude,
    required this.hotelStar,
    required this.imageUrls,
    required this.roomimages,
    required this.location,
  });
  String id;
  List<String> tokens;
  String hotelname;
  String email;
  List<dynamic> roomType;
  List<dynamic> noOfBeds;
  List<dynamic> price;
  List<dynamic> roomSize;
  List<dynamic> availableRooms;
  List<dynamic> facilities;
  double latitude;
  double longitude;
  int hotelStar;
  List<dynamic> imageUrls;
  List<dynamic> roomimages;
  dynamic location;
}
