import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Import Material for easy testing
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../chapa_service.dart'; // To decode the JSON response

// void main() {
//   runApp(const Payment());
// }

class Payment extends StatefulWidget {
  const Payment({super.key});

  @override
  State<Payment> createState() => _MyAppState();
}

class _MyAppState extends State<Payment> {
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Chapa Integration')),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              ChapaService chapaService = ChapaService();
              await chapaService.createSubAccount(
                businessName: 'Abebe Souq',
                accountName: 'Abebe Bikila',
                bankCode: '96e41186-29ba-4e30-b013-4ca26d7g2025',
                accountNumber: '0123456789',
                splitValue: 0.2,
                splitType: 'percentage',
              );
            },
            child: Text('Create Subaccount'),
          ),
        ),
      ),
    );
  }
}