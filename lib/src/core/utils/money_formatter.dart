/// Rupiah formatting and parsing utilities.
///
/// Pure Dart with no Flutter dependency. Amounts are whole-Rupiah integers (no
/// minor units). Formatting is deterministic and locale-independent so it is
/// safe to use directly in tests and domain calculations.
///
/// Format matches the reference screens:
/// - positive: `Rp 228,832,842`
/// - negative: `-Rp 3,323,000` (sign precedes the `Rp` symbol)
/// - zero: `Rp 0`
class MoneyFormatter {
  MoneyFormatter._();

  static const String symbol = 'Rp';

  /// Groups [amount]'s digits with thousands separators, applying a leading
  /// minus sign for negative values. Does not include the currency symbol.
  ///
  /// Example: `1234567 -> "1,234,567"`, `-545000 -> "-545,000"`.
  static String formatNumber(int amount) {
    final negative = amount < 0;
    final digits = amount.abs().toString();
    final buffer = StringBuffer();
    final firstGroup = digits.length % 3;

    for (var i = 0; i < digits.length; i++) {
      if (i != 0 && (i - firstGroup) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(digits[i]);
    }
    return negative ? '-${buffer.toString()}' : buffer.toString();
  }

  /// Formats [amount] as a full Rupiah string with the `Rp` symbol.
  ///
  /// Example: `228832842 -> "Rp 228,832,842"`, `-3323000 -> "-Rp 3,323,000"`.
  static String format(int amount) {
    if (amount < 0) {
      return '-$symbol ${formatNumber(-amount)}';
    }
    return '$symbol ${formatNumber(amount)}';
  }

  /// Parses a user-entered or formatted string into a whole-Rupiah integer.
  ///
  /// Ignores the currency symbol, whitespace, grouping separators, and any
  /// non-digit characters. Honors a leading or symbol-adjacent minus sign.
  /// Returns `0` when no digits are present.
  ///
  /// Examples:
  /// - `"Rp 228,832,842" -> 228832842`
  /// - `"-Rp 3,323,000" -> -3323000`
  /// - `"545.000" -> 545000`
  /// - `"" -> 0`
  static int parse(String input) {
    final negative = input.contains('-');
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 0;
    final value = int.parse(digits);
    return negative ? -value : value;
  }
}
