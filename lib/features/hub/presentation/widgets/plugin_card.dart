import 'package:flutter/material.dart';

class PluginCard extends StatelessWidget {
  const PluginCard({
    required this.title,
    required this.description,
    required this.quickStat,
    required this.onTap,
    super.key,
  });

  final String title;
  final String description;
  final String quickStat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.checklist_rounded, size: 28),
              const Spacer(),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(description),
              const SizedBox(height: 8),
              Text(
                quickStat,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
