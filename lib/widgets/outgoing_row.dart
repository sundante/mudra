import 'package:flutter/material.dart';

import '../core/constants/spacing.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import 'common/amount_display.dart';
import 'common/mudra_card.dart';
import 'common/section_label.dart';

class OutgoingRow extends StatelessWidget {
  const OutgoingRow({
    super.key,
    required this.name,
    required this.categoryLabel,
    required this.debitDate,
    required this.daysUntil,
    required this.amount,
    required this.currency,
    required this.accentColor,
    required this.onTap,
  });

  final String name;
  final String categoryLabel;
  final int debitDate;
  final int daysUntil;
  final double amount;
  final String currency;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MudraCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 64,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _Badge(
                      label: categoryLabel,
                      backgroundColor: AppColors.surfaceAlt,
                      textColor: AppColors.inkDim,
                    ),
                    _Badge(
                      label: 'Day $debitDate',
                      backgroundColor: AppColors.goldLight,
                      textColor: AppColors.gold,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AmountDisplay(
                amount: amount,
                currency: currency,
                style: AppTypography.monoMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              SectionLabel(_daysUntilLabel(daysUntil), color: AppColors.inkDim),
            ],
          ),
        ],
      ),
    );
  }

  String _daysUntilLabel(int daysUntil) {
    if (daysUntil == 0) return 'today';
    if (daysUntil == 1) return 'tomorrow';
    return 'in $daysUntil days';
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTypography.monoXSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
