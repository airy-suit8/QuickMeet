import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/firebase/userdetails.dart';
import 'auth/welcome_screen.dart';
import 'auth/register.dart';
import 'auth/login.dart';
import 'splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Splash(),
        '/welcome': (context) => const Welcome(),
        '/register': (context) => Register(),
        '/login': (context) => Login(),
        '/homescreen': (context) => HomeScreen(),
        '/user-details': (context) => UserDetails(),
      },
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            UserAccountListener(), // Add the listener widget here
          ],
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zoom Clone Home'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Add logic for starting a meeting
                print("Start Meeting");
              },
              child: Text('Start Meeting'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add logic for joining a meeting
                print("Join Meeting");
              },
              child: Text('Join Meeting'),
            ),
          ],
        ),
      ),
    );
  }
}

class UserAccountListener extends StatefulWidget {
  const UserAccountListener({super.key});

  @override
  _UserAccountListenerState createState() => _UserAccountListenerState();
}

class _UserAccountListenerState extends State<UserAccountListener> {
  @override
  void initState() {
    super.initState();
    _listenToUserAccount();
    _checkAndUpdateProfilePicture(); // Call the function to check and update profile picture
  }

  void _listenToUserAccount() {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((DocumentSnapshot documentSnapshot) {
        if (!documentSnapshot.exists) {
          // User document does not exist, log out the user
          FirebaseAuth.instance.signOut();
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
    }
  }

  Future<void> _checkAndUpdateProfilePicture() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        print('Current user is signed in: ${user.email}');

        // Check if user exists in Firestore
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          print('User document does not exist in Firestore.');
          // User does not exist in Firestore, no need to continue
          return;
        }

        // If the document exists, proceed with fetching and comparing profile picture URLs
        _updateProfilePictureIfNeeded(user);
      } else {
        print('No user is currently signed in.');
      }
    } catch (e) {
      print('Error checking or updating profile picture: $e');
    }
  }

  Future<void> _updateProfilePictureIfNeeded(User user) async {
    try {
      // Get the current profile picture URL
      String? currentProfilePictureUrl = user.photoURL;
      print(
          'Current Profile Picture URL from Firebase Auth: $currentProfilePictureUrl');

      if (currentProfilePictureUrl == null) {
        print('No profile picture found in user data.');
        return; // Exit if there is no profile picture to update
      }

      // Fetch the stored profile picture URL from Firestore
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        String? storedProfilePictureUrl = userDoc.data()?['profilePicture'];
        print(
            'Stored Profile Picture URL in Firestore: $storedProfilePictureUrl');

        // Check if the URLs are different and update Firestore if needed
        if (currentProfilePictureUrl != storedProfilePictureUrl) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'profilePicture': currentProfilePictureUrl});
          print('Profile picture URL updated in Firestore.');
        } else {
          print('No update needed; profile picture URL is already up-to-date.');
        }
      } else {
        print('User document does not exist in Firestore.');
      }
    } catch (e) {
      print('Error updating profile picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // No UI needed, just the listener
  }
}
