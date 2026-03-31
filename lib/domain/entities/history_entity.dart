class HistoryEntity {
  final String id;
  final String appName;
  final String packageName;
  final DateTime executedAt;
  final String? label;

  const HistoryEntity({
    required this.id,
    required this.appName,
    required this.packageName,
    required this.executedAt,
    this.label,
  });
}