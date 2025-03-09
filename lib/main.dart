import 'package:flutter/material.dart';
import 'media_selection_page.dart';  // Import media selection screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MediaSelectionPage(), // Load media selection screen
    );
  }
}