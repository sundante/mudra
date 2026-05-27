import 'package:flutter/material.dart';

import '../core/constants/spacing.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/currency_formatter.dart';
import '../data/models/investment_platform.dart';
import 'common/amount_display.dart';
import 'common/mudra_card.dart';

class PlatformCard extends StatelessWidget {
  const PlatformCard({
    super.key,
    required this.platform,
    required this.currency,
    required this.onTap,
  });

  final InvestmentPlatform platform;
  final String currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pnl = platform.safeCurrentValue - platform.safeInvestedAmount;
    final percent = platform.safeInvestedAmount == 0
        ? 0.0
        : pnl / platform.safeInvestedAmount * 100;
    final (pnlColor, pnlBackground) = pnl > 0
        ? (AppColors.green, AppColors.greenLight)
        : pnl < 0
            ? (AppColors.red, AppColors.redLight)
            : (AppColors.inkDim, AppColors.surfaceAlt);

    return MudraCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  platform.safePlatformName,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.amberLight,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  assetTypeLabel(platform.safeAssetType),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _Value(
                  label: 'INVESTED',
                  amount: platform.safeInvestedAmount,
                  currency: currency,
                  color: AppColors.inkDim,
                ),
              ),
              Expanded(
                child: _Value(
                  label: 'CURRENT',
                  amount: platform.safeCurrentValue,
                  currency: currency,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: pnlBackground,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                '${_signedAmount(pnl, currency)} (${_signedPercent(percent)})',
                style: AppTypography.monoXSmall.copyWith(
                  color: pnlColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _signedAmount(double amount, String currency) {
    final value = CurrencyFormatter.format(amount, currency);
    return amount > 0 ? '+$value' : value;
  }

  static String _signedPercent(double percent) {
    final value = '${percent.toStringAsFixed(1)}%';
    return percent > 0 ? '+$value' : value;
  }
}

class _Value extends StatelessWidget {
  const _Value({
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
  });

  final String label;
  final double amount;
  final String currency;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                AppTypography.sectionLabel.copyWith(color: AppColors.inkDim)),
        const SizedBox(height: AppSpacing.xs),
        AmountDisplay(
          amount: amount,
          currency: currency,
          style: AppTypography.monoSmall.copyWith(color: color),
        ),
      ],
    );
  }
}

String assetTypeLabel(AssetType type) => switch (type) {
      AssetType.indianStocks => 'Indian Stocks',
      AssetType.usStocks => 'US Stocks',
      AssetType.mutualFund => 'Mutual Fund',
      AssetType.ppf => 'PPF',
      AssetType.epf => 'EPF',
      AssetType.nps => 'NPS',
      AssetType.gold => 'Gold',
      AssetType.other => 'Other',
    };
