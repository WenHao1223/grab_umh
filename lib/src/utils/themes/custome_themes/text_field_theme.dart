import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';

class GCrabTextFormFieldTheme {
  GCrabTextFormFieldTheme._();

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: GCrabColors.darkGrey,
    suffixIconColor: GCrabColors.darkGrey,
    // constraints: const BoxConstraints.expand(height: GCrabSizes.inputFieldHeight),
    labelStyle: const TextStyle().copyWith(fontSize: GCrabSizes.fontSizeMd, color: GCrabColors.black),
    hintStyle: const TextStyle().copyWith(fontSize: GCrabSizes.fontSizeSm, color: GCrabColors.black),
    errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
    floatingLabelStyle: const TextStyle().copyWith(color: GCrabColors.black.withAlpha(204)),
    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(GCrabSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: GCrabColors.grey),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(GCrabSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: GCrabColors.grey),
    ),
    focusedBorder:const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(GCrabSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: GCrabColors.dark),
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(GCrabSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: GCrabColors.warning),
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(GCrabSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 2, color: GCrabColors.warning),
    ),
  );

  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 2,
    prefixIconColor: GCrabColors.darkGrey,
    suffixIconColor: GCrabColors.darkGrey,
    // constraints: const BoxConstraints.expand(height: GCrabSizes.inputFieldHeight),
    labelStyle: const TextStyle().copyWith(fontSize: GCrabSizes.fontSizeMd, color: GCrabColors.white),
    hintStyle: const TextStyle().copyWith(fontSize: GCrabSizes.fontSizeSm, color: GCrabColors.white),
    floatingLabelStyle: const TextStyle().copyWith(color: GCrabColors.white.withAlpha(204)),
    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(GCrabSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: GCrabColors.darkGrey),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(GCrabSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: GCrabColors.darkGrey),
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(GCrabSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: GCrabColors.white),
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(GCrabSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: GCrabColors.warning),
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(GCrabSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 2, color: GCrabColors.warning),
    ),
  );
}
