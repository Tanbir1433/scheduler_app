import 'package:app_scheduler/core/theme/app_color_config.dart';
import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        width: 38,
        height: 38,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColor.iconBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColor.appWhite,
          size: 18,
        ),
      ),
    );
  }
}
