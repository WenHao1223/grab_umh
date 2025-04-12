import 'package:flutter/material.dart';

/// Custom Password Field
class GCrabPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool isPasswordVisible;
  final Function(bool) onVisibilityChanged;

  const GCrabPasswordField({
    super.key,
    required this.controller,
    required this.isPasswordVisible,
    required this.onVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () => onVisibilityChanged(!isPasswordVisible),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }
}