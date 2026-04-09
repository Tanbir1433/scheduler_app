import 'package:hive_flutter/hive_flutter.dart';
import '../models/schedule_model.dart';
import '../../core/constants/app_constants.dart';

class ScheduleLocalDatasource {




  ///---------------------- Get Schedule Data Box ------------------------

  Box<ScheduleModel> get _box => Hive.box<ScheduleModel>(AppConstants.schedulesBox);

  List<ScheduleModel> getAll() => _box.values.toList();

  Future<void> save(ScheduleModel model) => _box.put(model.id, model);

  Future<void> delete(String id) => _box.delete(id);
}