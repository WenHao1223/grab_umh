import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';

/* -- Light & Dark Outlined Button Themes -- */
class GCrabOutlinedButtonTheme {
  GCrabOutlinedButtonTheme._(); //To avoid creating instances


  /* -- Light Theme -- */
  static final lightOutlinedButtonTheme  = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: GCrabColors.dark,
      side: const BorderSide(color: GCrabColors.borderPrimary),
      textStyle: const TextStyle(fontSize: 16, color: GCrabColors.black, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(vertical: GCrabSizes.buttonHeight, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GCrabSizes.buttonRadius)),
    ),
  );

  /* -- Dark Theme -- */
  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: GCrabColors.light,
      side: const BorderSide(color: GCrabColors.borderPrimary),
      textStyle: const TextStyle(fontSize: 16, color: GCrabColors.textWhite, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(vertical: GCrabSizes.buttonHeight, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GCrabSizes.buttonRadius)),
    ),
  );
}
