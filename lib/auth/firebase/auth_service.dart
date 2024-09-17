// auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Define a service class for user account management
class UserAccountService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> linkAccount(BuildContext context) async {
    String errorMessage = '';

    try {
      // Get the current user
      User? user = auth.currentUser;
      if (user == null) {
        errorMessage = 'No user is currently logged in';
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(errorMessage)));
        }
        return;
      }

      // Simulate some data to be saved
      final profilePictureUrl = user.photoURL;

      // Save user data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'linkedEmail': user.email,
        'profilePicture': profilePictureUrl,
      }, SetOptions(merge: true));

      // Navigate to home screen
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/homescreen');
      }
    } catch (e) {
      errorMessage = 'Failed to link account: $e';
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }
}
