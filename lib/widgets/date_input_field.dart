import 'package:flutter/material.dart';

class DateInputField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final Color primaryColor;
  final ValueChanged<DateTime> onDateSelected;

  const DateInputField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.primaryColor,
    required this.onDateSelected,
  });

  // Format DD/MM/YYYY
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime initial = selectedDate ?? DateTime.now();

    final picked = await showDialog<DateTime>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .25),
      builder: (context) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              surfaceTint: Colors.transparent,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
            ),
          ),
          child: Center(
            child: AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: CalendarDatePicker(
                    initialDate: initial,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2030),

                    // 🔥 เลือกวัน = ปิด dialog แล้ว return ค่าวันนั้น
                    onDateChanged: (date) {
                      Navigator.of(context).pop(date);
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: _formatDate(selectedDate));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Color(0xFF555555),
            ),
          ),
        ),

        GestureDetector(
          onTap: () => _selectDate(context),
          child: AbsorbPointer(
            child: TextField(
              controller: controller,
              readOnly: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: primaryColor, width: 2.0),
                ),
                suffixIcon: Icon(Icons.calendar_today, size: 20, color: primaryColor),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
