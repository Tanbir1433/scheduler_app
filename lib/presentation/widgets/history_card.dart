import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:r_icon_pro/r_icon_pro.dart';

import '../../core/theme/app_color_config.dart';
import '../../core/theme/text_config.dart';
import '../../domain/entities/history_entity.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({
    super.key,
    required this.item,
  });

  final HistoryEntity item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              RIcon.Check_Circle,
              color: AppColor.primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.appName,
                  style: AppText().bodyLarge,
                ),
                if (item.label != null)
                  Text(
                    item.label!,
                    style: AppText().bodyLarge,
                  ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, yyyy  •  hh:mm a').format(item.executedAt),
                  style: AppText().bodySmall.copyWith(color: AppColor.appWhite.withOpacity(0.4)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Done',
              style: AppText().bodyMedium.copyWith(color: AppColor.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
