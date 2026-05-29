import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'section_label.dart';

/// Flat white hero card — gold primary number, black label.
/// Max 1 per screen.
class MudraHeroCard extends StatelessWidget {
  const MudraHeroCard({
    super.key,
    required this.label,
    required this.amount,
    this.amountColor,
    this.sublabel,
    this.trailing,
    this.bottom,
  });

  final String label;
  final String amount;

  /// Defaults to AppColors.ink. Pass AppColors.green or .red for semantic values.
  final Color? amountColor;
  final String? sublabel;
  final Widget? trailing;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SectionLabel(label),
              if (trailing != null) ...[
                const Spacer(),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: AppTypography.displaySmall.copyWith(
              color: amountColor ?? AppColors.ink,
              height: 1.0,
            ),
          ),
          if (sublabel != null) ...[
            const SizedBox(height: 4),
            Text(
              sublabel!,
              style: AppTypography.bodySmall.copyWith(color: AppColors.inkDim),
            ),
          ],
          if (bottom != null) ...[
            const SizedBox(height: AppSpacing.md),
            bottom!,
          ],
        ],
      ),
    );
  }
}
