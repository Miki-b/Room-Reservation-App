import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Favourites extends StatefulWidget {
  const Favourites({super.key});

  @override
  State<Favourites> createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map> _hotels = [];

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection("hotels").get();
      List<Map> hotels = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'email': doc['email'],
          'roomType': doc['roomType'],
          'beds': doc['beds'],
          'price': doc['price'],
          'size': doc['size'],
          'roomsAvailable': doc['roomsAvailable'],
          'facilities': doc['facilities'],
          'location': doc['location'],
          'imageUrls': doc['imageUrls']
        };
      }).toList();
      setState(() {
        _hotels = hotels;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore Data Fetcher'),

      ),
      body: Container(
        height: 700,
        child: ListView.builder(
          itemCount: _hotels.length,
          itemBuilder: (context, index) {
            final hotel = _hotels[index];
            return ListTile(
              title: Text(hotel['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${hotel['email']}'),
                  Text('Room Type: ${hotel['roomType']}'),
                  Text('Beds: ${hotel['beds']}'),
                  Text('Price: ${hotel['price']}'),
                  Text('Size: ${hotel['size']}'),
                  Text('Rooms Available: ${hotel['roomsAvailable']}'),
                  Text('Facilities: ${hotel['facilities']}'),
                  Text('Location: ${hotel['location']}'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
