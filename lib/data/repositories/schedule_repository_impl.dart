import 'package:flutter/services.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_local_datasource.dart';
import '../models/schedule_model.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleLocalDatasource datasource;


  ///---------------------- Android label calling ------------------------
  static const _channel = MethodChannel('com.example.app_scheduler/apps');

  ScheduleRepositoryImpl(this.datasource);


  ///---------------------- Get Schedule ------------------------

  @override
  Future<List<ScheduleEntity>> getSchedules() async {
    return datasource.getAll().map((m) => m.toEntity()).toList()..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  ///---------------------- Save Schedule ------------------------

  @override
  Future<void> saveSchedule(ScheduleEntity schedule) async {
    await datasource.save(ScheduleModelX.fromEntity(schedule));
    final alarmId = schedule.id.hashCode.abs() % 2147483647;
    await _channel.invokeMethod('scheduleAlarm', {
      'alarmId': alarmId,
      'packageName': schedule.packageName,
      'appName': schedule.appName,
      'triggerMs': schedule.scheduledTime.millisecondsSinceEpoch,
    });
  }


  ///---------------------- Delete Schedule ------------------------

  @override
  Future<void> deleteSchedule(String id) async {
    await datasource.delete(id);
    final alarmId = id.hashCode.abs() % 2147483647;
    await _channel.invokeMethod('cancelAlarm', {'alarmId': alarmId});
  }


  ///---------------------- Has Conflict Schedule ------------------------

  @override
  bool hasConflict(DateTime time, {String? excludeId}) {
    return datasource.getAll().any((s) =>
        s.id != excludeId &&
        s.scheduledTime.year == time.year &&
        s.scheduledTime.month == time.month &&
        s.scheduledTime.day == time.day &&
        s.scheduledTime.hour == time.hour &&
        s.scheduledTime.minute == time.minute);
  }
}
