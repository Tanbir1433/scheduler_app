import '../entities/schedule_entity.dart';
import '../repositories/schedule_repository.dart';

class GetSchedules {
  final ScheduleRepository repository;

  GetSchedules(this.repository);

  Future<List<ScheduleEntity>> call() => repository.getSchedules();
}
