import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter/animation.dart';

class PulsatingMicButton extends StatefulWidget {
  final VoidCallback onTap;
  const PulsatingMicButton({Key? key, required this.onTap}) : super(key: key);

  @override
  _PulsatingMicButtonState createState() => _PulsatingMicButtonState();
  }

  class _PulsatingMicButtonState extends State<PulsatingMicButton>
  with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
  super.initState();
  _controller = AnimationController(
  vsync: this,
  duration: const Duration(seconds: 1),
  )..repeat(reverse: true);

  _animation = Tween<double>(begin: 1.0, end: 1.3).animate(
  CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );
  }

  @override
  void dispose() {
  _controller.dispose();
  super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  return GestureDetector(
  onTap: widget.onTap,
  child: AnimatedBuilder(
  animation: _animation,
  builder: (context, child) {
  return Transform.scale(
  scale: _animation.value,
  child: Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
  shape: BoxShape.circle,
  color: Colors.red.withOpacity(0.8),
  boxShadow: [
  BoxShadow(
  color: Colors.red.withOpacity(0.5),
  blurRadius: 10,
  spreadRadius: 2,
  ),
  ],
  ),
  child: const Icon(Icons.mic, size: 50, color: Colors.white),
  ),
  );
  },
  ),
  );
  }
  }

  class MediaSelectionPage extends StatefulWidget {
  const MediaSelectionPage({Key? key}) : super(key: key);

  @override
  _MediaSelectionPageState createState() => _MediaSelectionPageState();
  }

  class _MediaSelectionPageState extends State<MediaSelectionPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String? _enteredText;

  bool _isExpense = true;

  // Speech-to-Text instance
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _spokenText = "";
  bool _showFabOptions = false; // Controls FAB expansion

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
  /// Starts voice input (speech recognition) with pulsating UI
  void _startVoiceInput() async {
  if (!_isListening) {
  bool available = await _speech.initialize(
  onStatus: (status) => print('Speech Status: $status'),
  onError: (error) => print('Speech Error: $error'),
  );

  if (available) {
  setState(() => _isListening = true);
  _showVoicePopup(); // Show the voice dialog when starting speech input

  _speech.listen(
  onResult: (result) {
  setState(() {
  _spokenText = result.recognizedWords;
  });
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
  Navigator.pop(context); // Close the voice popup when stopping
  }

  /// Displays a pop-up dialog with a pulsating microphone
  void _showVoicePopup() {
  showDialog(
  context: context,
  barrierDismissible: false, // Prevents accidental dismissals
  builder: (BuildContext context) {
  return Dialog(
  backgroundColor: Colors.black.withOpacity(0.8),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
  child: Padding(
  padding: const EdgeInsets.all(20.0),
  child: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
  const Text(
  "Listening...",
  style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
  ),
  const SizedBox(height: 20),
  PulsatingMicButton(onTap: _stopVoiceInput), // Custom mic animation
  const SizedBox(height: 10),
  const Text(
  "Tap to stop recording",
  style: TextStyle(fontSize: 14, color: Colors.white70),
  ),
  ],
  ),
  ),
  );
  },
  );
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
  onPressed: () => Navigator.pop(context),
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

  /// **Build FAB Options**
  Widget _buildFabOption(IconData icon, VoidCallback onPressed, String label, Color backgroundColor) {
  return Column(
  children: [
  FloatingActionButton(
  mini: true,
  backgroundColor: backgroundColor,
  child: Icon(icon, color: Colors.black),
  onPressed: () {
  setState(() => _showFabOptions = false);
  onPressed();
  },
  ),
  const SizedBox(height: 4),
  Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
  ],
  );
  }

  @override
  Widget build(BuildContext context) {
  final theme = Theme.of(context);
  bool hasImageOrText = _selectedImage != null || _spokenText.isNotEmpty || (_enteredText != null && _enteredText!.isNotEmpty);

  return Scaffold(
  backgroundColor: theme.colorScheme.background,

    appBar: AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Expense',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Switch(
            value: !_isExpense,
            onChanged: (value) {
              setState(() {
                _isExpense = !value; // Toggle between Expense & Income
              });
            },
            activeColor: theme.colorScheme.primary,
          ),
          const Text(
            'Income',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
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
  style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onBackground),
  textAlign: TextAlign.center,
  ),
  ),
  )
      : Expanded(
  child: Center(
  child: Text(
  'Please scan the bill or enter details',
  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.8)),
  ),
  ),
  ),
  ],
  ),

  /// **Floating Action Button (FAB)**
  floatingActionButton: Column(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
  if (_showFabOptions) ...[
  _buildFabOption(Icons.mic, _startVoiceInput, "Voice", theme.colorScheme.primaryContainer),
  _buildFabOption(Icons.text_fields, _enterTextManually, "Text", theme.colorScheme.secondaryContainer),
  _buildFabOption(Icons.camera_alt, () => _pickImage(ImageSource.camera), "Camera", theme.colorScheme.tertiaryContainer),
  _buildFabOption(Icons.photo_library, () => _pickImage(ImageSource.gallery), "Gallery", theme.colorScheme.primaryContainer),
  ],
  FloatingActionButton(
  backgroundColor: theme.colorScheme.primary,
  child: Icon(_showFabOptions ? Icons.close : Icons.add, color: theme.colorScheme.onPrimary),
  onPressed: () => setState(() => _showFabOptions = !_showFabOptions),
  ),
  ],
  ),

  /// **Bottom Navigation Bar**
  bottomNavigationBar: NavigationBar(
  backgroundColor: theme.colorScheme.surfaceVariant,
  destinations: const [
  NavigationDestination(icon: Icon(Icons.home), label: 'Transactions'),
  NavigationDestination(icon: Icon(Icons.credit_card), label: 'Insights'),
  NavigationDestination(icon: Icon(Icons.pie_chart), label: 'Budgets'),
  NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
  ],
  ),
  );
  }
}