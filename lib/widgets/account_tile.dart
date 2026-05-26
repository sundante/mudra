import 'package:flutter/material.dart';

import '../core/constants/spacing.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import 'common/amount_display.dart';
import 'common/mudra_card.dart';
import 'common/section_label.dart';

class AccountTile extends StatelessWidget {
  const AccountTile({
    super.key,
    required this.nickname,
    required this.bankName,
    required this.categoryLabel,
    required this.balance,
    required this.fdAmount,
    required this.currency,
    required this.includeInLiquid,
    required this.onTap,
    required this.onBalanceTap,
  });

  final String nickname;
  final String bankName;
  final String categoryLabel;
  final double balance;
  final double fdAmount;
  final String currency;
  final bool includeInLiquid;
  final VoidCallback onTap;
  final VoidCallback onBalanceTap;

  @override
  Widget build(BuildContext context) {
    return MudraCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nickname,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (bankName.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        bankName,
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.inkDim),
                      ),
                    ],
                    if (categoryLabel.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        categoryLabel,
                        style: AppTypography.monoXSmall
                            .copyWith(color: AppColors.amber),
                      ),
                    ],
                  ],
                ),
              ),
              if (includeInLiquid)
                const _Badge(
                  label: 'LIQUID',
                  color: AppColors.greenLight,
                  textColor: AppColors.green,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: onBalanceTap,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  const SectionLabel('balance'),
                  const Spacer(),
                  AmountDisplay(
                    amount: balance,
                    currency: currency,
                    style: AppTypography.monoLarge,
                    coloured: balance < 0,
                  ),
                ],
              ),
            ),
          ),
          if (fdAmount > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const SectionLabel('fixed deposit'),
                const Spacer(),
                AmountDisplay(
                  amount: fdAmount,
                  currency: currency,
                  style:
                      AppTypography.monoSmall.copyWith(color: AppColors.amber),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTypography.monoXSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
