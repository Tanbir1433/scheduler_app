import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_color_config.dart';

class AppText {
  TextStyle headerLine1 = GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w600, color: AppColor.appWhite);
  TextStyle headerLine2 = GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w500, color: AppColor.appWhite);
  TextStyle headerLine3 = GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColor.appWhite);
  TextStyle headerLine4 = GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.appWhite);
  TextStyle headerLine5 = GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w900, color: AppColor.appWhite);
  TextStyle bodyLarge = GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColor.appWhite);
  TextStyle bodyMedium = GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: AppColor.appWhite);
  TextStyle bodyMediumBold = GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColor.appWhite);
  TextStyle bodySmall = GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.normal, color: AppColor.appWhite);
}
