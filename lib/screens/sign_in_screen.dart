// lib/screens/sign_in_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart'; // logger
import '../providers/auth_provider.dart';
import '../services/preferences_service.dart';
import 'pin_sign_in_screen.dart';

/// SignIn screen with email/password and PIN options.
/// Supports email validation, loading state, and social login placeholders.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _showPasswordInput = false;
  String? _emailErrorText;

  @override
  void initState() {
    super.initState();

    // โหลด email ที่เคยจำไว้
    final savedEmail = PreferencesService.getRememberEmail();
    if (savedEmail != null && savedEmail.isNotEmpty) {
      _emailController.text = savedEmail;
    }
  }

  // -----------------------
  // Helper Methods
  // -----------------------

  void _setLoading(bool value) {
    if (mounted) {
      setState(() {
        _isLoading = value;
      });
    }
  }

  bool _isEmailValid(String email) {
    if (email.isEmpty) {
      setState(() => _emailErrorText = 'Please enter your email or username.');
      return false;
    }
    setState(() => _emailErrorText = null);
    return true;
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade400),
    );
  }

  Future<void> _verifyEmail() async {
    final email = _emailController.text.trim();
    if (!_isEmailValid(email)) return;

    _setLoading(true);
    bool exists = false;
    String? errorMessage;

    try {
      // ดึง Provider ก่อนเข้าสู่ async เพื่อหลีกเลี่ยงการใช้ context หลัง async gap
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      exists = await authProvider.validateEmail(email);
    } catch (e) {
      logger.e('Email validation error: $e');
      errorMessage = e.toString();
    } finally {
      if (mounted) {
        _setLoading(false);
      }
    }

    if (!mounted) return;

    // ----- handle result -----
    if (exists) {
      await PreferencesService.saveRememberEmail(email);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PinSignInScreen(email: email),
        ),
      );

      logger.d('Navigated to PinSignInScreen with $email');
    } else {
      setState(() => _emailErrorText = 'This email is not found in the system.');
      logger.d('Email not found: $email');
    }

    if (errorMessage != null && errorMessage.isNotEmpty) {
      _showSnackBar(errorMessage);
    }
  }

  Future<void> _doLoginWithPassword() async {
    if (!_formKey.currentState!.validate()) return;

    _setLoading(true);
    try {
      // Placeholder for login logic
      // Example:
      // final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // await authProvider.login(email, password);
    } finally {
      _setLoading(false);
    }
  }

  Widget _buildSocialIconButton({
    required String iconPath,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade200, width: 0.8),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Image.asset(iconPath, height: 28, width: 28),
        onPressed: _isLoading ? null : onPressed,
        tooltip: tooltip,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade100,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.blue, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),

              // Logo + App Name
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, color: Colors.blue.shade700, size: 40),
                  const SizedBox(width: 8),
                  Text('FlutWork', style: TextStyle(color: Colors.blue.shade700, fontSize: 36, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 60),

              Align(
                alignment: Alignment.centerLeft,
                child: const Text('Sign In', style: TextStyle(color: Colors.black87, fontSize: 30, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 30),

              // Form Section
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: inputDecoration.copyWith(hintText: 'Email or Username', errorText: _emailErrorText),
                      onChanged: (_) {
                        if (_emailErrorText != null) setState(() => _emailErrorText = null);
                      },
                      enabled: !_isLoading,
                    ),
                    if (_showPasswordInput) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: inputDecoration.copyWith(hintText: 'Password'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your password.';
                          if (value.length < 6) return 'Password must be at least 6 characters.';
                          return null;
                        },
                        enabled: !_isLoading,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      TextButton(
                        onPressed: _isLoading ? null : () {},
                        child: Text('Forgot Password?', style: TextStyle(color: Colors.blue.shade600, fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Sign In Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                    if (_showPasswordInput) {
                      _doLoginWithPassword();
                    } else {
                      _verifyEmail();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_showPasswordInput ? 'Sign In' : 'Sign In with Account', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 20),

              // Toggle Login Mode
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                  setState(() {
                    _showPasswordInput = !_showPasswordInput;
                    _emailController.clear();
                    _passwordController.clear();
                    _emailErrorText = null;
                    _formKey.currentState?.reset();
                  });
                },
                child: Text(
                  _showPasswordInput ? 'Sign In with PIN' : 'Sign In with Password',
                  style: TextStyle(color: _isLoading ? Colors.blue.shade300 : Colors.blue, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),

              // Social Login
              const SizedBox(height: 30),
              Text('Or sign in with', style: TextStyle(color: Colors.grey.shade600, fontSize: 15, fontWeight: FontWeight.w500)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSocialIconButton(iconPath: 'assets/images/google-logo.png', tooltip: 'Sign in with Google', onPressed: () {}),
                  _buildSocialIconButton(iconPath: 'assets/images/facebook-logo.png', tooltip: 'Sign in with Facebook', onPressed: () {}),
                  _buildSocialIconButton(iconPath: 'assets/images/apple-logo.png', tooltip: 'Sign in with Apple', onPressed: () {}),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
