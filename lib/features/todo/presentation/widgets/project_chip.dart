import 'package:flutter/material.dart';

class ProjectChip extends StatelessWidget {
  const ProjectChip({required this.projectName, super.key});

  final String projectName;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.folder_outlined, size: 16),
      label: Text(projectName),
    );
  }
}
