import 'package:app_scheduler/core/theme/app_color_config.dart';
import 'package:app_scheduler/core/theme/text_config.dart';
import 'package:flutter/material.dart';
import 'package:r_icon_pro/r_icon_pro.dart';

class ClearAllButton extends StatelessWidget {
  final VoidCallback onTap;

  const ClearAllButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColor.appRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.appRed.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(RIcon.Trash_Bin_Minimalistic, size: 16, color: AppColor.appRed),
            SizedBox(width: 6),
            Text('Clear', style: AppText().bodyMedium.copyWith(color: AppColor.appRed)),
          ],
        ),
      ),
    );
  }
}
