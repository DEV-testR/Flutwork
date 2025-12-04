import 'package:flutter/material.dart';

class TextInputField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final Color primaryColor;

  final bool readOnly;
  final VoidCallback? onTap;

  final Widget? suffixIcon;
  final Widget? prefixIcon;

  const TextInputField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    required this.primaryColor,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.prefixIcon,
  });

  static const double _radius = 8.0;
  static const Color _labelColor = Color(0xFF555555);
  static const Color _textColor = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: _labelColor,
            ),
          ),
        ),

        // TextField
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(
            color: _textColor,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),

            // Border style
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_radius),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_radius),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_radius),
              borderSide: BorderSide(
                color: primaryColor,
                width: 2.0,
              ),
            ),

            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,

            suffixIconConstraints:
            const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ),
      ],
    );
  }
}
