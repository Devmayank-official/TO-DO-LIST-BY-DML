class Tag {
  const Tag({
    required this.id,
    required this.name,
    required this.createdAt,
    this.color = '#4A90D9',
  });

  final String id;
  final String name;
  final String color;
  final DateTime createdAt;
}
