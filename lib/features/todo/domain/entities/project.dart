class Project {
  const Project({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.color = '#4A90D9',
    this.icon = 'folder',
    this.isArchived = false,
  });

  final String id;
  final String name;
  final String? description;
  final String color;
  final String icon;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    String? icon,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
