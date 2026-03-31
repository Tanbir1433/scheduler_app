import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/schedule_entity.dart';

class ScheduleTile extends StatelessWidget {
  final ScheduleEntity schedule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ScheduleTile({
    super.key,
    required this.schedule,
    required this.onEdit,
    required this.onDelete,
  });

  String _timeUntil(DateTime dt) {
    final diff = dt.difference(DateTime.now());
    if (diff.isNegative) return 'Passed';
    if (diff.inHours > 0) return 'In ${diff.inHours}h ${diff.inMinutes.remainder(60)}m';
    return 'In ${diff.inMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(schedule.appName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (schedule.label != null)
              Text(schedule.label!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.blueGrey),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, yyyy – hh:mm a').format(schedule.scheduledTime),
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '⏰ Next: ${_timeUntil(schedule.scheduledTime)}',
              style: const TextStyle(fontSize: 12, color: Colors.teal),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: onEdit, child: const Text('Edit')),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}