import 'package:app_scheduler/core/theme/app_color_config.dart';
import 'package:app_scheduler/core/theme/text_config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:r_icon_pro/r_icon_pro.dart';

import '../../domain/entities/schedule_entity.dart';
import 'action_button.dart';

class ScheduleCard extends StatelessWidget {
  final ScheduleEntity schedule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ScheduleCard({
    required this.schedule,
    required this.onEdit,
    required this.onDelete,
  });

  String _timeUntil() {
    final diff = schedule.scheduledTime.difference(DateTime.now());
    if (diff.isNegative) return 'Passed';
    if (diff.inDays > 0) return 'In ${diff.inDays}d ${diff.inHours.remainder(24)}h';
    if (diff.inHours > 0) return 'In ${diff.inHours}h ${diff.inMinutes.remainder(60)}m';
    return 'In ${diff.inMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final isPassed = schedule.scheduledTime.isBefore(DateTime.now());
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        // color: AppColor.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:AppColor.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [

                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    RIcon.Widget_,
                    color: AppColor.primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.appName,
                        style: AppText().bodyLarge,
                      ),
                      if (schedule.label != null)
                        Text(
                          schedule.label!,
                          style: AppText().bodyMedium.copyWith(color: AppColor.appWhite.withOpacity(0.4)),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPassed ? AppColor.primaryColor.withOpacity(0.1) : AppColor.secondaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _timeUntil(),
                    style: AppText().bodySmall.copyWith(color: isPassed ? AppColor.primaryColor :AppColor.secondaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: Colors.white.withOpacity(0.4),
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormat('MMM d, yyyy  •  hh:mm a').format(schedule.scheduledTime),
                  style: AppText().bodyMedium.copyWith(color: AppColor.appWhite.withOpacity(0.4)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ActionButton(
                    label: 'Edit',
                    icon: RIcon.Pen_New_Round,
                    color: AppColor.primaryColor,
                    onTap: onEdit,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ActionButton(
                    label: 'Delete',
                    icon: RIcon.Trash_Bin_Minimalistic,
                    color: AppColor.appRed,
                    onTap: onDelete,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}