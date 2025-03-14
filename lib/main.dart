import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'media_selection_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FinvisionAI',
      theme: ThemeData(
        useMaterial3: true, // Enable Material 3 (Cashew-like)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9C0A7C), // Cashew-like Blue
        ),
        textTheme: GoogleFonts.robotoTextTheme(), // Modern font
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFB8B230), // Dark blue
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: const MediaSelectionPage(),
    );
  }
}