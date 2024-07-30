import 'package:flutter/material.dart';
import 'package:passtrackdash/colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mcgpalette0[50],
        title: const Text("Settings"),
      ),
      body: ListView(
        children: const [
          // System Configuration Section
          ExpansionTile(
            title: Text('System Configuration'),
            children: [
              ListTile(
                title: Text('Option 1'),
                // Add functionality here
              ),
              ListTile(
                title: Text('Option 2'),
                // Add functionality here
              ),
            ],
          ),

          // App Preferences Section
          ExpansionTile(
            title: Text('App Preferences'),
            children: [
              ListTile(
                title: Text('Preference 1'),
                // Add functionality here
              ),
              ListTile(
                title: Text('Preference 2'),
                // Add functionality here
              ),
            ],
          ),
        ],
      ),
    );
  }
}
