import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AdminWizardState {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final starsController = TextEditingController();
  final locationController = TextEditingController();
  final cityIdController = TextEditingController();
  final countryIdController = TextEditingController();
  final descriptionController = TextEditingController();
  int typeofRooms = 0;
  final List<TextEditingController> roomTypeControllers = [];
  final List<TextEditingController> roomTypeDescriptionControllers = [];
  final List<TextEditingController> noOfBedsControllers = [];
  final List<TextEditingController> priceControllers = [];
  final List<TextEditingController> roomSizeControllers = [];
  final List<TextEditingController> availableRoomsControllers = [];
  final List<TextEditingController> roomNumberControllers = [];
  final List<TextEditingController> roomCountControllers = [];
  final List<String> roomStatusList = [];
  final List<String> statusOptions = ['available', 'booked', 'maintenance'];
  LatLng hotelLatLng = LatLng(0, 0);
  final List<File?> hotelImages = [];
  final List<File?> roomImages = [];
  bool isCheckedWifi = false;
  bool isCheckedReception = false;
  bool isCheckedPool = false;
  bool isCheckedBreakfast = false;
  String? selectedPaymentMethodId;
  String? selectedPaymentAccountNumber;
  void initializeRoomControllers(int count) {
    roomTypeControllers.clear();
    roomTypeDescriptionControllers.clear();
    noOfBedsControllers.clear();
    priceControllers.clear();
    roomSizeControllers.clear();
    availableRoomsControllers.clear();
    roomNumberControllers.clear();
    roomStatusList.clear();
    roomImages.clear();
    roomCountControllers.clear();
    for (int i = 0; i < count; i++) {
      roomTypeControllers.add(TextEditingController());
      roomTypeDescriptionControllers.add(TextEditingController());
      noOfBedsControllers.add(TextEditingController());
      priceControllers.add(TextEditingController());
      roomSizeControllers.add(TextEditingController());
      availableRoomsControllers.add(TextEditingController());
      roomNumberControllers.add(TextEditingController());
      roomStatusList.add('available');
      roomImages.add(null);
      roomCountControllers.add(TextEditingController(text: '1'));
    }
  }
}
