import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/app_local_datasource.dart';
import '../../data/datasources/history_local_datasource.dart';
import '../../data/datasources/schedule_local_datasource.dart';
import '../../data/repositories/app_repository_impl.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../data/repositories/schedule_repository_impl.dart';
import '../../domain/repositories/app_repository.dart';
import '../../domain/repositories/history_repository.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../../domain/usecases/check_conflict.dart';
import '../../domain/usecases/delete_schedule.dart';
import '../../domain/usecases/get_installed_apps.dart';
import '../../domain/usecases/get_schedules.dart';
import '../../domain/usecases/save_schedule.dart';

final appDatasourceProvider = Provider((_) => AppLocalDatasource());
final scheduleDatasourceProvider = Provider((_) => ScheduleLocalDatasource());
final historyDatasourceProvider = Provider((_) => HistoryLocalDatasource());

final appRepositoryProvider = Provider<AppRepository>(
  (ref) => AppRepositoryImpl(ref.read(appDatasourceProvider)),
);
final scheduleRepositoryProvider = Provider<ScheduleRepository>(
  (ref) => ScheduleRepositoryImpl(ref.read(scheduleDatasourceProvider)),
);
final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepositoryImpl(ref.read(historyDatasourceProvider)),
);

final getInstalledAppsProvider = Provider((ref) => GetInstalledApps(ref.read(appRepositoryProvider)));
final saveScheduleProvider = Provider((ref) => SaveSchedule(ref.read(scheduleRepositoryProvider)));
final getSchedulesProvider = Provider((ref) => GetSchedules(ref.read(scheduleRepositoryProvider)));
final deleteScheduleProvider = Provider((ref) => DeleteSchedule(ref.read(scheduleRepositoryProvider)));
final checkConflictProvider = Provider((ref) => CheckConflict(ref.read(scheduleRepositoryProvider)));
