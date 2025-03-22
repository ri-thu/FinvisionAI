import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinvisionAI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MediaSelectionPage(),
    );
  }
}

class MediaSelectionPage extends StatefulWidget {
  const MediaSelectionPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MediaSelectionPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ExpenseScannerPage(),
    const InsightsPage(),
    const Center(child: Text("Budgets Page")),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
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

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  _InsightsPageState createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  String insights = "Press the button to get insights.";

  Future<void> fetchInsights() async {
    const url = "http://192.168.1.41:8000/generate_insights/"; // Replace with actual IP
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"expense_data": "Your expense details here"}),
      );

      if (response.statusCode == 200) {
        setState(() {
          insights = jsonDecode(response.body)['insights'] ?? "No insights found.";
        });
      } else {
        setState(() {
          insights = "Error: ${response.statusCode} - ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        insights = "Network Error: Failed to fetch insights.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Insights"),
        backgroundColor: const Color(0xFFB8B230),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                insights,
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: fetchInsights,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C0A7C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text("Get Insights"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

class ExpenseScannerPage extends StatefulWidget {
  const ExpenseScannerPage({Key? key}) : super(key: key);

  @override
  _ExpenseScannerPageState createState() => _ExpenseScannerPageState();
}

class _ExpenseScannerPageState extends State<ExpenseScannerPage> {
  File? _selectedImage;
  String _recognizedText = "";
  final ImagePicker _picker = ImagePicker();

  // Speech-to-Text instance
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _spokenText = "";
  bool _showFabOptions = false;
  String? _enteredText;
  bool _isExpense = true; // Default to expense mode

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

  // Function to pick an image from the gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      _performOCR(image);  // Perform OCR once the image is picked
    }
  }

  // Function to perform OCR on the selected image
  Future<void> _performOCR(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    final recognizedText = await textDetector.processImage(inputImage);

    setState(() {
      _recognizedText = recognizedText.text;  // Update the recognized text
    });
  }

  /// Starts voice input (speech recognition) with pulsating UI
  void _startVoiceInput() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          print('Speech Status: $status');
          if (status == 'done' || status == 'notListening') {
            _stopVoiceInput();
          }
        },
        onError: (error) {
          print('Speech Error: $error');
          _stopVoiceInput();
        },
      );

      if (available) {
        setState(() => _isListening = true);
        _showVoicePopup();
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

  /// Build FAB Options
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
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool hasImageOrText = _selectedImage != null || _spokenText.isNotEmpty || (_enteredText != null && _enteredText!.isNotEmpty) || _recognizedText.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,

      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the content
          children: [
            // Expense label on the left (clickable)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpense = true; // Set the state to Expense when tapped
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Add padding inside the container
                decoration: BoxDecoration(
                  color: _isExpense ? theme.colorScheme.primary : Colors.transparent, // Highlight if selected
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                ),
                child: Text(
                  'Expense',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isExpense ? Colors.white : Colors.white70, // White text for selected, lighter for unselected
                  ),
                ),
              ),
            ),

            const SizedBox(width: 20), // Add some space between the labels

            // Income label on the right (clickable)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpense = false; // Set the state to Income when tapped
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Add padding inside the container
                decoration: BoxDecoration(
                  color: !_isExpense ? theme.colorScheme.primary : Colors.transparent, // Highlight if selected
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                ),
                child: Text(
                  'Income',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: !_isExpense ? Colors.white : Colors.white70, // White text for selected, lighter for unselected
                  ),
                ),
              ),
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
                _recognizedText.isNotEmpty ? _recognizedText :
                _spokenText.isNotEmpty ? _spokenText :
                (_enteredText ?? ""),
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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _showFabOptions
                ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildFabOption(Icons.mic, _startVoiceInput, "Voice", theme.colorScheme.primaryContainer),
                _buildFabOption(Icons.text_fields, _enterTextManually, "Text", theme.colorScheme.secondaryContainer),
                _buildFabOption(Icons.camera_alt, () => _pickImage(ImageSource.camera), "Camera", theme.colorScheme.tertiaryContainer),
                _buildFabOption(Icons.photo_library, () => _pickImage(ImageSource.gallery), "Gallery", theme.colorScheme.primaryContainer),
              ],
            )
                : const SizedBox.shrink(), // Smooth hiding
          ),
          FloatingActionButton(
            backgroundColor: theme.colorScheme.primary,
            child: Icon(_showFabOptions ? Icons.close : Icons.add, color: theme.colorScheme.onPrimary),
            onPressed: () => setState(() => _showFabOptions = !_showFabOptions),
          ),
        ],
      ),
    );
  }
}