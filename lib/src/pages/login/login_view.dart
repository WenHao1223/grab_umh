import 'package:flutter/material.dart';
import 'package:grab_umh/src/settings/settings_view.dart';
import 'package:grab_umh/src/utils/constants/sizes.dart';
import 'package:grab_umh/src/components/component.dart';

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