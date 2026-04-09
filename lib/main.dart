import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/constants/app_constants.dart';
import 'data/datasources/history_local_datasource.dart';
import 'data/models/history_model.dart';
import 'data/models/schedule_model.dart';

void main() async {


  ///--------------------- Dependency init -------------------
  WidgetsFlutterBinding.ensureInitialized();


  await Hive.initFlutter();
  Hive.registerAdapter(ScheduleModelAdapter());
  Hive.registerAdapter(HistoryModelAdapter());
  await Hive.openBox<ScheduleModel>(AppConstants.schedulesBox);
  await Hive.openBox<HistoryModel>(HistoryLocalDatasource.boxName);



  runApp(const ProviderScope(child: AppSchedulerApp()));



}