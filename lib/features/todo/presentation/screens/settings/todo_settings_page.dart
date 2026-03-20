import 'package:flutter/material.dart';

class TodoSettingsPage extends StatelessWidget {
  const TodoSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do Settings')),
      body: ListView(
        children: const [
          ListTile(
            title: Text('Default priority'),
            subtitle: Text('None'),
          ),
          ListTile(
            title: Text('Notification offset'),
            subtitle: Text('30 minutes before due time'),
          ),
          SwitchListTile(
            value: true,
            onChanged: null,
            title: Text('Show completed tasks'),
          ),
          ListTile(
            title: Text('Clear completed tasks'),
            subtitle: Text('Destructive action placeholder for MVP persistence pass'),
          ),
        ],
      ),
    );
  }
}
