import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ProfilePictureWidget extends StatelessWidget {
  final String pictureUrl;

  const ProfilePictureWidget({super.key, required this.pictureUrl});

  @override
  Widget build(BuildContext context) {
    final logger = Logger();
    try {
      return Hero(
        tag: 'profile_image',
        child: CircleAvatar(
          radius: 64,
          backgroundColor: const Color.fromARGB(255, 0, 255, 8),
          child: CircleAvatar(
            radius: 60, // Slightly larger to form a border
            backgroundImage: NetworkImage(pictureUrl),
          ),
        ),
      );
    } catch (e) {
      logger.e('Error loading profile picture: $e');
      return const CircleAvatar(
        radius: 80,
        child: Icon(Icons.error),
      );
    }
  }
}
