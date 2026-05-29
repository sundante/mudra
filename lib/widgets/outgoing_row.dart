import 'package:flutter/material.dart';

import '../core/constants/spacing.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import 'common/amount_display.dart';
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 3, color: accentColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: AppSpacing.sm,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              _Badge(
                                label: categoryLabel,
                                backgroundColor: AppColors.surfaceAlt,
                                textColor: AppColors.inkDim,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              _Badge(
                                label: 'Day $debitDate',
                                backgroundColor: AppColors.surfaceAlt,
                                textColor: AppColors.inkDim,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AmountDisplay(
                          amount: amount,
                          currency: currency,
                          style: AppTypography.monoSmall,
                        ),
                        const SizedBox(height: 2),
                        SectionLabel(_daysUntilLabel(daysUntil)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _daysUntilLabel(int d) {
    if (d == 0) return 'today';
    if (d == 1) return 'tomorrow';
    return 'in $d days';
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
