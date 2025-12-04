// dropdown_input_field.dart
import 'package:flutter/material.dart';

import '../constants/style_constants.dart';

class DropdownInputField extends StatelessWidget {
  final String label;
  final String hintText;
  final List<String> items;
  final Color primaryColor;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const DropdownInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.items,
    required this.primaryColor,
    this.selectedValue,
    required this.onChanged,
  });

  static const double borderRadiusValue = 8.0;

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
              color: defaultTextColor,
            ),
          ),
        ),

        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadiusValue),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadiusValue),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadiusValue),
              borderSide: BorderSide(color: primaryColor, width: 2.0),
            ),
            suffixIcon:
            Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor),
          ),

          isExpanded: true,
          initialValue: selectedValue,
          dropdownColor: Colors.white,
          iconSize: 24,
          style: const TextStyle(
            color: defaultTextColor,
            fontSize: 16,
          ),

          items: items.map((String value) {
            final bool isSelected = selectedValue == value;
            return DropdownMenuItem<String>(
              value: value,
              // ใช้ Align เพื่อให้ text เต็มความกว้างของ item
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    /*color: isSelected ? primaryColor : defaultTextColor,*/
                    color : defaultTextColor,
                    /*fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,*/
                  ),
                ),
              ),
            );
          }).toList(),

          onChanged: onChanged,
        ),
      ],
    );
  }
}
