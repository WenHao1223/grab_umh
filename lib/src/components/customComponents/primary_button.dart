import 'package:flutter/material.dart';
import '../../utils/constants/sizes.dart';

/// Custom Primary Button
class GCrabPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const GCrabPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: GCrabSizes.fontSizeMd),
        ),
      ),
    );
  }
}