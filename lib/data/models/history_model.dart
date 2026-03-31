import 'package:hive_flutter/hive_flutter.dart';

part 'history_model.g.dart';

@HiveType(typeId: 1)
class HistoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String appName;

  @HiveField(2)
  final String packageName;

  @HiveField(3)
  final DateTime executedAt;

  @HiveField(4)
  final String? label;

  HistoryModel({
    required this.id,
    required this.appName,
    required this.packageName,
    required this.executedAt,
    this.label,
  });
}