import 'package:flutter/material.dart';
import 'package:flutwork/screens/sign_in_screen.dart';
import 'package:provider/provider.dart';

import '../main.dart'; // Assuming this imports your logger
import '../providers/auth_provider.dart';
import 'dashboard/dashboard_screen.dart';

class PinSignInScreen extends StatefulWidget {
  final String email;

  const PinSignInScreen({super.key, required this.email});

  @override
  State<PinSignInScreen> createState() => _PinSignInScreenState();
}

class _PinSignInScreenState extends State<PinSignInScreen> {
  String _pinCode = '';
  final int _pinLength = 6;

  void _onNumberTap(String number) async {
    setState(() {
      if (_pinCode.length < _pinLength) {
        _pinCode += number;
      }
    });

    if (_pinCode.length == _pinLength) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final bool loginSuccess = await authProvider.loginWithPin(widget.email, _pinCode);

      if (!mounted) {
        logger.d('Widget unmounted after login attempt, stopping further operations.');
        return;
      }

      if (loginSuccess) {
        logger.d('Login successful. Removing PinCodeScreen from navigator stack.');
        // Navigator.pop(context); // Pop this screen off the stack
        /*navigatorKey.currentState!.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (Route<dynamic> route) => false, // This condition removes all previous routes
        );*/
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        setState(() {
          _pinCode = ''; // Clear PIN on failure
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Login failed. Please try again.'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    }
  }

  void _onClearTap() {
    setState(() {
      if (_pinCode.isNotEmpty) {
        _pinCode = _pinCode.substring(0, _pinCode.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Overall white background
      appBar: AppBar(
        backgroundColor: Colors.white, // White AppBar background
        elevation: 0.5, // Subtle shadow for iOS feel
        centerTitle: true,
        title: Text(
          widget.email,
          style: const TextStyle(color: Colors.black, fontSize: 18), // Black title text
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue), // iOS style back arrow
          onPressed: () {
            // Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignInScreen()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Enter your PIN code',
                  style: TextStyle(
                    color: Colors.black87, // Dark grey for primary text
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'for ${widget.email}',
                  style: TextStyle(
                    color: Colors.grey.shade600, // Lighter grey for secondary text
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pinLength, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < _pinCode.length
                            ? Colors.blue // Filled dot for active PIN
                            : Colors.grey.shade300, // Light grey for inactive dot
                        border: Border.all(
                            color: index < _pinCode.length ? Colors.blue : Colors.grey.shade300),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          // Number Pad
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.5,
                crossAxisSpacing: 15, // Increased spacing for cleaner look
                mainAxisSpacing: 15, // Increased spacing for cleaner look
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                if (index == 9) {
                  return Container(); // Empty space for button 7-9
                } else if (index == 11) {
                  return _buildNumberPadButton(
                    child: Icon(Icons.backspace_outlined, color: Colors.blue.shade700, size: 28), // iOS-like backspace
                    onTap: _onClearTap,
                  );
                } else if (index == 10) {
                  return _buildNumberPadButton(
                    child: const Text('0', style: TextStyle(fontSize: 32, color: Colors.black)), // Black for numbers
                    onTap: () => _onNumberTap('0'),
                  );
                } else {
                  final number = (index + 1).toString();
                  return _buildNumberPadButton(
                    child: Text(number, style: const TextStyle(fontSize: 32, color: Colors.black)), // Black for numbers
                    onTap: () => _onNumberTap(number),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberPadButton({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100, // Very light grey for button background
          shape: BoxShape.circle,
          // No border for a flatter iOS look, rely on background color
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}