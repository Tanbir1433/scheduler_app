import '../entities/history_entity.dart';

abstract class HistoryRepository {
  List<HistoryEntity> getHistory();
  Future<void> addHistory(HistoryEntity entity);
  Future<void> clearHistory();
}