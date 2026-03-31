import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        gradient: LinearGradient(
          colors: isPassed
              ? [
            const Color(0xFF1A1A2E),
            const Color(0xFF16213E),
          ]
              : [
            const Color(0xFF1A1A2E),
            const Color(0xFF16213E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPassed ? Colors.white.withOpacity(0.05) : const Color(0xFF6C63FF).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isPassed ? Colors.transparent : const Color(0xFF6C63FF).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.apps_rounded,
                    color: isPassed ? Colors.white.withOpacity(0.3) : const Color(0xFF6C63FF),
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isPassed ? Colors.white.withOpacity(0.4) : Colors.white,
                        ),
                      ),
                      if (schedule.label != null)
                        Text(
                          schedule.label!,
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF03DAC6).withOpacity(0.8),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPassed ? Colors.white.withOpacity(0.05) : const Color(0xFF6C63FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _timeUntil(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isPassed ? Colors.white.withOpacity(0.3) : const Color(0xFF6C63FF),
                    ),
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
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ActionButton(
                  label: 'Edit',
                  icon: Icons.edit_rounded,
                  color: const Color(0xFF03DAC6),
                  onTap: onEdit,
                ),
                const SizedBox(width: 8),
                ActionButton(
                  label: 'Delete',
                  icon: Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  onTap: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}