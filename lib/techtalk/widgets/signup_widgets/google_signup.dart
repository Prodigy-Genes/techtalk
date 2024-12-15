import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GoogleSignup extends StatefulWidget {
  final VoidCallback onTap; // Callback to handle the Google signup logic

  const GoogleSignup({super.key, required this.onTap});

  @override
  State<GoogleSignup> createState() => _GoogleSignupState();
}

class _GoogleSignupState extends State<GoogleSignup> {
  bool _isLoading = false;

  void _handleTap() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
      widget.onTap();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _isLoading ? null : _handleTap, // Disable tap when loading
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 200,
        height: 50,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 0, 255, 8),
          borderRadius: BorderRadius.circular(15),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 30),
                  Image.asset(
                    'assets/icons/google.png',
                    width: 30,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Sign up here',
                    style: GoogleFonts.protestRevolution(),
                  ),
                ],
              ),
      ),
    );
  }
}
