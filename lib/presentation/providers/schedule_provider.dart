import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/schedule_entity.dart';
import 'providers.dart';

final scheduleListProvider = AsyncNotifierProvider<ScheduleNotifier, List<ScheduleEntity>>(
  ScheduleNotifier.new,
);

class ScheduleNotifier extends AsyncNotifier<List<ScheduleEntity>> {
  @override
  Future<List<ScheduleEntity>> build() async {
    return ref.read(getSchedulesProvider).call();
  }

  Future<void> save(ScheduleEntity schedule) async {
    await ref.read(saveScheduleProvider).call(schedule);
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    await ref.read(deleteScheduleProvider).call(id);
    ref.invalidateSelf();
  }
}
