import 'package:app_scheduler/core/theme/app_color_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:r_icon_pro/r_icon_pro.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/app_local_datasource.dart';
import '../../domain/entities/history_entity.dart';
import '../providers/history_provider.dart';
import '../providers/schedule_provider.dart';
import '../widgets/nav_item.dart';
import 'schedule_screen.dart';
import 'app_discovery_screen.dart';
import 'history_screen.dart';

class MainNavScreen extends ConsumerStatefulWidget {
  const MainNavScreen({super.key});

  @override
  ConsumerState<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends ConsumerState<MainNavScreen> with WidgetsBindingObserver {



  int _currentIndex = 0;
  final _datasource = AppLocalDatasource();

  final _screens = const [
    ScheduleScreen(),
    AppDiscoveryScreen(),
    HistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPendingHistory();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPendingHistory();
    }
  }

  Future<void> _checkPendingHistory() async {
    try {
      final pending = await _datasource.getPendingHistory();
      for (final item in pending) {
        final executedAt = item['executedAt'] != null && item['executedAt']!.isNotEmpty
            ? DateTime.fromMillisecondsSinceEpoch(int.tryParse(item['executedAt']!) ?? 0)
            : DateTime.now();

        await ref.read(historyProvider.notifier).add(
              HistoryEntity(
                id: const Uuid().v4(),
                appName: item['appName'] ?? '',
                packageName: item['packageName'] ?? '',
                executedAt: executedAt,
                label: item['label']?.isEmpty == true ? null : item['label'],
              ),
            );
      }
      if (pending.isNotEmpty) {
        ref.invalidate(scheduleListProvider);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {


    ///======================== Body ======================

    return Scaffold(
      backgroundColor: AppColor.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      ///======================== Nav Items ======================

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColor.background,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NavItem(
                  icon: RIcon.Calendar,
                  label: 'Schedule',
                  isActive: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                NavItem(
                  icon: RIcon.Widget_,
                  label: 'Apps',
                  isActive: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                NavItem(
                  icon: Icons.history_rounded,
                  label: 'History',
                  isActive: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

