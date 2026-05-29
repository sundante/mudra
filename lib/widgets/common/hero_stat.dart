import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// A single stat column used inside a [MudraHeroCard] bottom row.
///
/// Set [onDarkBackground] to true when the card uses a dark gradient
/// background (e.g. Net Worth card) so labels render in white instead of
/// [AppColors.inkDim].
class HeroStat extends StatelessWidget {
  const HeroStat({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.onDarkBackground = false,
  });

  final String label;
  final String value;
  final Color color;

  /// When true, renders the label in white38 instead of AppColors.inkDim.
  final bool onDarkBackground;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.monoSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.monoXSmall.copyWith(
              letterSpacing: 1.0,
              color: onDarkBackground ? Colors.white38 : AppColors.inkDim,
            ),
          ),
        ],
      ),
    );
  }
}
