import 'package:flutter/material.dart';
import 'sign_in_page.dart';

void main() {
  runApp(const CleanroomApp());
}

class CleanroomApp extends StatelessWidget {
  const CleanroomApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2F9E44);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cleanroom Monitor',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          primary: primaryGreen,
          surface: Colors.white,
        ),
      ),
      home: const SignInPage(),
    );
  }
}