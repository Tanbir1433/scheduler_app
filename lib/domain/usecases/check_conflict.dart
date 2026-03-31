import '../repositories/schedule_repository.dart';

class CheckConflict {
  final ScheduleRepository repository;

  CheckConflict(this.repository);

  bool call(DateTime time, {String? excludeId}) => repository.hasConflict(time, excludeId: excludeId);
}
