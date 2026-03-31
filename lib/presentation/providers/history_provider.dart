import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/history_entity.dart';
import 'providers.dart';

final historyProvider = NotifierProvider<HistoryNotifier, List<HistoryEntity>>(
  HistoryNotifier.new,
);

class HistoryNotifier extends Notifier<List<HistoryEntity>> {
  @override
  List<HistoryEntity> build() {
    return ref.read(historyRepositoryProvider).getHistory();
  }

  Future<void> add(HistoryEntity entity) async {
    await ref.read(historyRepositoryProvider).addHistory(entity);
    state = ref.read(historyRepositoryProvider).getHistory();
  }

  Future<void> clear() async {
    await ref.read(historyRepositoryProvider).clearHistory();
    state = [];
  }
}
