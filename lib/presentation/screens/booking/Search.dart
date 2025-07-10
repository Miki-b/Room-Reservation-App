import '../hotel/HotelsMap.dart';
import 'package:flutter/material.dart';
import '../home/HomeScreen.dart';
import 'SearchResults.dart';
import '../../../firestore.dart';

class Search extends StatefulWidget {
  Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<Hotels> allHotels = [];
  List<Hotels> searchedHotel = [];
  final recentSearches = TextEditingController();

  int searched = 0;
  List<String> searchHistory = [];

  void history() {
    String searches = recentSearches.text;
    searchHistory.add(searches);
    print("history $searchHistory");
  }

  @override
  void initState() {
    super.initState();
    AllHotels();
  }

  Future<void> Searched(String key) async {
    for (var hotels in allHotels) {
      for (var names in hotels.tokens) {
        if (names == key) {
          searchedHotel.add(hotels);
        }
      }
    }
  }

  Future<void> AllHotels() async {
    List<Hotels> hotels = await FirestoreService.allHotels();
    setState(() {
      allHotels = hotels;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Hotels>? searchbylocation = ModalRoute.of(context)!.settings.arguments as List<Hotels>?;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 180,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 12.0),
                child: Center(
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 1),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Container(
                            width: 200,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(15.0, 10, 0, 0),
                              child: TextField(
                                controller: recentSearches,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Search by hotel name'
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(onPressed: () {
                          Navigator.popAndPushNamed(context, '/mainpage');
                        }, icon: Icon(Icons.cancel_outlined, color: Colors.grey[500],))
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      width: 180,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 1),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextButton(onPressed: () {}, child: Text('Filter')),
                      )),
                  Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 1),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      width: 180,
                      height: 45,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextButton(onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HotelsMap(allHotels: allHotels),
                            ),
                          );
                        }, child: Text('Search on Map')),
                      )),
                ],
              )
            ],
          ),
          elevation: 1,
        ),
        body: getBodyContent(searchbylocation ?? []),
        bottomNavigationBar: Container(
          width: double.infinity,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[100],
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: GestureDetector(
              onTap: () async {
                history();
                setState(() {
                  searched = 1;
                  searchbylocation=[];
                  searchedHotel=[];
                });
                await Searched(recentSearches.text);

              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 1),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Center(child: Text('Search')),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getBodyContent(List<Hotels> searchbylocation) {
    if(searchbylocation.isNotEmpty){
      setState(() {
        searched=2;
      });
    }

    if (searched == 0) {
      return ListView.builder(
        itemCount: searchHistory.length,
        itemBuilder: (context, index) {
          print(searchHistory);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0),
            child: Container(
              height: 30,
              decoration: BoxDecoration(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.access_time_outlined),
                    Text(searchHistory[index]),
                    Icon(Icons.cancel_outlined)
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else if (searched == 1) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: searchedHotel.length,
          itemBuilder: (BuildContext context, int index) {
            print(searchedHotel[index].hotelname);
            print(searchedHotel);
            return SearchResults(hotel: searchedHotel[index]);
          },
        ),
      );
    } else if (searched == 2) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: searchbylocation.length,
          itemBuilder: (BuildContext context, int index) {
            print(searchbylocation[index].hotelname);
            print(searchbylocation);
            return SearchResults(hotel: searchbylocation[index]);
          },
        ),
      );
    } else {
      return Container(); // Default case if searched is not 0, 1, or 2
    }
  }
}
