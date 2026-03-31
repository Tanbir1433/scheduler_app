import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/app_local_datasource.dart';

final allAppIconsProvider = FutureProvider<Map<String, String?>>((ref) async {
  final datasource = AppLocalDatasource();
  final apps = await datasource.getInstalledApps();
  return {for (final app in apps) app.packageName: app.iconBase64};
});

final appIconProvider = Provider.family<String?, String>((ref, packageName) {
  final iconsMap = ref.watch(allAppIconsProvider);
  return iconsMap.maybeWhen(data: (map) => map[packageName], orElse: () => null);
});
