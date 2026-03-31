import '../entities/app_info.dart';

abstract class AppRepository {
  Future<List<AppInfo>> getInstalledApps();
  Future<void> openApp(String packageName);
}