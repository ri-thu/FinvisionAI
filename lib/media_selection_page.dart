import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:io';

class MediaSelectionPage extends StatefulWidget {
  const MediaSelectionPage({Key? key}) : super(key: key);

  @override
  _MediaSelectionPageState createState() => _MediaSelectionPageState();
}

class _MediaSelectionPageState extends State<MediaSelectionPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String? _enteredText;

  // Speech-to-Text instance
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _spokenText = "";

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  /// Initialize Speech Recognition
  void _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech Status: $status'),
      onError: (error) => print('Speech Error: $error'),
    );

    if (!available) {
      print("Speech recognition is NOT available ❌");
    }
  }

  /// Handles Image Selection
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  /// Starts voice input (speech recognition)
  void _startVoiceInput() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('Speech Status: $status'),
        onError: (error) => print('Speech Error: $error'),
      );

      if (available) {
        setState(() => _isListening = true);

        _speech.listen(
          onResult: (result) {
            setState(() {
              _spokenText = result.recognizedWords;
            });
            print("Recognized words: $_spokenText");
          },
        );
      } else {
        print("Speech recognition is NOT available ❌");
      }
    } else {
      _stopVoiceInput();
    }
  }

  /// Stops voice input (stops listening)
  void _stopVoiceInput() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  /// Manual Text Entry
  void _enterTextManually() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String tempText = _enteredText ?? "";
        return AlertDialog(
          title: const Text("Enter Text"),
          content: TextField(
            onChanged: (value) => tempText = value,
            decoration: const InputDecoration(hintText: "Enter bill details"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _enteredText = tempText;
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed, String label) {
    return Column(
      children: [
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
          child: IconButton(
            icon: Icon(icon, color: const Color(0xFF1F4690), size: 30),
            onPressed: onPressed,
            padding: const EdgeInsets.all(15),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasImageOrText = _selectedImage != null || _spokenText.isNotEmpty || (_enteredText != null && _enteredText!.isNotEmpty);

    return Scaffold(
      backgroundColor: const Color(0xFF1F4690),
      appBar: AppBar(
        title: const Text(
          'FinvisionAI',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0A2463),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          hasImageOrText
              ? Flexible(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _selectedImage != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
              )
                  : Text(
                _spokenText.isNotEmpty ? _spokenText : (_enteredText ?? ""),
                style: const TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          )
              : Expanded(
            child: Center(
              child: Text(
                'Please scan the bill or enter details',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                _buildIconButton(Icons.camera_alt, () => _pickImage(ImageSource.camera), "Camera"),
                _buildIconButton(Icons.photo_library, () => _pickImage(ImageSource.gallery), "Gallery"),
                _buildIconButton(
                  _isListening ? Icons.mic_off : Icons.mic,
                  _startVoiceInput,
                  "Voice",
                ),
                _buildIconButton(Icons.text_fields, _enterTextManually, "Text"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}