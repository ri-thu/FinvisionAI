import 'package:flutter/material.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({Key? key}) : super(key: key);

  @override
  _InsightsPageState createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  String insights = "Fetching insights...";

  @override
  void initState() {
    super.initState();
    fetchInsights();
  }

  Future<void> fetchInsights() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          insights = "Here are your insights!";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          insights = "Failed to fetch insights.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Insights Page"),
        backgroundColor: const Color(0xFF112363),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              insights,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Text(
                  "Chart functionality has been removed.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}