import 'package:flutter/material.dart';

/// Custom Spacing Widget
class GCrabSpacing extends StatelessWidget {
  final double width;
  final double height;

  const GCrabSpacing.height(this.height, {super.key}) : width = 0;
  const GCrabSpacing.width(this.width, {super.key}) : height = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: width,
          height: height,
        ),
      ],
    );
  }
}
