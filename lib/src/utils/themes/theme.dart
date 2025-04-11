import 'package:flutter/material.dart';
import '../../utils/constants/colors.dart';
import 'custome_themes/bottom_sheet_theme.dart';
import 'custome_themes/checkbox_theme.dart';
import 'custome_themes/chip_theme.dart';
import 'custome_themes/elevated_button_theme.dart';
import 'custome_themes/outlined_button_theme.dart';
import 'custome_themes/text_field_theme.dart';
import 'custome_themes/text_theme.dart';
import 'custome_themes/appbar_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class GCrabAppTheme {
  GCrabAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.roboto().fontFamily,
    disabledColor: GCrabColors.grey,
    brightness: Brightness.light,
    primaryColor: GCrabColors.primary,
    textTheme: GCrabTextTheme.lightTextTheme,
    chipTheme: GCrabChipTheme.lightChipTheme,
    scaffoldBackgroundColor: GCrabColors.white,
    elevatedButtonTheme: GCrabElevatedButtonTheme.lightElevatedButtonTheme,
    appBarTheme: GCrabAppBarTheme.lightAppBarTheme,
    bottomSheetTheme: GCrabBottomSheetTheme.lightBottomSheetTheme,
    checkboxTheme: GCrabCheckboxTheme.lightCheckboxTheme,
    outlinedButtonTheme: GCrabOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: GCrabTextFormFieldTheme.lightInputDecorationTheme,
    colorScheme: ColorScheme.fromSeed(seedColor: GCrabColors.primary, brightness: Brightness.light),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.roboto().fontFamily,
    disabledColor: GCrabColors.grey,
    brightness: Brightness.dark,
    primaryColor: GCrabColors.primary,
    scaffoldBackgroundColor: GCrabColors.black,
    textTheme: GCrabTextTheme.darkTextTheme,
    elevatedButtonTheme: GCrabElevatedButtonTheme.darkElevatedButtonTheme,
    appBarTheme: GCrabAppBarTheme.darkAppBarTheme,
    bottomSheetTheme: GCrabBottomSheetTheme.darkBottomSheetTheme,
    checkboxTheme: GCrabCheckboxTheme.darkCheckboxTheme,
    chipTheme: GCrabChipTheme.darkChipTheme,
    outlinedButtonTheme: GCrabOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: GCrabTextFormFieldTheme.darkInputDecorationTheme,
    colorScheme: ColorScheme.fromSeed(seedColor: GCrabColors.primary, brightness: Brightness.dark),
  );
}
