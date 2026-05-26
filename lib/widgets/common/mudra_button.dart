import 'package:flutter/material.dart';

import '../../core/constants/spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum MudraButtonVariant { primary, secondary, destructive }

class MudraButton extends StatelessWidget {
  const MudraButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = MudraButtonVariant.primary,
    this.expand = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final MudraButtonVariant variant;
  final bool expand;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(label),
            ],
          );

    final button = switch (variant) {
      MudraButtonVariant.primary => ElevatedButton(
          onPressed: onPressed,
          child: child,
        ),
      MudraButtonVariant.secondary => OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.ink,
            side: const BorderSide(color: AppColors.border),
            textStyle: AppTypography.labelLarge,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          child: child,
        ),
      MudraButtonVariant.destructive => ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.red,
            foregroundColor: Colors.white,
          ),
          child: child,
        ),
    };

    if (!expand) return button;

    return SizedBox(width: double.infinity, child: button);
  }
}
