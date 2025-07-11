import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../home/HomeScreen.dart';
import '../auth/signIn.dart';

class mainpage extends StatelessWidget {
  const mainpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomeScreen();
          } else {
            return Home(); // Login form
          }
        },
      ),
    );
  }
}
