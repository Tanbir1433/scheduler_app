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
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF03DAC6),
          surface: Color(0xFF1A1A2E),
          background: Color(0xFF0A0A0F),
        ),
        useMaterial3: true,
        fontFamily: 'monospace',
      ),
      home: const SplashScreen(),
    );
  }
}