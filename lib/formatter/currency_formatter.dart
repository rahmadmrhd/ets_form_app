import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter implements TextInputFormatter {
  static double toDouble(String text, {double defaultValue = 0}) {
    return double.tryParse(text
            .replaceAll(RegExp(r"Rp|\."), '')
            .replaceAll(RegExp(r','), '.')) ??
        defaultValue;
  }

  static String format(double value) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  final NumberFormat _numberFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) return newValue;

    double value = double.tryParse(newValue.text) ?? 0;
    String newText = _numberFormat.format(value);

    return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length));
  }
}
