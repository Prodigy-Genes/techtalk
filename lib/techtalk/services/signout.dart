// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class Signoutservice {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signOut(BuildContext context) async {
    try {
      // Sign out from Firebase
      await _auth.signOut();

      // Sign out from Google if Google Sign-In was used
      await _googleSignIn.signOut();

      
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }
}
