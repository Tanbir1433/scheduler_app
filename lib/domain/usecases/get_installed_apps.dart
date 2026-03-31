import '../entities/app_info.dart';
import '../repositories/app_repository.dart';

class GetInstalledApps {
  final AppRepository repository;

  GetInstalledApps(this.repository);

  Future<List<AppInfo>> call() => repository.getInstalledApps();
}
