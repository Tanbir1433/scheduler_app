import 'package:hive_flutter/hive_flutter.dart';
import '../models/history_model.dart';

class HistoryLocalDatasource {
  static const boxName = 'history_box';

  Box<HistoryModel> get _box => Hive.box<HistoryModel>(boxName);

  List<HistoryModel> getAll() {
    final list = _box.values.toList();
    list.sort((a, b) => b.executedAt.compareTo(a.executedAt));
    return list;
  }

  Future<void> save(HistoryModel model) => _box.put(model.id, model);

  Future<void> clear() => _box.clear();
}