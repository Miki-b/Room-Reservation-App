import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _signupState();
}

class _signupState extends State<SignUp> {
  final TextEditingController _email=TextEditingController();
  final TextEditingController _password=TextEditingController();
  final TextEditingController _name=TextEditingController();
  Future<void> addUser(String name, String email) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return users.add({
      'name': name,
      'email': email,
    }).then((value) {
      print("User Added with ID: ${value.id}");
    }).catchError((error) {
      print("Failed to add user: $error");
    });
  }
  Future<void> signup() async {
    String email = _email.text;
    String password = _password.text;
    String name = _name.text;
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        await addUser(name, email);
        print('Sign In successful: ${user.email}');

        Navigator.pushReplacementNamed(context, '/home');
        return showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Signed up successfully'),
            content: Text('Now log in'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      print('Failed with error code: ${e.code}');
      print(e.message);
      String message = e.message ?? 'An unknown error occurred';
      return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Sign up failed'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<User?> signUpWithEmailPassword(String email,String password) async{
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    }on FirebaseAuthException catch(e){
      print('Failed with error code: ${e.code}');
      print(e.message);
      return null;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // Icon(
                //   Icons.android,
                //   size: 100.0,
                // ),SizedBox(height:45),
                // Text('HELLO AGAIN',
                //     style: GoogleFonts.bebasNeue(
                //       fontSize:52,
                //     )),
                // SizedBox(height:5),
                Text('Sign Up with new email and password',style: TextStyle(fontSize: 20),),
                SizedBox(height:50),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12)),

                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      controller: _name,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Full Name'
                      ),
                    ),
                  ),
                ),SizedBox(height:15),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12)),

                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      controller: _email,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Email'
                      ),
                    ),
                  ),
                ),SizedBox(height:15),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12)),

                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      controller: _password,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Password'
                      ),
                    ),
                  ),
                ),SizedBox(height:15),
                TextButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all<Size>(Size.fromWidth(400)),
                    backgroundColor:  MaterialStateProperty.all<Color>(Colors.deepPurple[400]!),

                  ),
                  onPressed: () {
                    signup();

                  }, child:
                Text('Sign up',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                  ),),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
