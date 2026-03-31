import 'package:app_scheduler/core/theme/app_color_config.dart';
import 'package:app_scheduler/core/theme/text_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:r_icon_pro/r_icon_pro.dart';
import '../providers/schedule_provider.dart';
import '../widgets/schedule_card.dart';
import 'app_discovery_screen.dart';
import 'schedule_form_screen.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(scheduleListProvider);

    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///======================== Header ======================

            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Schedules',
                        style: AppText().headerLine1,
                      ),
                      Text(
                        DateFormat('EEEE, MMM d').format(DateTime.now()),
                        style: AppText().bodyMedium.copyWith(color: AppColor.appWhite.withAlpha(100)),
                      ),
                    ],
                  ),

                  ///======================== Add Schedule Button ======================
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AppDiscoveryScreen(isSelecting: true),
                      ),
                    ),
                    // ).then((_) => ref.invalidate(scheduleListProvider)),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColor.secondaryColor, AppColor.primaryColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(RIcon.Add_Circle, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),


            ///======================== Schedule List ======================

            Expanded(
              child: schedulesAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColor.primaryColor),
                  ),
                ),
                error: (e, _) => Center(
                  child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
                ),
                data: (schedules) {
                  if (schedules.isEmpty) {
                    return Center(
                      child: Text(
                        'No History Yet',
                        style: AppText().bodyMedium.copyWith(color: AppColor.appWhite.withOpacity(0.6)),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: schedules.length,
                    itemBuilder: (_, i) => ScheduleCard(
                      schedule: schedules[i],
                      onEdit: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScheduleFormScreen(
                            existing: schedules[i],
                          ),
                        ),
                      ).then((_) => ref.invalidate(scheduleListProvider)),
                      onDelete: () => ref.read(scheduleListProvider.notifier).delete(schedules[i].id),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
