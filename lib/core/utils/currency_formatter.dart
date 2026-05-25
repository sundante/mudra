import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(double amount, String currency) {
    switch (currency) {
      case 'INR':
        return '₹ ${_formatIndian(amount)}';
      case 'USD':
        return '\$ ${_formatStandard(amount)}';
      case 'GBP':
        return '£ ${_formatStandard(amount)}';
      case 'AED':
        return 'AED ${_formatStandard(amount)}';
      case 'SGD':
        return 'S\$ ${_formatStandard(amount)}';
      case 'AUD':
        return 'A\$ ${_formatStandard(amount)}';
      case 'EUR':
        return '€ ${_formatStandard(amount)}';
      default:
        return amount.toStringAsFixed(2);
    }
  }

  static String compact(double amount, String currency) {
    final abs = amount.abs();
    final sign = amount < 0 ? '-' : '';
    final sym = symbol(currency);

    if (currency == 'INR') {
      if (abs >= 10000000) {
        return '$sign$sym ${(abs / 10000000).toStringAsFixed(2)}Cr';
      } else if (abs >= 100000) {
        return '$sign$sym ${(abs / 100000).toStringAsFixed(2)}L';
      } else if (abs >= 1000) {
        return '$sign$sym ${(abs / 1000).toStringAsFixed(1)}K';
      }
      return format(amount, currency);
    } else {
      if (abs >= 1000000) {
        return '$sign$sym ${(abs / 1000000).toStringAsFixed(2)}M';
      } else if (abs >= 1000) {
        return '$sign$sym ${(abs / 1000).toStringAsFixed(1)}K';
      }
      return format(amount, currency);
    }
  }

  static String symbol(String currency) {
    switch (currency) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'AED':
        return 'AED';
      case 'SGD':
        return 'S\$';
      case 'AUD':
        return 'A\$';
      case 'EUR':
        return '€';
      default:
        return '';
    }
  }

  static String _formatIndian(double amount) {
    final isNegative = amount < 0;
    final abs = amount.abs();
    final intPart = abs.truncate();
    final decPart = ((abs - intPart) * 100).round();

    final s = intPart.toString();
    final buffer = StringBuffer();

    if (s.length <= 3) {
      buffer.write(s);
    } else {
      final rest = s.substring(0, s.length - 3);
      final last3 = s.substring(s.length - 3);
      final grouped = StringBuffer();
      for (var i = 0; i < rest.length; i++) {
        if (i > 0 && (rest.length - i) % 2 == 0) grouped.write(',');
        grouped.write(rest[i]);
      }
      buffer.write('$grouped,$last3');
    }

    final decimal = decPart > 0
        ? '.${decPart.toString().padLeft(2, '0')}'
        : '';
    return '${isNegative ? '-' : ''}$buffer$decimal';
  }

  static String _formatStandard(double amount) {
    return NumberFormat('#,##0.00').format(amount);
  }
}
