import 'package:flutter/material.dart';

class HubSettingsPage extends StatelessWidget {
  const HubSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hub Settings')),
      body: const ListTile(
        leading: Icon(Icons.info_outline),
        title: Text('DML Hub MVP'),
        subtitle: Text('Dark-first Android productivity platform.'),
      ),
    );
  }
}
