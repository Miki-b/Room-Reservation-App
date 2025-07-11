import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final userInfoProvider = FutureProvider<UserInfo?>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  final doc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  final data = doc.data();

  // Use firstName from Firestore, fallback to email username, then 'User'
  String displayName =
      data?['firstName'] ?? user.email?.split('@').first ?? 'User';

  return UserInfo(
    firstName: data?['firstName'] ?? '',
    lastName: data?['lastName'] ?? '',
    displayName: displayName,
    userId: user.uid,
    imagePath: user.photoURL,
  );
});

class UserInfo {
  final String firstName;
  final String lastName;
  final String displayName;
  final String userId;
  final String? imagePath;

  UserInfo(
      {required this.firstName,
      required this.lastName,
      required this.displayName,
      required this.userId,
      this.imagePath});
}

class AppDrawer extends ConsumerWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userInfoProvider);
    return userAsync.when(
      loading: () =>
          const Drawer(child: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Drawer(child: Center(child: Text('Error: $err'))),
      data: (user) => Drawer(
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: DrawerHeader(
                child: Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: user?.imagePath != null
                            ? NetworkImage(user!.imagePath!)
                            : const AssetImage('assets/no-user-Image.png')
                                as ImageProvider,
                      ),
                      const SizedBox(height: 8),
                      Text(user?.displayName ?? user?.userId ?? "Unknown User",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/edit_profile');
                        },
                        child: Text("Edit Profile",
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.secondary)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
