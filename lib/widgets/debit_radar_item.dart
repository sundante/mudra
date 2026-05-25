import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/date_helpers.dart';
import '../data/models/outgoing.dart';
import 'common/amount_display.dart';

class DebitRadarItem extends StatelessWidget {
  const DebitRadarItem({
    super.key,
    required this.outgoing,
    required this.daysUntil,
    required this.currency,
  });

  final Outgoing outgoing;
  final int daysUntil;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final isExpense = outgoing.safeType == OutgoingType.expense;
    final barColor = isExpense ? AppColors.red : AppColors.amber;
    final urgent = DateHelpers.isUrgent(daysUntil);

    final Color chipBg;
    final Color chipText;
    if (urgent) {
      chipBg = AppColors.redLight;
      chipText = AppColors.red;
    } else if (daysUntil <= 5) {
      chipBg = AppColors.amberLight;
      chipText = AppColors.amber;
    } else {
      chipBg = AppColors.surfaceAlt;
      chipText = AppColors.inkDim;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(width: 3, height: 48, color: barColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(outgoing.safeName, style: AppTypography.bodyMedium),
                Text(
                  outgoing.safeCategory.name,
                  style: AppTypography.monoXSmall
                      .copyWith(color: AppColors.inkDim),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AmountDisplay(
                amount: outgoing.safeAmount,
                currency: currency,
                style: AppTypography.monoSmall,
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  DateHelpers.debitLabel(daysUntil),
                  style: AppTypography.monoXSmall.copyWith(color: chipText),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
