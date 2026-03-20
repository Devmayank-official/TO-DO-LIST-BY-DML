import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TaskCheckbox extends StatelessWidget {
  const TaskCheckbox({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: value,
      onChanged: onChanged,
    ).animate(target: value ? 1 : 0).scale(duration: 250.ms);
  }
}
