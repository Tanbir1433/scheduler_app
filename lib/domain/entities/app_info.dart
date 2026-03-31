class AppInfo {
  final String appName;
  final String packageName;
  final String? iconBase64;

  const AppInfo({
    required this.appName,
    required this.packageName,
    this.iconBase64,
  });
}