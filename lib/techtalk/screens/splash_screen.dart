import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/appicon.png',
                width: 200,
              ),
              const SizedBox(
                height: 30,
              ),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(fontSize: 42),
                  children: const [
                    TextSpan(
                      text: 'Tech',
                      style: TextStyle(color: Color.fromARGB(255, 0, 255, 47)),
                    ),
                    TextSpan(
                      text: 'Talk',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              )
            ],
          )),
        ));
  }
}
