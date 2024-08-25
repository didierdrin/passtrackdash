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
            title: Text('App Configuration'),
            children: [
              ListTile(
                title: Text('Light/Dark Mode'),
                // Add functionality here
              ),
              ListTile(
                title: Text('Notifications'),
                // Add functionality here
              ),
            ],
          ),

          // App Preferences Section
          ExpansionTile(
            title: Text('My Account'),
            children: [
              ListTile(
                title: Text('Profile'),
                // Add functionality here
              ),
              ListTile(
                title: Text('System users'),
                // Add functionality here
              ),
            ],
          ),
        ],
      ),
    );
  }
}
