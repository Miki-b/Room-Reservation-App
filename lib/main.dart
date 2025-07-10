import 'presentation/screens/profile/Dashboard.dart';
import 'presentation/screens/hotel/HotelsMap.dart';
import 'presentation/screens/profile/SignUp.dart';
import 'presentation/screens/home/home.dart';
import 'presentation/screens/booking/Book.dart';
import 'presentation/screens/home/HomeScreen.dart';
import 'presentation/screens/hotel/HotelProfile.dart';
import 'presentation/screens/booking/Payment.dart';
import 'presentation/screens/booking/Search.dart';
import 'presentation/screens/map/map.dart';
import 'presentation/screens/home/Mainpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'presentation/screens/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => AuthGate(),
        '/home': (context) => AuthGate(),
        '/mainpage': (context) => HomeScreen(),
        '/signUp': (context) => SignUp(),
        '/dashboard': (context) => Dashboard(),
        '/map': (context) => Maps(),
        '/search': (context) => Search(),
        '/HotelProfile': (context) => HotelProfile(),
        '/Book': (context) => Book(),
        '/pay': (context) => Payment(),
      },
    );
  }
}
