import 'package:flutter/material.dart';
import 'package:grab_umh/src/utils/constants/colors.dart';
import 'package:grab_umh/src/utils/constants/sizes.dart';

/// Custom Outlined Button
class GCrabOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;

  const GCrabOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = GCrabSizes.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: GCrabColors.darkGrey),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: GCrabSizes.fontSizeMd,
          ),
        ),
      ),
    );
  }
}
