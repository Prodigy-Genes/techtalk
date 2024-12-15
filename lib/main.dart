// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';
import 'package:techtalk/techtalk/navigations/authroute.dart';

// Create a global logger instance
final Logger logger = Logger();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: "assets/.env");

  // Retrieve variables from .env file
  final apiKey = dotenv.env['API_KEY'];
  final appId = dotenv.env['APP_ID'];
  final messagingSenderId = dotenv.env['MESSAGING_SENDER_ID'];
  final projectId = dotenv.env['PROJECT_ID'];

  if (apiKey == null || appId == null || messagingSenderId == null || projectId == null) {
    logger.e('Missing Firebase configuration in .env file');
    throw Exception('Missing Firebase configuration.');
  }

  try {
    // Initialize Firebase with environment variables
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        storageBucket: dotenv.env['STORAGE_BUCKET'], 
      ),
    );
    logger.i('Firebase initialized successfully.');
  } catch (e, stackTrace) {
    // Log detailed error and stack trace for debugging
    logger.e('Firebase initialization failed: $e, $stackTrace');
  }

  runApp(const techtalk());
}

class techtalk extends StatelessWidget {
  const techtalk({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthRoute(),
    );
  }
}
