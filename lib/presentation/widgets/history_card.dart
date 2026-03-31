import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:r_icon_pro/r_icon_pro.dart';
import '../../core/theme/app_color_config.dart';
import '../../core/theme/text_config.dart';
import '../../domain/entities/history_entity.dart';
import '../providers/app_icon_provider.dart';

class HistoryCard extends ConsumerWidget {
  const HistoryCard({super.key, required this.item});

  final HistoryEntity item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconAsync = ref.watch(appIconProvider(item.packageName));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          /// ==================================  App Icon ==================================
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColor.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: iconAsync != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      base64Decode(iconAsync),
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(RIcon.Check_Circle, color: AppColor.primaryColor, size: 22),
                    ),
                  )
                : const Icon(RIcon.Check_Circle, color: AppColor.primaryColor, size: 22),
          ),

          /// ================== Date & Time ==================
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.appName, style: AppText().bodyLarge),
                if (item.label != null) Text(item.label!, style: AppText().bodyMedium.copyWith(color: AppColor.appWhite.withOpacity(0.4))),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, yyyy  •  hh:mm a').format(item.executedAt),
                  style: AppText().bodySmall.copyWith(color: AppColor.appWhite.withOpacity(0.4)),
                ),
              ],
            ),
          ),

          ///=========================== Status ==========================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColor.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text('Done', style: AppText().bodyMedium.copyWith(color: AppColor.primaryColor)),
          ),
        ],
      ),
    );
  }
}
