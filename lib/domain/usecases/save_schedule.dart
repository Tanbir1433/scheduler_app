import '../entities/schedule_entity.dart';
import '../repositories/schedule_repository.dart';

class SaveSchedule {
  final ScheduleRepository repository;

  SaveSchedule(this.repository);

  Future<void> call(ScheduleEntity schedule) => repository.saveSchedule(schedule);
}
