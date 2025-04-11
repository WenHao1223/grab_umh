import 'package:flutter/material.dart';
import '../../constants/sizes.dart';
import '../../constants/colors.dart';

class GCrabAppBarTheme{
  GCrabAppBarTheme._();

  static const lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: GCrabColors.black, size: GCrabSizes.iconMd),
    actionsIconTheme: IconThemeData(color: GCrabColors.black, size: GCrabSizes.iconMd),
    titleTextStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: GCrabColors.black),
  );
  static const darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: GCrabColors.black, size: GCrabSizes.iconMd),
    actionsIconTheme: IconThemeData(color: GCrabColors.white, size: GCrabSizes.iconMd),
    titleTextStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: GCrabColors.white),
  );
}