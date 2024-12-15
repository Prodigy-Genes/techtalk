// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:techtalk/techtalk/screens/signup_or_signin.dart';
import 'package:techtalk/techtalk/services/signout.dart';

class SignOutButton extends StatelessWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.logout,
        color: Colors.red,
      ),
      tooltip: 'Sign Out',
      onPressed: () async {
        try {
          // Show confirmation dialog
          final bool? confirmSignOut = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Sign Out'),
              content: const Text('Are you sure you want to sign out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          );

          // Proceed with sign out if confirmed
          if (confirmSignOut == true) {
            await Signoutservice().signOut(context);

            // Navigate to the Signup or Signin screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SignupOrSignin()),
            );
          }
        } catch (e) {
          // Show error if sign out fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign out failed: $e')),
          );
        }
      },
    );
  }
}
