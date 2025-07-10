import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/presentation/screens/admin/admin_screen.dart';
import 'Favourites.dart';
import '../home/homee.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/HomeScreen.dart';

class Setting extends StatefulWidget {
  final void Function(List<Hotels> hotels) onHotelsFetched;

  const Setting({required this.onHotelsFetched, super.key});

  @override
  State<Setting> createState() => _SettingsState();
}

class _SettingsState extends State<Setting> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              EmailAuthProvider()
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20,100,20,20),
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ?  Text('Welcome to Maderia, please sign in!',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 39,
                  ),)
                    :  Text('Welcome to Maderia, please sign up!',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 39,
                  ),),
              );
            },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
          );
        }
        if(currentUser?.email=='michaelbehailu0@gmail.com'){
          print(currentUser?.email);
            return AdminScreen();
        }else{
          return Favourites();
        }
      },
    );
  }
}
