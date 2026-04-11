// lib/screens/sign_in_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/style_constants.dart';
import '../utils/logger.dart';
import '../providers/auth_provider.dart';
import '../services/preferences_service.dart';
import 'main/main_screen.dart';
import 'pin_sign_in_screen.dart';

/// Sign-in screen with email/password and PIN options.
/// Uses [ThemeData] and [style_constants] for a single design system.
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
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onError,
          ),
        ),
        backgroundColor: theme.colorScheme.error,
      ),
    );
  }

  Future<void> _verifyEmail() async {
    final email = _emailController.text.trim();
    if (!_isEmailValid(email)) return;

    _setLoading(true);
    var exists = false;
    String? errorMessage;

    try {
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
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    _setLoading(true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final success = await auth.loginWithPassword(email, password);
      if (!mounted) return;

      if (success) {
        await PreferencesService.saveRememberEmail(email);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        _showSnackBar(auth.errorMessage ?? 'Login failed.');
      }
    } finally {
      if (mounted) {
        _setLoading(false);
      }
    }
  }

  /// Brand row: icon + app name using [ColorScheme.primary].
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, color: primary, size: 40),
            const SizedBox(width: 8),
            Text(
              'FlutWork',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Sign In',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: defaultTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Form fields and primary action; styles come from [ThemeData].
  Widget _buildSignInForm(BuildContext context) {
    final theme = Theme.of(context);
    final bodyLarge = theme.textTheme.bodyLarge;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: bodyLarge,
            decoration: InputDecoration(
              hintText: 'Email or Username',
              errorText: _emailErrorText,
            ).applyDefaults(theme.inputDecorationTheme),
            onChanged: (_) {
              if (_emailErrorText != null) {
                setState(() => _emailErrorText = null);
              }
            },
            enabled: !_isLoading,
          ),
          if (_showPasswordInput) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              style: bodyLarge,
              decoration: InputDecoration(
                hintText: 'Password',
              ).applyDefaults(theme.inputDecorationTheme),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password.';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters.';
                }
                return null;
              },
              enabled: !_isLoading,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isLoading ? null : () {},
                child: const Text('Forgot Password?'),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: 54,
            width: double.infinity,
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
              child: _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : Text(
                      _showPasswordInput
                          ? 'Sign In'
                          : 'Sign In with Account',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Secondary label and social icon row (placeholders until OAuth is wired).
  Widget _buildSocialLogin(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      children: [
        const SizedBox(height: 30),
        Text(
          'Or sign in with',
          style: theme.textTheme.titleSmall?.copyWith(
            color: defaultTextColor.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _SocialIconButton(
              iconPath: 'assets/images/google-logo.png',
              tooltip: 'Sign in with Google',
              isLoading: _isLoading,
              onPressed: () {},
              borderColor: cs.outlineVariant,
            ),
            _SocialIconButton(
              iconPath: 'assets/images/facebook-logo.png',
              tooltip: 'Sign in with Facebook',
              isLoading: _isLoading,
              onPressed: () {},
              borderColor: cs.outlineVariant,
            ),
            _SocialIconButton(
              iconPath: 'assets/images/apple-logo.png',
              tooltip: 'Sign in with Apple',
              isLoading: _isLoading,
              onPressed: () {},
              borderColor: cs.outlineVariant,
            ),
          ],
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    final savedEmail = PreferencesService.getRememberEmail();
    if (savedEmail != null && savedEmail.isNotEmpty) {
      _emailController.text = savedEmail;
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        _buildHeader(context),
                        const SizedBox(height: 32),
                        _buildSignInForm(context),
                        const SizedBox(height: 8),
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
                            _showPasswordInput
                                ? 'Sign In with PIN'
                                : 'Sign In with Password',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: _isLoading
                                  ? primaryColor.withValues(alpha: 0.45)
                                  : null,
                            ),
                          ),
                        ),
                        _buildSocialLogin(context),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Circular social provider button using [secondaryColor] and theme outline.
class _SocialIconButton extends StatelessWidget {
  const _SocialIconButton({
    required this.iconPath,
    required this.tooltip,
    required this.onPressed,
    required this.isLoading,
    required this.borderColor,
  });

  final String iconPath;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: secondaryColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.35),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Image.asset(iconPath, height: 28, width: 28),
        onPressed: isLoading ? null : onPressed,
        tooltip: tooltip,
      ),
    );
  }
}
