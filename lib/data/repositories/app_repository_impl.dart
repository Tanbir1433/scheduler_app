import '../../domain/entities/app_info.dart';
import '../../domain/repositories/app_repository.dart';
import '../datasources/app_local_datasource.dart';

class AppRepositoryImpl implements AppRepository {
  final AppLocalDatasource datasource;

  AppRepositoryImpl(this.datasource);

  @override
  Future<List<AppInfo>> getInstalledApps() => datasource.getInstalledApps();

  @override
  Future<void> openApp(String packageName) => datasource.openApp(packageName);
}
