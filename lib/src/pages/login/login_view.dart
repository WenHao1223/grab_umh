import 'package:flutter/material.dart';
import 'package:grab_umh/src/utils/constants/colors.dart';
import '../../settings/settings_view.dart';
import '../../utils/constants/sizes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const routeName = '/login';

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('G Crab'), actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.restorablePushNamed(context, SettingsView.routeName);
          },
        ),
      ]),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(GCrabSizes.defaultSpace),
            child: Column(
              children: [
                // Title Section
                const GCrabSpacing.height(GCrabSizes.spaceBtwSections),
                const Text(
                  'GCrab',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Your everyday everything app.',
                  style: TextStyle(
                    fontSize: GCrabSizes.fontSizeLg,
                  ),
                ),
                const GCrabSpacing.height(GCrabSizes.spaceBtwSections * 2),

                // Form Section
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email Field
                      GCrabTextFormField(
                        controller: _emailController,
                        labelText: 'Email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const GCrabSpacing.height(GCrabSizes.spaceBtwInputFields),

                      // Password Field
                      GCrabPasswordField(
                        controller: _passwordController,
                        isPasswordVisible: _isPasswordVisible,
                        onVisibilityChanged: (visible) {
                          setState(() => _isPasswordVisible = visible);
                        },
                      ),

                      const GCrabSpacing.height(GCrabSizes.spaceBtwSections),

                      // Login Button
                      GCrabPrimaryButton(
                        text: 'Login',
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // TODO: Implement login logic
                            print('Email: ${_emailController.text}');
                            print('Password: ${_passwordController.text}');
                          }
                        },
                      ),

                      const GCrabSpacing.height(GCrabSizes.gridViewSpacing),

                      // Sign Up Button
                      GCrabOutlinedButton(
                        height: 50,
                        text: 'New to GCrab? Sign up!',
                        onPressed: () {
                          // TODO: Implement navigation to sign up page
                          print('Navigate to Sign Up');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom Text Form Field
class GCrabTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const GCrabTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
      ),
      validator: validator,
    );
  }
}

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
