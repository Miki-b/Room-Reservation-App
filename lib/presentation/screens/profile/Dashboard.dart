import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int users = 0;
  List<QueryDocumentSnapshot> docs = [];

  @override
  void initState() {
    super.initState();
    getAllUsers();
  }

  Future<void> deleteUser(String userId) async {
    try {
      // Delete from Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).delete().then((value) {
        print("User Deleted from Firestore");
      });

      // Delete from Firebase Authentication
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.uid == userId) {
        await user.delete().then((value) {
          print("User Deleted from Firebase Authentication");
        });
      } else {
        print("User not found in Authentication");
      }

      // Refresh user list
      getAllUsers();
    } catch (error) {
      print("Failed to delete user: $error");
    }
  }

  Future<void> getAllUsers() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      docs = querySnapshot.docs;
      users = docs.length;
    });
  }

  Future<void> updateUser(String userId, String name) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'name': name,
    }).then((value) {
      print("User Updated");
    }).catchError((error) {
      print("Failed to update user: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[600],
        title: Row(
          children: [
            const Icon(Icons.account_circle),
            const Text('System Administrator'),
            TextButton(
              onPressed: () {
                getAllUsers();
              },
              child: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: docs.length,
        itemBuilder: (context, index) {
          var data = docs[index].data() as Map<String, dynamic>;
          String name = data['name'] ?? 'No name';
          String email = data['email'] ?? 'No email';

          return Card(
            child: ListTile(
              title: Text(name),
              subtitle: Text(email),
              trailing: IconButton(
                onPressed: () {
                  deleteUser(docs[index].id);
                },
                icon: const Icon(Icons.delete_forever),
              ),
            ),
          );
        },
      ),
    );
  }
}
