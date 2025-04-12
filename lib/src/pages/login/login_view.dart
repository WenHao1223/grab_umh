import 'package:flutter/material.dart';
import 'package:grab_umh/src/settings/settings_view.dart';
import 'package:grab_umh/src/utils/constants/sizes.dart';
import 'package:grab_umh/src/components/component.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:grab_umh/src/models/driver_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const routeName = '/';

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
  List<Driver>? _drivers;
  final _auth = FirebaseAuth.instance;
  Driver? driver;

  @override
  void initState() {
    super.initState();
    // _loadDrivers();
    _checkExistingLogin();
  }

  Future<void> _checkExistingLogin() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = _auth.currentUser;
      if (currentUser != null && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  // Future<void> _loadDrivers() async {
  //   try {
  //     final String jsonString =
  //         await rootBundle.loadString('assets/data/drivers.json');
  //     final List<dynamic> jsonList = json.decode(jsonString);
  //     setState(() {
  //       _drivers = jsonList.map((json) => Driver.fromJson(json)).toList();
  //     });
  //   } catch (e) {
  //     throw 'Error loading drivers: $e';
  //   }
  // }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;

      try {
        // Sign in with Firebase
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Find driver by email
        driver = _drivers?.firstWhere(
          (d) => d.email == email,
        );

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          String message = 'Authentication failed';
          if (e.code == 'user-not-found') {
            message = 'No user found for that email';
          } else if (e.code == 'wrong-password') {
            message = 'Wrong password provided';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Driver not found')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
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
                        onPressed: _handleLogin,
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
