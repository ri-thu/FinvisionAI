import 'package:flutter/material.dart';
import 'media_selection_page.dart';  // Import your media selection screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Media Picker App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MediaSelectionPage(), // Load the media selection screen
    );
  }
}