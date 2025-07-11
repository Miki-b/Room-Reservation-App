import 'package:flutter/material.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/hotel_model.dart';
import '../../../data/models/room_model.dart';
import '../../../data/models/room_type_model.dart';
import '../my_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../screens/booking/Payment.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final HotelModel? hotel;
  final Room? room;
  final RoomType? roomType;
  const BookingCard({
    required this.booking,
    this.hotel,
    this.room,
    this.roomType,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Use roomType image(s) for the room image
    String? roomImage;
    if (roomType != null) {
      if (roomType!.images.isNotEmpty) {
        roomImage = roomType!.images[0];
      } else if (roomType!.image.isNotEmpty) {
        roomImage = roomType!.image;
      }
    }
    // Use hotel images for the hotel image
    String? hotelImage;
    if (hotel != null && hotel!.images.isNotEmpty) {
      hotelImage = hotel!.images[0];
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: SizedBox(
        height: 232,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Images column, flush left, no gap, only outer corners rounded
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Room image (top, top-left corner rounded)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                  ),
                  child: roomImage != null
                      ? Image.network(
                          roomImage,
                          width: 118,
                          height: 116,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const ImagePlaceholder(width: 95, height: 95),
                        )
                      : const ImagePlaceholder(width: 95, height: 95),
                ),
                // Hotel image (bottom, bottom-left corner rounded)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                  ),
                  child: hotelImage != null
                      ? Image.network(
                          hotelImage,
                          width: 118,
                          height: 116,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const ImagePlaceholder(width: 95, height: 95),
                        )
                      : const ImagePlaceholder(width: 95, height: 95),
                ),
              ],
            ),
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      hotel?.name ?? 'Unknown Hotel',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        shadows: [
                          Shadow(
                            color: Colors.white24,
                            offset: Offset(0, 1),
                            blurRadius: 1,
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      roomType?.name ?? 'Unknown Room Type',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        StatusChip(
                          label: booking.status,
                          color: booking.status == 'approved'
                              ? Colors.green
                              : Colors.orange,
                        ),
                        StatusChip(
                          label: booking.paymentStatus,
                          color: booking.paymentStatus == 'paid'
                              ? Colors.blue
                              : Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Check-in:  ${booking.startDate.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      'Check-out: ${booking.endDate.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 210,
                      height: 37,
                      child: MyButton(
                        buttonText: booking.paymentStatus == 'paid'
                            ? 'Paid'
                            : 'Complete Payment',
                        onTap: booking.paymentStatus == 'paid' ||
                                booking.status != 'approved'
                            ? null
                            : () async {
                                // Fetch user info from Firestore
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(
                                      child: CircularProgressIndicator()),
                                );
                                try {
                                  final userDoc = await FirebaseFirestore
                                      .instance
                                      .collection('users')
                                      .doc(booking.userId)
                                      .get();
                                  final userData = userDoc.data();

                                  // Get first and last name from Firestore
                                  final firstName =
                                      userData?['firstName'] ?? '';
                                  final lastName = userData?['lastName'] ?? '';
                                  final userPhone = userData?['phone'] ?? '';

                                  // Create full name from first and last name
                                  String userFullName;
                                  if (firstName.isNotEmpty ||
                                      lastName.isNotEmpty) {
                                    userFullName =
                                        '${firstName.trim()} ${lastName.trim()}'
                                            .trim();
                                  } else {
                                    userFullName =
                                        userData?['name'] ?? 'Unknown';
                                  }

                                  Navigator.of(context).pop(); // Remove loading
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => PaymentPage(
                                        booking: booking,
                                        hotel: hotel!,
                                        roomType: roomType!,
                                        userFullName: userFullName,
                                        userPhone: userPhone,
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Failed to fetch user info: $e')),
                                  );
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImagePlaceholder extends StatelessWidget {
  final double width;
  final double height;
  const ImagePlaceholder({super.key, this.width = 100, this.height = 100});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Icon(
        Icons.hotel,
        color: Colors.grey,
        size: 40,
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const StatusChip({required this.label, required this.color, super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
