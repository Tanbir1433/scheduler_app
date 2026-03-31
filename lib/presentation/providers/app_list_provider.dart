import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_info.dart';
import 'providers.dart';

final appListProvider = FutureProvider<List<AppInfo>>((ref) async {
  return ref.read(getInstalledAppsProvider).call();
});
