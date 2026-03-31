import 'dart:convert';

import 'package:app_scheduler/core/theme/app_color_config.dart';
import 'package:flutter/material.dart';

import '../../core/theme/text_config.dart';
import '../../domain/entities/app_info.dart';

class AppCard extends StatelessWidget {
  final AppInfo app;
  final VoidCallback onTap;

  const AppCard({required this.app, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          // color:AppColor.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            ///=========================== App Icon ===============================
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: app.iconBase64 != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        base64Decode(app.iconBase64!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.android,
                          color: AppColor.primaryColor,
                        ),
                      ),
                    )
                  : const Icon(Icons.android, color: AppColor.primaryColor),
            ),
            const SizedBox(width: 14),

            ///=========================== App Name and Package ===============================

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.appName,
                    style: AppText().bodyLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    app.packageName,
                    style: AppText().bodySmall.copyWith(color: AppColor.appWhite.withOpacity(0.4)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            ///=========================== Arrow Icon ===============================

            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withAlpha(40),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColor.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
