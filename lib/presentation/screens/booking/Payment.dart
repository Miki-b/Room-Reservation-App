import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/hotel_model.dart';
import '../../../data/models/room_type_model.dart';
import '../../controllers/payment_method_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentPage extends ConsumerStatefulWidget {
  final BookingModel booking;
  final HotelModel hotel;
  final RoomType roomType;
  final String userFullName;
  final String userPhone;

  const PaymentPage({
    super.key,
    required this.booking,
    required this.hotel,
    required this.roomType,
    required this.userFullName,
    required this.userPhone,
  });

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  String? selectedPaymentMethodId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load payment methods when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentMethodControllerProvider.notifier).fetch();
    });
  }

  Future<String> _getUserFullName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return widget.userFullName;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();
      final firstName = data?['firstName'] ?? '';
      final lastName = data?['lastName'] ?? '';

      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        return '${firstName.trim()} ${lastName.trim()}'.trim();
      }

      return widget.userFullName;
    } catch (e) {
      return widget.userFullName;
    }
  }

  Future<void> _processPayment() async {
    if (selectedPaymentMethodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Update booking payment status
      await FirebaseFirestore.instance
          .collection('booking_requests')
          .doc(widget.booking.id)
          .update({
        'paymentStatus': 'paid',
        'status': 'approved',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to bookings
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentMethodControllerProvider);
    final nights =
        widget.booking.endDate.difference(widget.booking.startDate).inDays;
    final total =
        (widget.roomType.price * (nights > 0 ? nights : 1)).toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Payment'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: FutureBuilder<String>(
        future: _getUserFullName(),
        builder: (context, snapshot) {
          final fullName = snapshot.data ?? widget.userFullName;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking Summary Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking Summary',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        SizedBox(height: 16),
                        _buildInfoRow('Hotel', widget.hotel.name),
                        _buildInfoRow('Room Type', widget.roomType.name),
                        _buildInfoRow(
                            'Check-in', _formatDate(widget.booking.startDate)),
                        _buildInfoRow(
                            'Check-out', _formatDate(widget.booking.endDate)),
                        _buildInfoRow('Nights', '$nights'),
                        Divider(height: 32),
                        _buildInfoRow('Price per night',
                            'ETB ${widget.roomType.price.toStringAsFixed(2)}'),
                        _buildInfoRow('Total Amount', 'ETB $total',
                            isTotal: true),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // User Information Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Guest Information',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        SizedBox(height: 16),
                        _buildInfoRow('Full Name', fullName),
                        _buildInfoRow('Phone Number', widget.userPhone),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // Payment Method Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Method',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        SizedBox(height: 16),
                        if (paymentState.loading)
                          Center(child: CircularProgressIndicator())
                        else if (paymentState.error != null)
                          Text(
                            'Error loading payment methods: ${paymentState.error}',
                            style: TextStyle(color: Colors.red),
                          )
                        else if (paymentState.methods.isEmpty)
                          Text(
                            'No payment methods available',
                            style: TextStyle(color: Colors.grey),
                          )
                        else
                          Column(
                            children: paymentState.methods.map((method) {
                              return RadioListTile<String>(
                                title: Text(method.methodName),
                                value: method.methodId,
                                groupValue: selectedPaymentMethodId,
                                onChanged: (value) {
                                  setState(() {
                                    selectedPaymentMethodId = value;
                                  });
                                },
                                activeColor:
                                    Theme.of(context).colorScheme.secondary,
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 32),

                // Payment Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Complete Payment',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
