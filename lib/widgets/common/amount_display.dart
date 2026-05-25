import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';

class AmountDisplay extends StatelessWidget {
  const AmountDisplay({
    super.key,
    required this.amount,
    required this.currency,
    this.style,
    this.showSign = false,
    this.coloured = false,
    this.compact = false,
  });

  final double amount;
  final String currency;
  final TextStyle? style;
  final bool showSign;
  final bool coloured;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (coloured) {
      if (amount > 0) {
        color = AppColors.green;
      } else if (amount < 0) {
        color = AppColors.red;
      } else {
        color = AppColors.inkDim;
      }
    } else {
      color = style?.color ?? AppColors.ink;
    }

    final formatted = compact
        ? CurrencyFormatter.compact(amount, currency)
        : CurrencyFormatter.format(amount, currency);
    final display = (showSign && amount > 0) ? '+$formatted' : formatted;

    final base = style ?? const TextStyle(fontSize: 16);
    final resolved = GoogleFonts.ibmPlexMono(
      fontSize: base.fontSize,
      fontWeight: base.fontWeight,
      letterSpacing: base.letterSpacing,
      color: color,
    );

    return Text(display, style: resolved);
  }
}
