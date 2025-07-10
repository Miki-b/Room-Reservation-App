import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../hotel/hotels.dart';

class AdminScreen extends StatefulWidget {
  AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<AdminScreen> {
  int typeofRooms = 0;
  bool isCheckedWifi = false;
  bool isCheckedReception = false;
  bool isCheckedPool = false;
  bool isCheckedBreakfast = false;
  bool isCheckedChildren = false;
  bool isCheckedPets = false;
  bool isLoading = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final starsController = TextEditingController();
  final List<TextEditingController> roomTypeControllers = [];
  final List<TextEditingController> noOfBedsControllers = [];
  final List<TextEditingController> priceControllers = [];
  final List<TextEditingController> roomSizeControllers = [];
  final List<TextEditingController> availableRoomsControllers = [];
  LatLng locationController = LatLng(0, 0);

  final _formKey = GlobalKey<FormState>();

  // List to store selected images for the hotel
  final List<File?> hotelImages = [];

  // List to store one selected image for each room type
  final List<File?> roomImages = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    starsController.dispose();
    for (var controller in roomTypeControllers) {
      controller.dispose();
    }
    for (var controller in noOfBedsControllers) {
      controller.dispose();
    }
    for (var controller in priceControllers) {
      controller.dispose();
    }
    for (var controller in roomSizeControllers) {
      controller.dispose();
    }
    for (var controller in availableRoomsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void initializeRoomControllers(int count) {
    roomTypeControllers.clear();
    noOfBedsControllers.clear();
    priceControllers.clear();
    roomSizeControllers.clear();
    availableRoomsControllers.clear();
    roomImages.clear(); // Reset the list for new room types

    for (int i = 0; i < count; i++) {
      roomTypeControllers.add(TextEditingController());
      noOfBedsControllers.add(TextEditingController());
      priceControllers.add(TextEditingController());
      roomSizeControllers.add(TextEditingController());
      availableRoomsControllers.add(TextEditingController());
      roomImages.add(null); // Initialize with null for each room type
    }
  }
  Future<File> saveImageToLocalDirectory(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = image.path.split('/').last;
    final localImagePath = '${directory.path}/$fileName';
    return await image.copy(localImagePath);
  }
  Future<void> pickHotelImages() async {
    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage();

      if (pickedFiles != null) {
        for (var file in pickedFiles) {
          File savedImage = await saveImageToLocalDirectory(File(file.path));
          setState(() {
            hotelImages.add(savedImage);
          });
        }
      }
    } catch (e) {
      print("Error picking hotel images: $e");
      showPopupMessage("Error", "Failed to pick hotel images.", false);
    }
  }

  Future<void> pickRoomImage(int index) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File savedImage = await saveImageToLocalDirectory(File(pickedFile.path));
        setState(() {
          roomImages[index] = savedImage;
        });
      }
    } catch (e) {
      print("Error picking room image: $e");
      showPopupMessage("Error", "Failed to pick room image.", false);
    }
  }

  Future<List<String>> uploadRoomImages(String hotelId) async {
    List<String> roomImageUrls = [];

    for (int i = 0; i < roomImages.length; i++) {
      File? image = roomImages[i];
      if (image != null) {
        String fileName = image.path.split('/').last;
        Reference ref = FirebaseStorage.instance.ref().child('hotels/$hotelId/room_$i/$fileName');
        UploadTask uploadTask = ref.putFile(image);
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        roomImageUrls.add(downloadUrl);
      }
    }

    return roomImageUrls;
  }

  Future<List<String>> uploadHotelImages(String hotelId) async {
    List<String> hotelImageUrls = [];

    for (int i = 0; i < hotelImages.length; i++) {
      File? image = hotelImages[i];
      if (image != null) {
        String fileName = image.path.split('/').last;
        Reference ref = FirebaseStorage.instance.ref().child('hotels/$hotelId/hotel/$fileName');
        UploadTask uploadTask = ref.putFile(image);
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        hotelImageUrls.add(downloadUrl);
      }
    }

    return hotelImageUrls;
  }

  void showPopupMessage(String title, String message, bool success) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (success) Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<ProfileScreen>(
                  builder: (context) => ProfileScreen(
                    appBar: AppBar(
                      title: const Text('User Profile'),
                    ),
                    actions: [
                      SignedOutAction((context) {
                        Navigator.of(context).pop();
                      })
                    ],
                    children: [],
                  ),
                ),
              );
            },
          )
        ],
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Hotel name'),
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the hotel name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Hotel email'),
                  controller: emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the hotel email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Hotel Class'),
                  controller: starsController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the hotel class';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Text('Hotel Images', style: TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: pickHotelImages,
                  child: Text('Pick Hotel Images'),
                ),
                SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: List.generate(hotelImages.length, (index) {
                    return Stack(
                      children: [
                        Image.file(
                          hotelImages[index]!,
                          height: 100,
                          width: 100,
                        ),
                        Positioned(
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                hotelImages.removeAt(index);
                              });
                            },
                            child: Icon(Icons.remove_circle, color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                SizedBox(height: 16.0),
                Text('Room Details', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Types of rooms available in numbers'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      typeofRooms = int.tryParse(value) ?? 0;
                      initializeRoomControllers(typeofRooms);
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty || int.tryParse(value) == null) {
                      return 'Please enter the types of rooms available';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                if (typeofRooms > 0)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: typeofRooms,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Room Type ${index + 1}', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Room Type Name'),
                            controller: roomTypeControllers[index],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the room type name';
                              }
                              return null;
                            },
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(labelText: 'Number of beds'),
                                  controller: noOfBedsControllers[index],
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty || int.tryParse(value) == null) {
                                      return 'Please enter the amount of beds';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(labelText: 'Price'),
                                  controller: priceControllers[index],
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty || double.tryParse(value) == null) {
                                      return 'Please enter the price';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(labelText: 'Room Size'),
                                  controller: roomSizeControllers[index],
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty || double.tryParse(value) == null) {
                                      return 'Please enter the room size';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(labelText: 'Amount of rooms available'),
                                  controller: availableRoomsControllers[index],
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty || int.tryParse(value) == null) {
                                      return 'Please enter the number of rooms available';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.0),
                          ElevatedButton(
                            onPressed: () => pickRoomImage(index),
                            child: Text('Pick Image for Room Type ${index + 1}'),
                          ),
                          SizedBox(height: 8.0),
                          if (roomImages[index] != null)
                            Stack(
                              children: [
                                Image.file(
                                  roomImages[index]!,
                                  height: 100,
                                  width: 100,
                                ),
                                Positioned(
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        roomImages[index] = null;
                                      });
                                    },
                                    child: Icon(Icons.remove_circle, color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      );
                    },
                  ),
                SizedBox(height: 16.0),
                Text('Facilities', style: TextStyle(fontWeight: FontWeight.bold)),
                CheckboxListTile(
                  title: Text('WiFi'),
                  value: isCheckedWifi,
                  onChanged: (bool? value) {
                    setState(() {
                      isCheckedWifi = value!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('24-hour reception'),
                  value: isCheckedReception,
                  onChanged: (bool? value) {
                    setState(() {
                      isCheckedReception = value!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('Swimming pool'),
                  value: isCheckedPool,
                  onChanged: (bool? value) {
                    setState(() {
                      isCheckedPool = value!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('Breakfast offered'),
                  value: isCheckedBreakfast,
                  onChanged: (bool? value) {
                    setState(() {
                      isCheckedBreakfast = value!;
                    });
                  },
                ),
                SizedBox(height: 16.0),
                TextButton(
                  onPressed: () async {
                    dynamic result = await Navigator.pushNamed(context, '/map');
                    locationController = result;
                  },
                  child: Text('Share location'),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });

                      List<String> facilities = [];
                      if (isCheckedWifi) facilities.add('WiFi');
                      if (isCheckedReception) facilities.add('24-hour reception');
                      if (isCheckedPool) facilities.add('Swimming pool');
                      if (isCheckedBreakfast) facilities.add('Breakfast offered');

                      List<String> roomTypes = [];
                      List<int> noOfBeds = [];
                      List<double> prices = [];
                      List<double> roomSizes = [];
                      List<int> availableRooms = [];

                      for (int i = 0; i < typeofRooms; i++) {
                        roomTypes.add(roomTypeControllers[i].text);
                        noOfBeds.add(int.parse(noOfBedsControllers[i].text));
                        prices.add(double.parse(priceControllers[i].text));
                        roomSizes.add(double.parse(roomSizeControllers[i].text));
                        availableRooms.add(int.parse(availableRoomsControllers[i].text));
                      }

                      GeoPoint hotelGeoPoint = GeoPoint(locationController.latitude, locationController.longitude);

                      Hotel hotel = Hotel(
                        hotelName: nameController.text,
                        hotelEmail: emailController.text,
                        roomType: roomTypes,
                        noOfBeds: noOfBeds,
                        price: prices,
                        roomSize: roomSizes,
                        availableRooms: availableRooms,
                        facilities: facilities,
                        hotelLocation: hotelGeoPoint,
                      );

                      try {
                        DocumentReference docRef = await FirebaseFirestore.instance.collection('hotels').add(hotel.toJson());

                        // Upload the room images and get their URLs
                        List<String> roomImageUrls = await uploadRoomImages(docRef.id);

                        // Store all room type's image URLs in a single list
                        await FirebaseFirestore.instance.collection('hotels').doc(docRef.id).update({
                          'roomImageUrls': roomImageUrls,
                        });

                        // Upload the hotel images and get their URLs
                        List<String> imageUrls = await uploadHotelImages(docRef.id);

                        // Update the hotelImageUrls in the Firestore document
                        await FirebaseFirestore.instance.collection('hotels').doc(docRef.id).update({
                          'imageUrls': imageUrls,
                        });

                        showPopupMessage('Success', 'Hotel added successfully with photos.', true);
                      } catch (error) {
                        showPopupMessage('Failure', 'Failed to add hotel: $error', false);
                      }

                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
