class ScheduleEntity {
  final String id;
  final String appName;
  final String packageName;
  final String? label;
  final DateTime scheduledTime;
  final bool isRepeating;

  const ScheduleEntity({
    required this.id,
    required this.appName,
    required this.packageName,
    this.label,
    required this.scheduledTime,
    this.isRepeating = false,
  });
}