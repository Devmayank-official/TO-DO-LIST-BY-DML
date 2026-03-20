import 'package:flutter/material.dart';

class TodoProjectsPage extends StatelessWidget {
  const TodoProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.folder_copy_outlined),
            title: Text('DML Hub'),
            subtitle: Text('1 active task'),
          ),
          ListTile(
            leading: Icon(Icons.folder_copy_outlined),
            title: Text('Personal'),
            subtitle: Text('0 active tasks'),
          ),
        ],
      ),
    );
  }
}
