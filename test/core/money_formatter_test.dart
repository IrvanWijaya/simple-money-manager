import 'package:flutter_test/flutter_test.dart';
import 'package:simple_money_manager/src/core/utils/money_formatter.dart';

void main() {
  group('MoneyFormatter.format', () {
    test('formats positive amounts with Rp and grouping', () {
      expect(MoneyFormatter.format(228832842), 'Rp 228,832,842');
      expect(MoneyFormatter.format(545000), 'Rp 545,000');
      expect(MoneyFormatter.format(1000), 'Rp 1,000');
      expect(MoneyFormatter.format(999), 'Rp 999');
    });

    test('formats zero', () {
      expect(MoneyFormatter.format(0), 'Rp 0');
    });

    test('formats negative amounts with leading minus before Rp', () {
      expect(MoneyFormatter.format(-3323000), '-Rp 3,323,000');
      expect(MoneyFormatter.format(-545000), '-Rp 545,000');
      expect(MoneyFormatter.format(-5), '-Rp 5');
    });
  });

  group('MoneyFormatter.formatNumber', () {
    test('groups digits in threes', () {
      expect(MoneyFormatter.formatNumber(1), '1');
      expect(MoneyFormatter.formatNumber(12), '12');
      expect(MoneyFormatter.formatNumber(123), '123');
      expect(MoneyFormatter.formatNumber(1234), '1,234');
      expect(MoneyFormatter.formatNumber(1234567), '1,234,567');
    });

    test('handles negatives without a currency symbol', () {
      expect(MoneyFormatter.formatNumber(-545000), '-545,000');
    });
  });

  group('MoneyFormatter.parse', () {
    test('parses formatted Rupiah strings', () {
      expect(MoneyFormatter.parse('Rp 228,832,842'), 228832842);
      expect(MoneyFormatter.parse('-Rp 3,323,000'), -3323000);
    });

    test('ignores arbitrary grouping/punctuation', () {
      expect(MoneyFormatter.parse('545.000'), 545000);
      expect(MoneyFormatter.parse('1 234 567'), 1234567);
    });

    test('returns 0 for empty or digit-free input', () {
      expect(MoneyFormatter.parse(''), 0);
      expect(MoneyFormatter.parse('Rp'), 0);
      expect(MoneyFormatter.parse('abc'), 0);
    });

    test('honors a leading minus sign', () {
      expect(MoneyFormatter.parse('-12,000'), -12000);
    });

    test('round-trips format then parse', () {
      for (final value in <int>[0, 5, 1000, 545000, -3323000, 228832842]) {
        expect(MoneyFormatter.parse(MoneyFormatter.format(value)), value);
      }
    });
  });
}
