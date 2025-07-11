import 'package:firebase/data/models/hotel_model.dart';
import 'package:firebase/presentation/screens/admin/admin_screen.dart';

import 'presentation/screens/profile/Dashboard.dart';
import 'presentation/screens/hotel/HotelsMap.dart';
import 'presentation/screens/auth/SignUp.dart';
import 'presentation/screens/auth/signIn.dart';
import 'presentation/screens/booking/Book.dart';
import 'presentation/screens/home/HomeScreen.dart';
import 'presentation/screens/hotel/HotelProfile.dart';
import 'presentation/screens/booking/Payment.dart';
import 'presentation/screens/booking/Search.dart';
import 'presentation/screens/map/map.dart';
import 'presentation/screens/home/Mainpage.dart';
import 'presentation/screens/profile/edit_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'presentation/screens/auth/auth_gate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.white,
          secondary: Color.fromARGB(255, 0, 128, 113), // dark teal
        ),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color.fromARGB(255, 0, 128, 113),
          elevation: 1,
          titleTextStyle: GoogleFonts.poppins(
            color: Color.fromARGB(255, 0, 128, 113),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color.fromARGB(255, 0, 128, 113)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Color.fromARGB(255, 0, 128, 113), width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 0, 128, 113),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => AuthGate(),
        '/home': (context) => AuthGate(),
        '/mainpage': (context) => mainpage(),
        '/signUp': (context) => SignUp(),
        '/dashboard': (context) => Dashboard(),
        '/map': (context) => Maps(),
        '/search': (context) => Search(),
        '/HotelProfile': (context) => HotelProfile(),
        '/admin': (context) => AdminScreen(),
        '/book': (context) => Book(), // <-- lowercase route
        '/pay': (context) => PaymentPage(
              booking: throw UnimplementedError(),
              hotel: throw UnimplementedError(),
              roomType: throw UnimplementedError(),
              userFullName: '',
              userPhone: '',
            ),
        '/edit_profile': (context) => const EditProfilePage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/HotelMap') {
          final allHotels = (settings.arguments as List?)?.cast<HotelModel>() ??
              <HotelModel>[];
          return MaterialPageRoute(
            builder: (context) => HotelsMap(allHotels: allHotels),
          );
        }
        return null;
      },
    );
  }
}
