import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techtalk/techtalk/services/googlesignin_service.dart';
import 'package:techtalk/techtalk/services/googlesignup_service.dart';
import 'package:techtalk/techtalk/widgets/signup_widgets/google_signin.dart';
import 'package:techtalk/techtalk/widgets/signup_widgets/google_signup.dart';

class SignupOrSignin extends StatelessWidget {
  final GoogleSignupService _googleSignupService = GoogleSignupService();
  final GooglesigninService _googleSigninService = GooglesigninService();

  SignupOrSignin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                  color: const Color.fromARGB(255, 32, 32, 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 150,
                      ),
                      Text(
                        'Sign up',
                        style: GoogleFonts.protestRevolution(
                            fontSize: 42, color: Colors.white),
                      ),
                      Text(
                        'Create an account to hop on board',
                        style:
                            GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      GoogleSignup(
                          onTap: () =>
                              _googleSignupService.signUpWithGoogle(context))
                    ],
                  )),
            ),
            Container(
              width: 3,
              color: const Color.fromARGB(255, 0, 255, 8), 
            ),
            Expanded(
              child: Container(
                  color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 600,
                      ),
                      Text(
                        'Sign in',
                        style: GoogleFonts.protestRevolution(
                            fontSize: 42,
                            color: const Color.fromARGB(255, 0, 255, 8)),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Get back into your account',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.white),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      GoogleSignin(onTap: () {
                        _googleSigninService.signInWithGoogle(context);
                      })
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
