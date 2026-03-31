
import 'package:app_scheduler/core/theme/app_color_config.dart';
import 'package:app_scheduler/core/theme/text_config.dart';
import 'package:flutter/material.dart';

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColor.primaryColor : AppColor.appWhite.withOpacity(0.8),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppText().bodyMedium.copyWith(
              color: isActive ? AppColor.primaryColor : AppColor.appWhite.withOpacity(0.8),
            )
          ),
        ],
      ),
    );
  }
}