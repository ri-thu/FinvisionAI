import 'media_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MediaSelectionPage extends StatefulWidget {
  const MediaSelectionPage({Key? key}) : super(key: key);

  @override
  _MediaSelectionPageState createState() => _MediaSelectionPageState();
}

class _MediaSelectionPageState extends State<MediaSelectionPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        _selectedImage = File(photo.path);
      });
    }
  }

  Future<void> _chooseFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F4690), // Royal blue background
      appBar: AppBar(
        title: const Text('FinvisionAI',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0A2463),
          centerTitle: true,// Darker royal blue for AppBar
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedImage != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Text(
                    'Please scan the bill',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Camera Icon Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Color(0xFF1F4690),
                        size: 30,
                      ),
                      onPressed: _takePhoto,
                      padding: const EdgeInsets.all(15),
                    ),
                  ),

                  // Gallery Icon Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: IconButton(
                      icon: const Icon(
                        Icons.photo_library,
                        color: Color(0xFF1F4690),
                        size: 30,
                      ),
                      onPressed: _chooseFromGallery,
                      padding: const EdgeInsets.all(15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}