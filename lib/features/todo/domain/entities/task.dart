enum TaskPriority { none, low, medium, high }

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.priority = TaskPriority.none,
    this.dueDate,
    this.projectName,
    this.isCompleted = false,
    this.isPinned = false,
  });

  final String id;
  final String title;
  final String? description;
  final TaskPriority priority;
  final DateTime? dueDate;
  final String? projectName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompleted;
  final bool isPinned;

  bool get isDueToday {
    if (dueDate == null) {
      return false;
    }

    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  bool get isOverdue {
    if (dueDate == null || isCompleted) {
      return false;
    }

    return dueDate!.isBefore(DateTime.now());
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    DateTime? dueDate,
    String? projectName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
    bool? isPinned,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      projectName: projectName ?? this.projectName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
