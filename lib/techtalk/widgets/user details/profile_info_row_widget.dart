import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';

class ProfileInfoRowWidget extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const ProfileInfoRowWidget({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final logger = Logger();
    try {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.protestRevolution(color: const Color.fromARGB(255, 0, 255, 8),fontSize: 20)
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      logger.e('Error displaying profile row: $e');
      return const SizedBox();
    }
  }
}
