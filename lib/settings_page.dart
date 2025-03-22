import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: const Color(0xFF00359E), // Dark blue color
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // General Settings Section
            ListTile(
              title: const Text('Theme'),
              subtitle: const Text('Change the app theme'),
              leading: const Icon(Icons.color_lens),
              onTap: () {
                // Action to change theme
              },
            ),
            ListTile(
              title: const Text('Notifications'),
              subtitle: const Text('Enable/Disable notifications'),
              leading: const Icon(Icons.notifications),
              onTap: () {
                // Action to toggle notifications
              },
            ),
            ListTile(
              title: const Text('Language'),
              subtitle: const Text('Change language preferences'),
              leading: const Icon(Icons.language),
              onTap: () {
                // Action to change language
              },
            ),
            // Other settings can be added below
            ListTile(
              title: const Text('User Agreement'),
              subtitle: const Text('More on licensing'),
              leading: const Icon(Icons.lock),
              onTap: () {
                // Action for privacy settings
              },
            ),
            // Add more settings options as needed
          ],
        ),
      ),
    );
  }
}