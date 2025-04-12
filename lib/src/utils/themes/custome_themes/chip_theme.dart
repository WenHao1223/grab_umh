import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class GCrabChipTheme {
  GCrabChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: GCrabColors.grey.withAlpha(102),
    labelStyle: const TextStyle(color: GCrabColors.black),
    selectedColor: GCrabColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    checkmarkColor: GCrabColors.white,
  );

  static ChipThemeData darkChipTheme = const ChipThemeData(
    disabledColor: GCrabColors.darkerGrey,
    labelStyle: TextStyle(color: GCrabColors.white),
    selectedColor: GCrabColors.primary,
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    checkmarkColor: GCrabColors.white,
  );
}
