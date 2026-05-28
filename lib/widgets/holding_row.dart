import 'package:flutter/material.dart';

import '../core/constants/spacing.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/currency_formatter.dart';
import 'common/amount_display.dart';

class HoldingRow extends StatelessWidget {
  const HoldingRow({
    super.key,
    required this.schemeName,
    required this.platformName,
    required this.investedAmount,
    required this.currentValue,
    required this.currency,
    required this.onTap,
  });

  final String schemeName;
  final String platformName;
  final double investedAmount;
  final double currentValue;
  final String currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pnl = currentValue - investedAmount;
    final percent =
        investedAmount == 0 ? 0.0 : pnl / investedAmount * 100;
    final (pnlColor, pnlBg) = pnl > 0
        ? (AppColors.green, AppColors.greenLight)
        : pnl < 0
            ? (AppColors.red, AppColors.redLight)
            : (AppColors.inkDim, AppColors.surfaceAlt);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: AppSpacing.xs),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schemeName,
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.ink),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.amberLight,
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          platformName,
                          style: AppTypography.labelSmall
                              .copyWith(color: AppColors.amber),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${CurrencyFormatter.format(investedAmount, currency)} invested',
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.inkDim),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AmountDisplay(
                  amount: currentValue,
                  currency: currency,
                  style: AppTypography.monoSmall
                      .copyWith(color: AppColors.ink),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs, vertical: 2),
                  decoration: BoxDecoration(
                    color: pnlBg,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    '${_signed(pnl, currency)} (${_signedPct(percent)})',
                    style: AppTypography.monoXSmall
                        .copyWith(color: pnlColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _signed(double v, String currency) {
    final f = CurrencyFormatter.format(v, currency);
    return v > 0 ? '+$f' : f;
  }

  static String _signedPct(double v) {
    final f = '${v.toStringAsFixed(1)}%';
    return v > 0 ? '+$f' : f;
  }
}

