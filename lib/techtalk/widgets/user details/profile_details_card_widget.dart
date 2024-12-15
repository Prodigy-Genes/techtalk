import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:techtalk/techtalk/models/user.dart';
import 'profile_info_row_widget.dart';

class ProfileDetailsCardWidget extends StatelessWidget {
  final UserModel userModel;

  const ProfileDetailsCardWidget({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    final logger = Logger();
    try {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileInfoRowWidget(
                label: 'User ID',
                value: userModel.userId,
                icon: Icons.person,
              ),
              const Divider(),
              ProfileInfoRowWidget(
                label: 'Email Verified',
                value: FirebaseAuth.instance.currentUser!.emailVerified
                    ? 'Yes'
                    : 'No',
                icon: Icons.check_circle,
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      logger.e('Error displaying profile details card: $e');
      return const SizedBox();
    }
  }
}
