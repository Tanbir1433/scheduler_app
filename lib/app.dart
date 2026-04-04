import 'package:app_scheduler/core/theme/app_color_config.dart';
import 'package:flutter/material.dart';
import 'presentation/screens/splash_screen.dart';

class AppSchedulerApp extends StatelessWidget {
  const AppSchedulerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Scheduler',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColor.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColor.secondaryColor,
          secondary: AppColor.primaryColor,
          surface: AppColor.bgLight,
        ),
        useMaterial3: true,
        fontFamily: 'monospace',
      ),
      home: const SplashScreen(),
    );
  }
}