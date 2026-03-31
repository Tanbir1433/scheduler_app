import 'package:flutter/services.dart';
import '../../domain/entities/app_info.dart';

class AppLocalDatasource {
  static const _channel = MethodChannel('com.example.app_scheduler/apps');

  Future<List<AppInfo>> getInstalledApps() async {
    final List result = await _channel.invokeMethod('getInstalledApps');
    return result.map((e) {
      final map = Map<String, dynamic>.from(e);
      return AppInfo(
        appName: map['appName'] ?? '',
        packageName: map['packageName'] ?? '',
        iconBase64: map['icon'],
      );
    }).toList();
  }

  Future<void> openApp(String packageName) async {
    await _channel.invokeMethod('openApp', {'packageName': packageName});
  }

  Future<List<Map<String, String>>> getPendingHistory() async {
    final String raw =
        await _channel.invokeMethod('getPendingHistory') ?? '';
    if (raw.isEmpty) return [];
    return raw.split('\n').where((e) => e.isNotEmpty).map((entry) {
      final parts = entry.split('|');
      return {
        'packageName': parts.length > 0 ? parts[0] : '',
        'appName': parts.length > 1 ? parts[1] : '',
        'label': parts.length > 2 ? parts[2] : '',
        'executedAt': parts.length > 3 ? parts[3] : '',
      };
    }).toList();
  }
}