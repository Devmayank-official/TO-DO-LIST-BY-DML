class PluginInfo {
  const PluginInfo({
    required this.id,
    required this.displayName,
    required this.description,
    required this.route,
    required this.version,
    this.quickStatLabel,
  });

  final String id;
  final String displayName;
  final String description;
  final String route;
  final String version;
  final String? quickStatLabel;
}
