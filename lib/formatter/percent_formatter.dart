import 'package:flutter/services.dart';

class PercentFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) return newValue;

    double value = double.tryParse(newValue.text
            .replaceAll(RegExp(r'%'), '')
            .replaceAll(RegExp(r','), '.')) ??
        0;
    String newText = '${newValue.text.replaceAll(RegExp(r'%'), '')}%';

    if (value > 100) {
      newText = '100%';
    } else if (value < 0) {
      newText = '0%';
    }

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length - 1),
    );
  }
}
