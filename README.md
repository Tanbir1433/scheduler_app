📱 App Scheduler

A Flutter app that lets you schedule any installed Android app to launch automatically at a specific time.


 ✨ Features

- 📋 View all installed apps on your device
- ⏰ Schedule any app to open at a specific date & time
- ⚡ Conflict detection — prevents two apps scheduled at the same time
- ✏️ Edit and delete schedules
- 🔔 Background notification when scheduled time arrives
- 🚀 Auto-launch when app is in foreground
- 📜 History of completed schedules


 🛠️ Tech Stack

| Framework | Flutter |
| Language | Dart + Kotlin |
| State Management | Riverpod |
| Database | Hive |
| Architecture | Clean Architecture |
| Background | Native Android AlarmManager |



📁 Folder Structure


lib/
├── main.dart
├── app.dart
├── core/constants/
├── data/
│   ├── datasources/       # Hive & Platform Channel data sources
│   ├── models/            # Hive models (Freezed)
│   └── repositories/      # Repository implementations
├── domain/
│   ├── entities/          # Pure data classes
│   ├── repositories/      # Abstract interfaces
│   └── usecases/          # Single-responsibility use cases
└── presentation/
    ├── providers/          # Riverpod providers
    └── screens/            # UI screens

android/app/src/main/kotlin/
└── MainActivity.kt         # Native app list, alarm & notification logic


🚀 Getting Started

Prerequisites

- Flutter SDK `>=3.0.0`
- Android device or emulator (API 21+)
- Java 17

Installation

bash
1. Clone the repo
git clone https://github.com/Tanbir1433/scheduler_app
cd app_scheduler

2. Install packages
flutter pub get

3. Generate Hive & Freezed files
flutter pub run build_runner build --delete-conflicting-outputs

4. Run the app
flutter run


First Launch Setup

When the app opens for the first time:

1. Allow notification permission when prompted
2. Allow battery optimization bypass when prompted
3. On Samsung devices → `Settings → Apps → App Scheduler → Battery → Unrestricted`



- Android only — iOS is not supported
- Android 12+ — Direct background app launch is blocked by the OS. A tap-to-open notification is shown instead
- Samsung devices — May require manual battery settings for reliable background execution


Challenges & Solutions

Third-party app list packages were outdated | Built a custom Platform Channel in Kotlin 
Background app launch blocked on Android 12+ | Used Foreground Service + Notification 
Samsung aggressively killing background service | WakeLock + Battery optimization bypass 
Notification not showing after reinstall | Deleted broken channels, added `POST_NOTIFICATIONS` permission 
