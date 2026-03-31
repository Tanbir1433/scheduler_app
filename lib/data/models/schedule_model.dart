import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/schedule_entity.dart';

part 'schedule_model.freezed.dart';
part 'schedule_model.g.dart';

@freezed
@HiveType(typeId: 0)
class ScheduleModel with _$ScheduleModel {
  const factory ScheduleModel({
    @HiveField(0) required String id,
    @HiveField(1) required String appName,
    @HiveField(2) required String packageName,
    @HiveField(3) String? label,
    @HiveField(4) required DateTime scheduledTime,
    @HiveField(5) @Default(false) bool isRepeating,
  }) = _ScheduleModel;

  factory ScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleModelFromJson(json);
}

extension ScheduleModelX on ScheduleModel {
  ScheduleEntity toEntity() => ScheduleEntity(
    id: id,
    appName: appName,
    packageName: packageName,
    label: label,
    scheduledTime: scheduledTime,
    isRepeating: isRepeating,
  );

  static ScheduleModel fromEntity(ScheduleEntity e) => ScheduleModel(
    id: e.id,
    appName: e.appName,
    packageName: e.packageName,
    label: e.label,
    scheduledTime: e.scheduledTime,
    isRepeating: e.isRepeating,
  );
}