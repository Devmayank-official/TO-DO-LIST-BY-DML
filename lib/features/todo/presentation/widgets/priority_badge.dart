import 'package:flutter/material.dart';

import 'package:dml_hub/core/theme/app_colors.dart';
import 'package:dml_hub/features/todo/domain/entities/task.dart';

class PriorityBadge extends StatelessWidget {
  const PriorityBadge({required this.priority, super.key});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (priority) {
      TaskPriority.high => AppColors.error,
      TaskPriority.medium => AppColors.warning,
      TaskPriority.low => AppColors.success,
      TaskPriority.none => AppColors.dmlBlue,
    };

    return Chip(
      label: Text(priority.name),
      backgroundColor: color.withOpacity(0.15),
      side: BorderSide(color: color),
    );
  }
}
