import 'package:flutter/material.dart';
import 'sign_in_page.dart';

void main() {
  runApp(const CleanroomApp());
}

class CleanroomApp extends StatelessWidget {
  const CleanroomApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF145A32);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cleanroom Monitor',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFF6F8F6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          primary: primaryGreen,
          surface: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.90),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          hintStyle: const TextStyle(
            color: Colors.black45,
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            borderSide: BorderSide(color: primaryGreen, width: 1.4),
          ),
        ),
      ),
      home: const SignInPage(),
    );
  }
}