import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';

/* -- Light & Dark Elevated Button Themes -- */
class GCrabElevatedButtonTheme {
  GCrabElevatedButtonTheme._(); //To avoid creating instances


  /* -- Light Theme -- */
  static final lightElevatedButtonTheme  = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      minimumSize: const Size(350, 40),
      foregroundColor: GCrabColors.light,
      backgroundColor: GCrabColors.primary,
      disabledForegroundColor: GCrabColors.darkGrey,
      disabledBackgroundColor: GCrabColors.buttonDisabled,
      side: const BorderSide(color: GCrabColors.primary),
      padding: const EdgeInsets.symmetric(vertical: GCrabSizes.buttonHeight),
      textStyle: const TextStyle(fontSize: 16, color: GCrabColors.textWhite, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GCrabSizes.buttonRadius)),
    ),
  );

  /* -- Dark Theme -- */
  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      minimumSize: const Size(350, 40),
      foregroundColor: GCrabColors.light,
      backgroundColor: GCrabColors.primary,
      disabledForegroundColor: GCrabColors.darkGrey,
      disabledBackgroundColor: GCrabColors.darkerGrey,
      side: const BorderSide(color: GCrabColors.primary),
      padding: const EdgeInsets.symmetric(vertical: GCrabSizes.buttonHeight),
      textStyle: const TextStyle(fontSize: 16, color: GCrabColors.textWhite, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GCrabSizes.buttonRadius)),
    ),
  );
}
