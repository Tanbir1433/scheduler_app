import '../../domain/entities/history_entity.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_local_datasource.dart';
import '../models/history_model.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryLocalDatasource datasource;

  HistoryRepositoryImpl(this.datasource);

  @override
  List<HistoryEntity> getHistory() {
    return datasource
        .getAll()
        .map((m) => HistoryEntity(
              id: m.id,
              appName: m.appName,
              packageName: m.packageName,
              executedAt: m.executedAt,
              label: m.label,
            ))
        .toList();
  }

  @override
  Future<void> addHistory(HistoryEntity entity) async {
    await datasource.save(HistoryModel(
      id: entity.id,
      appName: entity.appName,
      packageName: entity.packageName,
      executedAt: entity.executedAt,
      label: entity.label,
    ));
  }

  @override
  Future<void> clearHistory() => datasource.clear();
}
