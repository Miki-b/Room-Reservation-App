import '../../../firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({super.key});

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 100.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome to Marefia.com",
                style: GoogleFonts.bebasNeue(
                  fontSize: 52,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Embark on a Journey to Find Your Perfect Night Stay Nearby! Start Now and Reserve Your Dream Stay Today for an Unforgettable Experience!",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: GestureDetector(
                  onTap: () {
                    //firestore();
                    Navigator.pushReplacementNamed(context, "/mainpage");

                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 4),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 23,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
