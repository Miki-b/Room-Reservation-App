import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/my_button.dart';
import 'hotel_info_page.dart';
import 'room_types_page.dart';
import 'amenities_images_page.dart';
import 'review_submit_page.dart';
import 'admin_wizard_state.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  int currentStep = 0;
  final AdminWizardState wizardState = AdminWizardState();

  // Keys for each step's State
  final hotelInfoKey = GlobalKey<HotelInfoPageState>();
  final roomTypesKey = GlobalKey<RoomTypesPageState>();
  final amenitiesKey = GlobalKey<AmenitiesImagesPageState>();

  List<Widget> get steps => [
        HotelInfoPage(key: hotelInfoKey, state: wizardState),
        RoomTypesPage(key: roomTypesKey, state: wizardState),
        AmenitiesImagesPage(key: amenitiesKey, state: wizardState),
        ReviewSubmitPage(state: wizardState),
      ];

  bool validateCurrentStep() {
    switch (currentStep) {
      case 0:
        return hotelInfoKey.currentState?.validate() ?? false;
      case 1:
        return roomTypesKey.currentState?.validate() ?? false;
      case 2:
        return amenitiesKey.currentState?.validate() ?? false;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Hotel'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(child: steps[currentStep]),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (currentStep > 0)
                      SizedBox(
                        width: 120,
                        child: MyButton(
                          buttonText: 'Back',
                          onTap: () => setState(() => currentStep--),
                        ),
                      )
                    else
                      const SizedBox(width: 120),
                    if (currentStep < steps.length - 1)
                      SizedBox(
                        width: 120,
                        child: MyButton(
                          buttonText: 'Next',
                          onTap: () {
                            if (validateCurrentStep()) {
                              setState(() => currentStep++);
                            }
                          },
                        ),
                      )
                    else
                      const SizedBox(width: 120),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    wizardState.nameController.dispose();
    wizardState.emailController.dispose();
    wizardState.starsController.dispose();
    wizardState.locationController.dispose();
    wizardState.cityIdController.dispose();
    wizardState.countryIdController.dispose();
    wizardState.descriptionController.dispose();
    for (var controller in wizardState.roomTypeControllers) {
      controller.dispose();
    }
    for (var controller in wizardState.roomTypeDescriptionControllers) {
      controller.dispose();
    }
    for (var controller in wizardState.noOfBedsControllers) {
      controller.dispose();
    }
    for (var controller in wizardState.priceControllers) {
      controller.dispose();
    }
    for (var controller in wizardState.roomSizeControllers) {
      controller.dispose();
    }
    for (var controller in wizardState.availableRoomsControllers) {
      controller.dispose();
    }
    for (var controller in wizardState.roomNumberControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
