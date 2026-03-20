import 'package:flutter/material.dart';

class TodoSettingsPage extends StatelessWidget {
  const TodoSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do Settings')),
      body: ListView(
        children: const [
          SwitchListTile(
            value: false,
            onChanged: null,
            title: Text('Biometric lock'),
            subtitle: Text('Available when device authentication is configured.'),
          ),
        ],
      ),
    );
  }
}
